# The contents of this file are subject to the MonetDB Public License
# Version 1.1 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://www.monetdb.org/Legal/MonetDBLicense
#
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
# License for the specific language governing rights and limitations
# under the License.
#
# The Original Code is the MonetDB Database System.
#
# The Initial Developer of the Original Code is CWI.
# Portions created by CWI are Copyright (C) 1997-July 2008 CWI.
# Copyright August 2008-2012 MonetDB B.V.
# All Rights Reserved.

import logging

from monetdb.sql import monetize, pythonize
from monetdb.exceptions import *
from monetdb import mapi

logger = logging.getLogger("monetdb")

class Cursor(object):
    """This object represents a database cursor, which is used to manage
    the context of a fetch operation. Cursors created from the same
    connection are not isolated, i.e., any changes done to the
    database by a cursor are immediately visible by the other
    cursors"""
    def __init__(self, connection):
        """This read-only attribute return a reference to the Connection
        object on which the cursor was created."""
        self.connection = connection

        """last executed operation (query)"""
        self.operation = ""

        """This read/write attribute specifies the number of rows to
        fetch at a time with .fetchmany()"""
        self.arraysize = 100


        """This read-only attribute specifies the number of rows that
        the last .execute*() produced (for DQL statements like
        'select') or affected (for DML statements like 'update' or
        'insert').

        The attribute is -1 in case no .execute*() has been
        performed on the cursor or the rowcount of the last
        operation is cannot be determined by the interface."""
        self.rowcount = -1

        """This read-only attribute is a sequence of 7-item
        sequences.

        Each of these sequences contains information describing
        one result column:

          (name,
           type_code,
           display_size,
           internal_size,
           precision,
           scale,
           null_ok)

        This attribute will be None for operations that
        do not return rows or if the cursor has not had an
        operation invoked via the .execute*() method yet.
        """
        self.description = None

        #This read-only attribute indicates at which row
        #we currently are
        self.rownumber = -1

        self.__executed = None

        # the offset of the current resultset in the total resultset
        self.__offset = 0

        # the resultset
        self.__rows = []

        # used to identify a query during server contact.
        #Only select queries have query ID
        self.__query_id = -1

        """This is a Python list object to which the interface appends
        tuples (exception class, exception value) for all messages
        which the interfaces receives from the underlying database for
        this cursor.

        The list is cleared by all standard cursor methods calls (prior
        to executing the call) except for the .fetch*() calls
        automatically to avoid excessive memory usage and can also be
        cleared by executing "del cursor.messages[:]".

        All error and warning messages generated by the database are
        placed into this list, so checking the list allows the user to
        verify correct operation of the method calls.

        """
        self.messages = []


        """This read-only attribute provides the rowid of the last
        modified row (most databases return a rowid only when a single
        INSERT operation is performed). If the operation does not set
        a rowid or if the database does not support rowids, this
        attribute should be set to None.

        The semantics of .lastrowid are undefined in case the last
        executed statement modified more than one row, e.g. when
        using INSERT with .executemany()."""
        self.lastrowid = None

    def __check_executed(self):
        if not self.__executed:
            self.__exception_handler(ProgrammingError, "do a execute() first")


    """
    def callproc(self, procname, parameters=None):
        (This method is optional since not all databases provide
        stored procedures. [3])

        Call a stored database procedure with the given name. The
        sequence of parameters must contain one entry for each
        argument that the procedure expects. The result of the
        call is returned as modified copy of the input
        sequence. Input parameters are left untouched, output and
        input/output parameters replaced with possibly new values.

        The procedure may also provide a result set as
        output. This must then be made available through the
        standard .fetch*() methods.
    """


    def close(self):
        """ Close the cursor now (rather than whenever __del__ is
        called).  The cursor will be unusable from this point
        forward; an Error (or subclass) exception will be raised
        if any operation is attempted with the cursor."""
        self.connection = None


    def execute(self, operation, parameters=None):
        """Prepare and execute a database operation (query or
        command).  Parameters may be provided as mapping and
        will be bound to variables in the operation.
        """

        if not self.connection:
            self.__exception_handler(ProgrammingError, "cursor is closed")

        # clear message history
        self.messages = []

        # convert to utf-8
        operation = unicode(operation).encode('utf-8')

        # set the number of rows to fetch
        self.connection.command('Xreply_size %s' % self.arraysize)

        if operation == self.operation:
            #same operation, DBAPI mentioned something about reuse
            # but monetdb doesn't support this
            pass
        else:
            self.operation = operation

        if parameters:
            if isinstance(parameters, dict):
                query = operation % dict([(k, monetize.convert(v))
                    for (k,v) in parameters.items()])
            elif type(parameters) == list or type(parameters) == tuple:
                query = operation % tuple([monetize.convert(item) for item in parameters])
            elif isinstance(parameters, str):
                query = operation % monetize.convert(parameters)
            else:
                self.__exception_handler(ValueError,
                        "Parameters should be None, dict or list, now it is %s"
                        % type(parameters))
        else:
           query = operation

        block = self.connection.execute(query)
        self.__store_result(block)
        self.rownumber = 0
        self.__executed = operation
        return self.rowcount



    def executemany(self, operation, seq_of_parameters):
        """Prepare a database operation (query or command) and then
        execute it against all parameter sequences or mappings
        found in the sequence seq_of_parameters.

        It will return the number or rows affected
        """

        count = 0
        for parameters in seq_of_parameters:
            count += self.execute(operation, parameters)
        self.rowcount = count
        return count


    def fetchone(self):
        """Fetch the next row of a query result set, returning a
        single sequence, or None when no more data is available."""
        logger.debug("II executing fetch one")

        self.__check_executed()

        if self.__query_id == -1:
            self.__exception_handler(ProgrammingError,
                    "query didn't result in a resultset")

        if self.rownumber >= (self.rowcount):
            logger.debug("rownumber >= rowcount")
            return None

        logger.debug("rownumber: %s" % self.rownumber)
        logger.debug("offset: %s" % self.__offset)
        logger.debug("lenrows: %s" % len(self.__rows))


        if self.rownumber >= (self.__offset + len(self.__rows)):
            self.nextset()

        result = self.__rows[self.rownumber - self.__offset]
        self.rownumber += 1
        return result


    def fetchmany(self, size=None):
        """Fetch the next set of rows of a query result, returning a
        sequence of sequences (e.g. a list of tuples). An empty
        sequence is returned when no more rows are available.

        The number of rows to fetch per call is specified by the
        parameter.  If it is not given, the cursor's arraysize
        determines the number of rows to be fetched. The method
        should try to fetch as many rows as indicated by the size
        parameter. If this is not possible due to the specified
        number of rows not being available, fewer rows may be
        returned.

        An Error (or subclass) exception is raised if the previous
        call to .execute*() did not produce any result set or no
        call was issued yet.

        Note there are performance considerations involved with
        the size parameter.  For optimal performance, it is
        usually best to use the arraysize attribute.  If the size
        parameter is used, then it is best for it to retain the
        same value from one .fetchmany() call to the next."""

        logger.debug("II executing fetchmany")
        self.__check_executed()

        if self.rownumber >= (self.rowcount):
            return []

        end = self.rownumber + (size or self.arraysize)
        end = min(end, self.rowcount)

        logger.debug("end: %s" % end)

        result = self.__rows[self.rownumber - self.__offset:end - self.__offset]
        self.rownumber = min(end, len(self.__rows) + self.__offset)

        while (end > self.rownumber) and self.nextset():
                result += self.__rows[self.rownumber - self.__offset:end -
                        self.__offset]
                self.rownumber = min(end, len(self.__rows) + self.__offset)
        return result



    def fetchall(self) :
        """Fetch all (remaining) rows of a query result, returning
        them as a sequence of sequences (e.g. a list of tuples).
        Note that the cursor's arraysize attribute can affect the
        performance of this operation.

        An Error (or subclass) exception is raised if the previous
        call to .execute*() did not produce any result set or no
        call was issued yet."""

        self.__check_executed()

        if self.__query_id == -1:
            self.__exception_handler(ProgrammingError,
                    "query didn't result in a resultset")

        result = self.__rows[self.rownumber - self.__offset:]
        self.rownumber = len(self.__rows) + self.__offset

        # slide the window over the resultset
        while self.nextset():
            result += self.__rows
            self.rownumber = len(self.__rows) + self.__offset

        return result



    def nextset(self):
        """This method will make the cursor skip to the next
        available set, discarding any remaining rows from the
        current set.

        If there are no more sets, the method returns
        None. Otherwise, it returns a true value and subsequent
        calls to the fetch methods will return rows from the next
        result set.

        An Error (or subclass) exception is raised if the previous
        call to .execute*() did not produce any result set or no
        call was issued yet."""

        self.__check_executed()

        if self.rownumber >= self.rowcount:
            return False

        logger.debug("retreiving next set")
        self.__offset += len(self.__rows)

        end = min(self.rowcount, self.rownumber + self.arraysize)
        amount = end - self.__offset

        command = 'Xexport %s %s %s' % (self.__query_id,
                self.__offset, amount)
        block = self.connection.command(command)
        self.__store_result(block)
        return True


    def setinputsizes(self, sizes):
        """
        This method would be used before the .execute*() method
        is invoked to reserve memory. This implementation doesn't
        use this.

        """
        pass


    def setoutputsize(self, size, column=None):
        """
        Set a column buffer size for fetches of large columns
        This implementation doesn't use this
        """
        pass


    def __iter__(self):
        return self


    def next(self):
        row = self.fetchone()
        if not row:
            raise StopIteration
        return row


    def __store_result(self, block):
        """ parses the mapi result into a resultset"""

        if not block:
            block = ""

        lines = block.split("\n")
        firstline = lines[0]

        while firstline.startswith(mapi.MSG_INFO):
            logger.info(firstline[1:])
            self.messages.append((Warning, firstline[1:]))
            lines = lines[1:]
            firstline = lines[0]

        if firstline.startswith(mapi.MSG_QTABLE):
            (id, rowcount, columns, tuples) = firstline[2:].split()
            columns = int(columns)   # number of columns in result
            rowcount = int(rowcount) # total number of rows
            tuples = int(tuples)     # number of rows in this set
            rows = []

            # set up fields for description
            table_name = [None]*columns
            column_name = [None]*columns
            type_ = [None]*columns
            display_size = [None]*columns
            internal_size = [None]*columns
            precision = [None]*columns
            scale = [None]*columns
            null_ok = [None]*columns

            typesizes = [(0,0)]*columns

            for line in lines[1:]:
                if line.startswith(mapi.MSG_HEADER):
                    (data, identity) = line[1:].split("#")
                    values = [x.strip() for x in data.split(",")]
                    identity = identity.strip()

                    if identity == "table_name":
                        table_name = values   # not used
                    elif identity == "name":
                        column_name = values
                    elif identity == "type":
                        type_ = values
                    elif identity == "length":
                        pass # not used
                    elif identity == "typesizes":
                        typesizes = [[int(j) for j in i.split()] for i in values]
                        internal_size = [x[0] for x in typesizes]
                        for num, typeelem in enumerate(type_):
                            if typeelem in ['decimal']:
                                precision[num] = typesizes[num][0]
                                scale[num] = typesizes[num][1]
                    else:
                        self.messages.append((InterfaceError,
                            "unknown header field"))
                        self.__exception_handler(InterfaceError,
                                "unknown header field")

                    self.description = list(zip(column_name, type_,
                        display_size, internal_size, precision, scale, null_ok))

                if line.startswith(mapi.MSG_TUPLE):
                    values = self.__parse_tuple(line)
                    rows.append(values)

                elif line == mapi.MSG_PROMPT:
                    self.__query_id = id
                    self.__rows = rows
                    self.__offset = 0

                    self.rowcount = rowcount
                    self.lastrowid = None
                    logger.debug("II store result finished")
                    return

        elif firstline.startswith(mapi.MSG_QBLOCK):
            rows = []
            for line in lines[1:]:
                if line.startswith(mapi.MSG_TUPLE):
                    values = self.__parse_tuple(line)
                    rows.append(values)
                elif line == mapi.MSG_PROMPT:
                    logger.debug("II store result finished")
                    self.__rows = rows
                    return

        elif firstline.startswith(mapi.MSG_QSCHEMA):
           if lines[1] == mapi.MSG_PROMPT:
                self.__rows = []
                self.__offset = 0
                self.description = None
                self.rowcount = -1
                self.lastrowid = None
                logger.debug("II schema finished")
                return

        elif firstline.startswith(mapi.MSG_QUPDATE):
           if lines[1] == mapi.MSG_PROMPT:
                (affected, identity) = firstline[2:].split()
                self.__rows = []
                self.__offset = 0
                self.description = None
                self.rowcount = int(affected)
                self.lastrowid = int(identity)
                self.__query_id = -1
                logger.debug("II update finished")
                return

        elif firstline.startswith(mapi.MSG_ERROR):
            self.__exception_handler(ProgrammingError, firstline[1:])

        elif firstline.startswith(mapi.MSG_QTRANS):
           if lines[1] == mapi.MSG_PROMPT:
                self.__rows = []
                self.__offset = 0
                self.description = None
                self.rowcount = -1
                self.lastrowid = None
                logger.debug("II transaction finished")
                return

        elif firstline.startswith(mapi.MSG_PROMPT):
            self.__query_id = -1
            self.__rows = []
            self.__offset = 0

            self.rowcount = 0
            self.lastrowid = None
            logger.debug("II empty response, assuming everything is ok")
            return

        # you are not supposed to be here
        self.__exception_handler(InterfaceError, "Unknown state, %s" % block)


    def __parse_tuple(self, line):
        """ parses a mapi data tuple, and returns a list of python types"""

        # values in a row are seperated by \t
        elements = line[1:-1].split(',\t')
        if len(elements) == len(self.description):
            return tuple([pythonize.convert(element.strip(),
                description[1]) for (element, description) in
                zip(elements, self.description)])
        else:
            self.__exception_handler(InterfaceError,
                    "length of row doesn't match header")


    def scroll(self, value, mode='relative'):
        """Scroll the cursor in the result set to a new position according
        to mode.

        If mode is 'relative' (default), value is taken as offset to
        the current position in the result set, if set to 'absolute',
        value states an absolute target position.

        An IndexError is raised in case a scroll operation would
        leave the result set.
        """
        self.__check_executed()

        if mode not in ['relative', 'absolute']:
            self.__exception_handler(ProgrammingError,
                    "unknown mode '%s'" % mode)

        if mode == 'relative':
            value = self.rownumber + value

        if value > self.rowcount:
             self.__exception_handler(IndexError,
                     "value beyond length of resultset")

        self.__offset = value
        end = min(self.rowcount, self.rownumber + self.arraysize)
        amount = end - self.__offset
        command = 'Xexport %s %s %s' % (self.__query_id,
                self.__offset, amount)
        block = self.connection.command(command)
        self.__store_result(block)


    def __exception_handler(self, exception_class, message):
        """ raises the exception specified by exception, and add the error
        to the message list """
        self.messages.append((exception_class, message))
        raise exception_class(message)




