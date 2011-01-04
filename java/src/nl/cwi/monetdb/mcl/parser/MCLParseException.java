/*
 * The contents of this file are subject to the MonetDB Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://monetdb.cwi.nl/Legal/MonetDBLicense-1.1.html
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * The Original Code is the MonetDB Database System.
 *
 * The Initial Developer of the Original Code is CWI.
 * Portions created by CWI are Copyright (C) 1997-July 2008 CWI.
 * Copyright August 2008-2011 MonetDB B.V.
 * All Rights Reserved.
 */

package nl.cwi.monetdb.mcl.parser;

import java.text.*;

/**
 * When an MCLParseException is thrown, the MCL protocol is violated by
 * the sender.  In general a stream reader throws an
 * MCLParseException as soon as something that is read cannot be
 * understood or does not conform to the specifications (e.g. a
 * missing field).  The instance that throws the exception will try to
 * give an error offset whenever possible.  Alternatively it makes sure
 * that the error message includes the offending data read.
 */
public class MCLParseException extends ParseException {
	public MCLParseException(String e) {
		super(e, -1);
	}

	public MCLParseException(String e, int offset) {
		super(e, offset);
	}
}
