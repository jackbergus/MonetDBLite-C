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
 * Portions created by CWI are Copyright (C) 1997-2006 CWI.
 * All Rights Reserved.
 */

package nl.cwi.monetdb.jdbc;

import java.sql.*;
import java.util.*;
import java.io.*;
import java.nio.*;

/**
 * A Connection suitable for the MonetDB database.
 * <br /><br />
 * This connection represents a connection (session) to a MonetDB
 * database. SQL statements are executed and results are returned within
 * the context of a connection. This Connection object holds a physical
 * connection to the MonetDB database.
 * <br /><br />
 * A Connection object's database should able to provide information
 * describing its tables, its supported SQL grammar, its stored
 * procedures, the capabilities of this connection, and so on. This
 * information is obtained with the getMetaData method.<br />
 * Note: By default a Connection object is in auto-commit mode, which
 * means that it automatically commits changes after executing each
 * statement. If auto-commit mode has been disabled, the method commit
 * must be called explicitly in order to commit changes; otherwise,
 * database changes will not be saved.
 * <br /><br />
 * The current state of this connection is that it nearly implements the
 * whole Connection interface.<br />
 *
 * @author Fabian Groffen <Fabian.Groffen@cwi.nl>
 * @version 0.9.2
 */
public class MonetConnection implements Connection {
	/** The hostname to connect to */
	private final String hostname;
	/** The port to connect on the host to */
	private final int port;
	/** The database to use (currently not used) */
	private final String database;
	/** The username to use when authenticating */
	private final String username;
	/** The password to use when authenticating */
	private final String password;
	/** The language which is used */
	private final int lang;
	/** Whether to use server-side (native) or Java emulated
	 * PreparedStatements */
	private final boolean nativePreparedStatements;
	/** A connection to Mserver using a TCP socket */
	private final MonetSocketBlockMode monet;

	/** Whether this Connection is closed (and cannot be used anymore) */
	private boolean closed;

	/** Whether this Connection is in autocommit mode */
	private boolean autoCommit = true;

	/** The stack of warnings for this Connection object */
	private SQLWarning warnings = null;
	/** The Connection specific mapping of user defined types to Java
	 * types (not used) */
	private Map typeMap = new HashMap();

	// See javadoc for documentation about WeakHashMap if you don't know what
	// it does !!!NOW!!! (only when you deal with it of course)
	/** A Map containing all (active) Statements created from this Connection */
	private Map statements = new WeakHashMap();

	/** The number of results we receive from the server at once */
	private int curReplySize = -1;	// the server by default uses -1 (all)

	/** A template to apply to each query (like pre and post fixes) */
	String[] queryTempl;
	/** A template to apply to each command (like pre and post fixes) */
	String[] commandTempl;

	/** the SQL language */
	final static int LANG_SQL = 0;
	/** the XQuery language */
	final static int LANG_XQUERY = 1;
	/** the MIL language (officially *NOT* supported) */
	final static int LANG_MIL = 2;
	/** an unknown language */
	final static int LANG_UNKNOWN = -1;

	/** Query types (copied from sql_query.mx) */
	final static int Q_PARSE	= '0';
	final static int Q_TABLE	= '1';
	final static int Q_UPDATE	= '2';
	final static int Q_SCHEMA	= '3';
	final static int Q_TRANS	= '4';
	final static int Q_PREPARE	= '5';
	final static int Q_BLOCK	= '6';

	/**
	 * Constructor of a Connection for MonetDB. At this moment the
	 * current implementation limits itself to storing the given host,
	 * database, username and password for later use by the
	 * createStatement() call.  This constructor is only accessible to
	 * classes from the jdbc package.
	 *
	 * @param props a Property hashtable holding the properties needed for
	 *              connecting
	 * @throws SQLException if a database error occurs
	 * @throws IllegalArgumentException is one of the arguments is null or empty
	 */
	MonetConnection(
		Properties props)
		throws SQLException, IllegalArgumentException
	{
		this.hostname = props.getProperty("host");
		int port;
		try {
			port = Integer.parseInt(props.getProperty("port"));
		} catch (NumberFormatException e) {
			port = 0;
		}
		this.port = port;
		this.database = props.getProperty("database");
		this.username = props.getProperty("user");
		this.password = props.getProperty("password");
		boolean natPrepStIsSet =
			props.getProperty("native_prepared_statements") == null;
		if (!natPrepStIsSet) {
			this.nativePreparedStatements = Boolean.valueOf(props.getProperty("native_prepared_statements")).booleanValue();
		} else {
			this.nativePreparedStatements = true;
		}

		String language = props.getProperty("language");
		boolean blockMode = Boolean.valueOf(props.getProperty("blockmode")).booleanValue();
		boolean debug = Boolean.valueOf(props.getProperty("debug")).booleanValue();

		// check input arguments
		if (hostname == null || hostname.trim().equals(""))
			throw new IllegalArgumentException("hostname should not be null or empty");
		if (port == 0)
			throw new IllegalArgumentException("port should not be 0");
		if (database == null || database.trim().equals(""))
			throw new IllegalArgumentException("database should not be null or empty");
		if (username == null || username.trim().equals(""))
			throw new IllegalArgumentException("user should not be null or empty");
		if (password == null || password.trim().equals(""))
			throw new IllegalArgumentException("password should not be null or empty");
		if (language == null || language.trim().equals("")) {
			language = "sql";
			addWarning("No language given, defaulting to 'sql'");
		}

		// initialise query templates (filled later, but needed below)
		queryTempl = new String[3]; // pre, post, sep
		commandTempl = new String[3]; // pre, post, sep

		try {
			monet = new MonetSocketBlockMode(hostname, port);

			/*
			 * There is no need for a lock on the monet object here.
			 * Since we just created the object, and the reference to
			 * this object has not yet been returned to the caller,
			 * noone can (in a legal way) know about the object.
			 */

			// we're debugging here... uhm, should be off in real life
			if (debug) {
				String fname = props.getProperty("logfile", "monet_" +
					System.currentTimeMillis() + ".log");
				File f = new File(fname);
				int ext = fname.lastIndexOf(".");
				if (ext < 0) ext = fname.length();
				String pre = fname.substring(0, ext);
				String suf = fname.substring(ext);

				for (int i = 1; f.exists(); i++) {
					f = new File(pre + "-" + i + suf);
				}

				monet.debug(f.getAbsolutePath());
			}

			// log in
			String challenge = null;

			// read the challenge from the server
			byte[] chal = new byte[2];
			monet.read(chal);
			int len = 0;
			try {
				len = Integer.parseInt(new String(chal, "UTF-8"));
			} catch (NumberFormatException e) {
				throw new SQLException("Server challenge length unparsable " +
						"(" + new String(chal, "UTF-8") + ")");
			}
			// read the challenge string
			chal = new byte[len];
			monet.read(chal);

			challenge = new String(chal, "UTF-8");

			// mind the newline at the end
			monet.write(getChallengeResponse(
						challenge,
						username,
						password,
						language,
						true,
						database
						) + "\n");

			// We need to send the server our byte order.  Java by
			// itself uses network order.
			// A short with value 1234 will be sent to indicate our
			// byte-order.
			/*
			short x = 1234;
			byte high = (byte)(x >>> 8);	// = 0x04
			byte low = (byte)x;				// = 0xD2
			*/
			final byte[] bigEndian = {(byte)0x04, (byte)0xD2};
			monet.write(bigEndian);
			monet.flush();

			// now read the byte-order of the server
			byte[] byteorder = new byte[2];
			if (monet.read(byteorder) != 2)
				throw new SQLException("The server sent an incomplete byte-order sequence");
			if (byteorder[0] == (byte)0x04) {
				// set our connection to big-endian mode
				monet.setByteOrder(ByteOrder.BIG_ENDIAN);
			} else if (byteorder[0] == (byte)0xD2) {
				// set our connection to litte-endian mode
				monet.setByteOrder(ByteOrder.LITTLE_ENDIAN);
			}

			// read monet response till prompt
			String err;
			if ((err = monet.waitForPrompt()) != null) {
				monet.disconnect();
				throw new SQLException(err);
			}

			// we seem to have managed to log in, let's store the
			// language used
			if ("sql".equals(language)) {
				lang = LANG_SQL;
			} else if ("xquery".equals(language)) {
				lang = LANG_XQUERY;
			} else if ("mil".equals(language)) {
				lang = LANG_MIL;
			} else {
				lang = LANG_UNKNOWN;
			}
			
			// we're ready for commands!
		} catch (IOException e) {
			throw new SQLException("Unable to connect (" + hostname + ":" + port + "): " + e.getMessage());
		}

		// fill the query templates
		if (lang == LANG_SQL) {
			queryTempl[0] = "s";		// pre
			queryTempl[1] = ";";		// post
			queryTempl[2] = ";\n";		// separator

			commandTempl[0] = "X";		// pre
			commandTempl[1] = null;		// post
			commandTempl[2] = "\nX";	// separator
		} else if (lang == LANG_XQUERY) {
			queryTempl[0] = "xml-seq-mapi\n";
			queryTempl[1] = null;
			queryTempl[2] = ",";

			commandTempl[0] = null;		// pre
			commandTempl[1] = null;		// post
			commandTempl[2] = null;		// separator
		} else if (lang == LANG_MIL) {
			queryTempl[0] = null;
			queryTempl[1] = ";";
			queryTempl[2] = ";\n";

			commandTempl[0] = null;		// pre
			commandTempl[1] = null;		// post
			commandTempl[2] = null;		// separator
		}

		// the following initialisers are only valid when the language
		// is SQL...
		if (lang == LANG_SQL) {
			// enable auto commit
			setAutoCommit(true);
			// set our time zone on the server
			Calendar cal = Calendar.getInstance();
			int offset = (cal.get(Calendar.ZONE_OFFSET) + cal.get(Calendar.DST_OFFSET)) / (60 * 1000);
			String tz = offset < 0 ? "-" : "+";
			tz += (Math.abs(offset) / 60 < 10 ? "0" : "") + (Math.abs(offset) / 60) + ":";
			offset -= (offset / 60) * 60;
			tz += (offset < 10 ? "0" : "") + offset;
			sendIndependantCommand("SET TIME ZONE INTERVAL '" + tz + "' HOUR TO MINUTE");
		}

		// we're absolutely not closed, since we're brand new
		closed = false;
	}

	/**
	 * A little helper function that processes a challenge string, and
	 * returns a response string for the server.  If the challenge
	 * string is null, a challengeless response is returned.
	 *
	 * @param chalstr the challenge string
	 * @param username the username to use
	 * @param password the password to use
	 * @param language the language to use
	 * @param blocked whether to use blocked protocol
	 * @param database the database to connect to
	 */
	private String getChallengeResponse(
		String chalstr,
		String username,
		String password,
		String language,
		boolean blocked,
		String database
	) throws SQLException {
		int version = 0;
		String response;
		
		// parse the challenge string, split it on ':'
		String[] chaltok = chalstr.split(":");
		if (chaltok.length != 4) throw
			new SQLException("Server challenge string unusable!");

		// challenge string use as salt/key in future
		String challenge = chaltok[1];
		// chaltok[2]; // server type, not needed yet 
		try {
			version = Integer.parseInt(chaltok[3].trim());	// protocol version
		} catch (NumberFormatException e) {
			throw new SQLException("Protocol version unparseable: " + chaltok[3]);
		}

		/**
		 * do something with the challenge to salt the password hash here!!!
		 */
		response = username + ":" + password + ":" + language;
		if (blocked) {
			response += ":blocked";
		} else if (version >= 5) {
			response += ":line";
		}
		if (version < 5) {
			// don't use database
			addWarning("database specifier not supported on this server (" + chaltok[2].trim() + "), protocol version " + chaltok[3].trim());
		} else {
			response += ":" + database;
		}

		return(response);
	}

	//== methods of interface Connection

	/**
	 * Clears all warnings reported for this Connection object. After a
	 * call to this method, the method getWarnings returns null until a
	 * new warning is reported for this Connection object.
	 */
	public void clearWarnings() {
		warnings = null;
	}

	/**
	 * Releases this Connection object's database and JDBC resources
	 * immediately instead of waiting for them to be automatically
	 * released. All Statements created from this Connection will be
	 * closed when this method is called.
	 * <br /><br />
	 * Calling the method close on a Connection object that is already
	 * closed is a no-op.
	 */
	public void close() {
		Iterator it = statements.keySet().iterator();
		while (it.hasNext()) {
			try {
				((Statement)it.next()).close();
			} catch (SQLException e) {
				// better luck next time!
			}
		}
		// close the socket
		monet.disconnect();
		// report ourselves as closed
		closed = true;
	}

	/**
	 * Makes all changes made since the previous commit/rollback
	 * permanent and releases any database locks currently held by this
	 * Connection object.  This method should be used only when
	 * auto-commit mode has been disabled.
	 *
	 * @throws SQLException if a database access error occurs or this
	 *         Connection object is in auto-commit mode
	 * @see #setAutoCommit(boolean)
	 */
	public void commit() throws SQLException {
		// send commit to the server
		sendIndependantCommand("COMMIT");
	}

	/**
	 * Creates a Statement object for sending SQL statements to the
	 * database.  SQL statements without parameters are normally
	 * executed using Statement objects. If the same SQL statement is
	 * executed many times, it may be more efficient to use a
	 * PreparedStatement object.
	 * <br /><br />
	 * Result sets created using the returned Statement object will by
	 * default be type TYPE_FORWARD_ONLY and have a concurrency level of
	 * CONCUR_READ_ONLY.
	 *
	 * @return a new default Statement object
	 * @throws SQLException if a database access error occurs
	 */
	public Statement createStatement() throws SQLException {
		return(createStatement(
					ResultSet.TYPE_FORWARD_ONLY,
					ResultSet.CONCUR_READ_ONLY));
	}

	/**
	 * Creates a Statement object that will generate ResultSet objects
	 * with the given type and concurrency. This method is the same as
	 * the createStatement method above, but it allows the default
	 * result set type and concurrency to be overridden.
	 *
	 * @param resultSetType a result set type; one of
	 *        ResultSet.TYPE_FORWARD_ONLY, ResultSet.TYPE_SCROLL_INSENSITIVE,
	 *        or ResultSet.TYPE_SCROLL_SENSITIVE
	 * @param resultSetConcurrency a concurrency type; one of
	 *        ResultSet.CONCUR_READ_ONLY or ResultSet.CONCUR_UPDATABLE
	 * @return a new Statement object that will generate ResultSet objects with
	 *         the given type and concurrency
	 * @throws SQLException if a database access error occurs
	 */
	public Statement createStatement(
		int resultSetType,
		int resultSetConcurrency)
		throws SQLException
	{
		try {
			Statement ret =
				new MonetStatement(
					this, resultSetType, resultSetConcurrency
				);
			// store it in the map for when we close...
			statements.put(ret, null);
			return(ret);
		} catch (IllegalArgumentException e) {
			throw new SQLException(e.toString());
		}
		// we don't have to catch SQLException because that is declared to
		// be thrown
	}

	public Statement createStatement(int resultSetType, int resultSetConcurrency, int resultSetHoldability) {return(null);}

	/**
	 * Retrieves the current auto-commit mode for this Connection
	 * object.
	 *
	 * @return the current state of this Connection object's auto-commit
	 *         mode
	 * @see #setAutoCommit(boolean)
	 */
	public boolean getAutoCommit() throws SQLException {
		return(autoCommit);
	}

	/**
	 * Retrieves this Connection object's current catalog name.
	 *
	 * @return the current catalog name or null if there is none
	 * @throws SQLException if a database access error occurs or the
	 *         current language is not SQL
	 */
	public String getCatalog() throws SQLException {
		if (lang != LANG_SQL)
			throw new SQLException("This method is only supported in SQL mode");

		// this is a dirty hack, but it works as long as MonetDB
		// only handles one catalog (dbfarm) at a time
		ResultSet rs = getMetaData().getCatalogs();
		if (rs.next()) {
			String ret = rs.getString(1);
			rs.close();
			return(ret);
		} else {
			return(null);
		}
	}
	
	public int getHoldability() {return(-1);}

	/**
	 * Retrieves a DatabaseMetaData object that contains metadata about
	 * the database to which this Connection object represents a
	 * connection. The metadata includes information about the
	 * database's tables, its supported SQL grammar, its stored
	 * procedures, the capabilities of this connection, and so on.
	 *
	 * @throws SQLException if the current language is not SQL
	 * @return a DatabaseMetaData object for this Connection object
	 */
	public DatabaseMetaData getMetaData() throws SQLException {
		if (lang != LANG_SQL)
			throw new SQLException("This method is only supported in SQL mode");

		return(new MonetDatabaseMetaData(this));
	}

	/**
	 * Retrieves this Connection object's current transaction isolation
	 * level.
	 *
	 * @return the current transaction isolation level, which will be
	 *         Connection.TRANSACTION_SERIALIZABLE
	 */
	public int getTransactionIsolation() {
		return(TRANSACTION_SERIALIZABLE);
	}

	/**
	 * Retrieves the Map object associated with this Connection object.
	 * Unless the application has added an entry, the type map returned
	 * will be empty.
	 *
	 * @return the java.util.Map object associated with this Connection
	 *         object
	 */
	public Map getTypeMap() {
		return(typeMap);
	}

	/**
	 * Retrieves the first warning reported by calls on this Connection
	 * object.  If there is more than one warning, subsequent warnings
	 * will be chained to the first one and can be retrieved by calling
	 * the method SQLWarning.getNextWarning on the warning that was
	 * retrieved previously.
	 * <br /><br />
	 * This method may not be called on a closed connection; doing so
	 * will cause an SQLException to be thrown.
	 * <br /><br />
	 * Note: Subsequent warnings will be chained to this SQLWarning.
	 *
	 * @return the first SQLWarning object or null if there are none
	 * @throws SQLException if a database access error occurs or this method is
	 *         called on a closed connection
	 */
	public SQLWarning getWarnings() throws SQLException {
		if (closed) throw new SQLException("Cannot call on closed Connection");

		// if there are no warnings, this will be null, which fits with the
		// specification.
		return(warnings);
	}

	/**
	 * Retrieves whether this Connection object has been closed.  A
	 * connection is closed if the method close has been called on it or
	 * if certain fatal errors have occurred.  This method is guaranteed
	 * to return true only when it is called after the method
	 * Connection.close has been called.
	 * <br /><br />
	 * This method generally cannot be called to determine whether a
	 * connection to a database is valid or invalid.  A typical client
	 * can determine that a connection is invalid by catching any
	 * exceptions that might be thrown when an operation is attempted.
	 *
	 * @return true if this Connection object is closed; false if it is
	 *         still open
	 */
	public boolean isClosed() {
		return(closed);
	}

	/**
	 * Retrieves whether this Connection object is in read-only mode.
	 * MonetDB currently doesn't support updateable result sets.
	 *
	 * @return true if this Connection object is read-only; false otherwise
	 */
	public boolean isReadOnly() {
		return(true);
	}

	public String nativeSQL(String sql) {return(sql);}
	public CallableStatement prepareCall(String sql) {return(null);}
	public CallableStatement prepareCall(String sql, int resultSetType, int resultSetConcurrency) {return(null);}
	public CallableStatement prepareCall(String sql, int resultSetType, int resultSetConcurrency, int resultSetHoldability) {return(null);}

	/**
	 * Creates a PreparedStatement object for sending parameterized SQL
	 * statements to the database.
	 * <br /><br />
	 * A SQL statement with or without IN parameters can be pre-compiled
	 * and stored in a PreparedStatement object. This object can then be
	 * used to efficiently execute this statement multiple times.
	 * <br /><br />
	 * Note: This method is optimized for handling parametric SQL
	 * statements that benefit from precompilation. If the driver
	 * supports precompilation, the method prepareStatement will send
	 * the statement to the database for precompilation. Some drivers
	 * may not support precompilation. In this case, the statement may
	 * not be sent to the database until the PreparedStatement object is
	 * executed. This has no direct effect on users; however, it does
	 * affect which methods throw certain SQLException objects.
	 * <br /><br />
	 * Result sets created using the returned PreparedStatement object
	 * will by default be type TYPE_FORWARD_ONLY and have a concurrency
	 * level of CONCUR_READ_ONLY.
	 *
	 * @param sql an SQL statement that may contain one or more '?' IN
	 *        parameter placeholders
	 * @return a new default PreparedStatement object containing the
	 *         pre-compiled SQL statement
	 * @throws SQLException if a database access error occurs
	 */
	public PreparedStatement prepareStatement(String sql) throws SQLException {
		return(
			prepareStatement(
					sql,
					ResultSet.TYPE_FORWARD_ONLY,
					ResultSet.CONCUR_READ_ONLY
			)
		);
	}

	/**
	 * Creates a PreparedStatement object that will generate ResultSet
	 * objects with the given type and concurrency.  This method is the
	 * same as the prepareStatement method above, but it allows the
	 * default result set type and concurrency to be overridden.
	 *
	 * @param sql a String object that is the SQL statement to be sent to the
	 *            database; may contain one or more ? IN parameters
	 * @param resultSetType a result set type; one of
	 *        ResultSet.TYPE_FORWARD_ONLY, ResultSet.TYPE_SCROLL_INSENSITIVE,
	 *        or ResultSet.TYPE_SCROLL_SENSITIVE
	 * @param resultSetConcurrency a concurrency type; one of
	 *        ResultSet.CONCUR_READ_ONLY or ResultSet.CONCUR_UPDATABLE
	 * @return a new PreparedStatement object containing the pre-compiled SQL
	 *         statement that will produce ResultSet objects with the given
	 *         type and concurrency
	 * @throws SQLException if a database access error occurs or the given
	 *                      parameters are not ResultSet constants indicating
	 *                      type and concurrency
	 */
	public PreparedStatement prepareStatement(
		String sql,
		int resultSetType,
		int resultSetConcurrency)
		throws SQLException
	{
		try {
			PreparedStatement ret;
			if (nativePreparedStatements) {
				// use a server-side PreparedStatement
				ret = new MonetPreparedStatement(
					this, resultSetType, resultSetConcurrency, sql
				);
			} else {
				// use a Java implementation of a PreparedStatement
				ret = new MonetPreparedStatementJavaImpl(
					this, resultSetType, resultSetConcurrency, sql
				);
			}
			// store it in the map for when we close...
			statements.put(ret, null);
			return(ret);
		} catch (IllegalArgumentException e) {
			throw new SQLException(e.toString());
		}
		// we don't have to catch SQLException because that is declared to
		// be thrown
	}

	public PreparedStatement prepareStatement(String sql, int autoGeneratedKeys) {return(null);}
	public PreparedStatement prepareStatement(String sql, int[] columnIndexes) {return(null);}
	public PreparedStatement prepareStatement(String sql, int resultSetType, int resultSetConcurrency, int resultSetHoldability) {return(null);}
	public PreparedStatement prepareStatement(String sql, String[] columnNames) {return(null);}

	/**
	 * Removes the given Savepoint object from the current transaction.
	 * Any reference to the savepoint after it have been removed will
	 * cause an SQLException to be thrown.
	 *
	 * @param savepoint the Savepoint object to be removed
	 * @throws SQLException if a database access error occurs or the given
	 *         Savepoint object is not a valid savepoint in the current
	 *         transaction
	 */
	public void releaseSavepoint(Savepoint savepoint) throws SQLException {
		if (!(savepoint instanceof MonetSavepoint)) throw
			new SQLException("This driver can only handle savepoints it created itself");

		MonetSavepoint sp = (MonetSavepoint)savepoint;

		// send the appropriate query string to the database
		sendIndependantCommand("RELEASE SAVEPOINT " + sp.getName());
	}

	/**
	 * Undoes all changes made in the current transaction and releases
	 * any database locks currently held by this Connection object. This
	 * method should be used only when auto-commit mode has been
	 * disabled.
	 *
	 * @throws SQLException if a database access error occurs or this
	 *         Connection object is in auto-commit mode
	 * @see #setAutoCommit(boolean)
	 */
	public void rollback() throws SQLException {
		// send rollback to the server
		sendIndependantCommand("ROLLBACK");
	}

	/**
	 * Undoes all changes made after the given Savepoint object was set.
	 * <br /><br />
	 * This method should be used only when auto-commit has been
	 * disabled.
	 *
	 * @param savepoint the Savepoint object to roll back to
	 * @throws SQLException if a database access error occurs, the
	 *         Savepoint object is no longer valid, or this Connection
	 *         object is currently in auto-commit mode
	 */
	public void rollback(Savepoint savepoint) throws SQLException {
		if (!(savepoint instanceof MonetSavepoint)) throw
			new SQLException("This driver can only handle savepoints it created itself");

		MonetSavepoint sp = (MonetSavepoint)savepoint;

		// send the appropriate query string to the database
		sendIndependantCommand("ROLLBACK TO SAVEPOINT " + sp.getName());
	}

	/**
	 * Sets this connection's auto-commit mode to the given state. If a
	 * connection is in auto-commit mode, then all its SQL statements
	 * will be executed and committed as individual transactions.
	 * Otherwise, its SQL statements are grouped into transactions that
	 * are terminated by a call to either the method commit or the
	 * method rollback. By default, new connections are in auto-commit
	 * mode.
	 * <br /><br />
	 * The commit occurs when the statement completes or the next
	 * execute occurs, whichever comes first. In the case of statements
	 * returning a ResultSet object, the statement completes when the
	 * last row of the ResultSet object has been retrieved or the
	 * ResultSet object has been closed. In advanced cases, a single
	 * statement may return multiple results as well as output parameter
	 * values. In these cases, the commit occurs when all results and
	 * output parameter values have been retrieved.
	 * <br /><br />
	 * NOTE: If this method is called during a transaction, the
	 * transaction is committed.
	 *
 	 * @param autoCommit true to enable auto-commit mode; false to disable it
	 * @throws SQLException if a database access error occurs
	 * @see #getAutoCommit()
	 */
	public void setAutoCommit(boolean autoCommit) throws SQLException {
		if (this.autoCommit != autoCommit) {
			fetchBlock(new RawResults(
					0,
					"auto_commit " + (autoCommit ? "1" : "0"),
					true
				)
			);
			this.autoCommit = autoCommit;
		}
	}

	public void setCatalog(String catalog) {}
	public void setHoldability(int holdability) {}
	public void setReadOnly(boolean readOnly) {}

	/**
	 * Creates an unnamed savepoint in the current transaction and
	 * returns the new Savepoint object that represents it.
	 *
	 * @return the new Savepoint object
	 * @throws SQLException if a database access error occurs or this Connection
	 *         object is currently in auto-commit mode
	 */
	public Savepoint setSavepoint() throws SQLException {
		// create a new Savepoint object
		MonetSavepoint sp = new MonetSavepoint();
		// send the appropriate query string to the database
		sendIndependantCommand("SAVEPOINT " + sp.getName());

		return(sp);
	}

	/**
	 * Creates a savepoint with the given name in the current
	 * transaction and returns the new Savepoint object that represents
	 * it.
	 *
	 * @param name a String containing the name of the savepoint
	 * @return the new Savepoint object
	 * @throws SQLException if a database access error occurs or this Connection
	 *         object is currently in auto-commit mode
	 */
	public Savepoint setSavepoint(String name) throws SQLException {
		// create a new Savepoint object
		MonetSavepoint sp;
		try {
			sp = new MonetSavepoint(name);
		} catch (IllegalArgumentException e) {
			throw new SQLException(e.getMessage());
		}
		// send the appropriate query string to the database
		sendIndependantCommand("SAVEPOINT " + sp.getName());

		return(sp);
	}

	/**
	 * Attempts to change the transaction isolation level for this
	 * Connection object to the one given. The constants defined in the
	 * interface Connection are the possible transaction isolation
	 * levels.
	 *
	 * @param level one of the following Connection constants:
	 *        Connection.TRANSACTION_READ_UNCOMMITTED,
	 *        Connection.TRANSACTION_READ_COMMITTED,
	 *        Connection.TRANSACTION_REPEATABLE_READ, or
	 *        Connection.TRANSACTION_SERIALIZABLE.
	 */
	public void setTransactionIsolation(int level) {
		if (level != TRANSACTION_SERIALIZABLE) {
			addWarning("MonetDB only supports fully serializable " +
					"transactions, continuing with transaction level " +
					"raised to TRANSACTION_SERIALIZABLE");
		}
	}

	/**
	 * Installs the given TypeMap object as the type map for this
	 * Connection object. The type map will be used for the custom
	 * mapping of SQL structured types and distinct types.
	 *
	 * @param map the java.util.Map object to install as the replacement for
	 *        this Connection  object's default type map
	 */
	public void setTypeMap(Map map) {
		typeMap = map;
	}

	//== end methods of interface Connection

	/**
	 * Sends the given string to MonetDB, making sure there is a prompt
	 * before and after the command has sent. All possible returned
	 * information is discarded.
	 *
	 * @param command the exact string to send to MonetDB
	 * @throws SQLException if an IO exception or a database error occurs
	 */
	void sendIndependantCommand(String command) throws SQLException {
		HeaderList hdrl =
			new HeaderList(command, 0, 0, 0, 0);
		processQuery(hdrl);

		while (hdrl.getNextHeader() != null);
	}

	/**
	 * Adds a warning to the pile of warnings this Connection object
	 * has.  If there were no warnings (or clearWarnings was called)
	 * this warning will be the first, otherwise this warning will get
	 * appended to the current warning.
	 *
	 * @param reason the warning message
	 */
	private void addWarning(String reason) {
		if (warnings == null) {
			warnings = new SQLWarning(reason);
		} else {
			warnings.setNextWarning(new SQLWarning(reason));
		}
	}


	/** the default number of rows that are (attempted to) read at once */
	private final static int DEF_FETCHSIZE = 250;
	/** The sequence counter */
	private static int seqCounter = 0;

	/** An optional thread that is used for sending large queries */
	private SendThread sendThread = null;

	/**
	 * Adds a new query result block request to the queue of queries that
	 * can and should be executed.  A RawResults object is returned which
	 * will be filled as soon as the query request is processed.
	 *
	 * @param hdr the Header this query block is part of
	 * @param block the block number to fetch, index starts at 0
	 * @return a RawResults object which will get filled as soon as the
	 *         query is processed
	 * @throws IllegalStateException if this thread is not alive
	 * @see RawResults
	 */
	RawResults addBlock(ResultSetHeader hdr, int block) throws IllegalStateException {
		RawResults rawr;
		int cacheSize = hdr.getCacheSize();
		// get number of results to fetch
		int size = Math.min(cacheSize, hdr.tuplecount - ((block * cacheSize) + hdr.getBlockOffset()));

		if (size == 0) throw
			new IllegalStateException("Should not fetch empty block!");

		rawr = new RawResults(size,
				"export " + hdr.id + " " +
				((block * cacheSize) + hdr.getBlockOffset()) + " " +
				size, hdr.getRSType() == ResultSet.TYPE_FORWARD_ONLY);

		fetchBlock(rawr);

		return(rawr);
	}

	/**
	 * Adds a result set close command to the head of the queue of queries
	 * that can and should be executed.  Close requests are given maximum
	 * priority because it are small quick terminating queries and release
	 * resources on the server backend.
	 *
	 * @param id the table id of the result set to close
	 * @throws IllegalStateException if this thread is not alive
	 */
	void closeResult(int id) throws IllegalStateException {
		fetchBlock(new RawResults(0, "close " + id, true));
	}

	/**
	 * Executes the query contained in the given HeaderList, and stores the
	 * Headers resulting from this query in the HeaderList.
	 * There is no need for an exclusive lock on the monet object here.
	 * Since there is a queue system, queries are executed only by on
	 * specialised thread.  The monet object is not accessible for any
	 * other object (ok, not entirely true) so this specialised thread
	 * is the only one accessing it.
	 *
	 * @param hdrl a HeaderList which contains the query to execute
	 */
	void processQuery(HeaderList hdrl) {
		boolean sendThreadInUse = false;
		
		try {
			// make sure we're ready to send query; read data till we
			// have the prompt it is possible (and most likely) that we
			// already have the prompt and do not have to skip any
			// lines.  Ignore errors from previous result sets.
			monet.waitForPrompt();

			int size;
			// {{{ set reply size
			try {
				/**
				 * Change the reply size of the server.  If the given
				 * value is the same as the current value known to use,
				 * then ignore this call.  If it is set to 0 we get a
				 * prompt after the server sent it's header.
				 */
				size = hdrl.cachesize == 0 ? DEF_FETCHSIZE : hdrl.cachesize;
				size = hdrl.maxrows != 0 ? Math.min(hdrl.maxrows, size) : size;
				// don't do work if it's not needed
				if (lang == LANG_SQL && size != 0 && size != curReplySize) {
					monet.writeLine(queryTempl, "SET reply_size = " + size);

					String error = monet.waitForPrompt();
					if (error != null) throw new SQLException(error);
					
					// store the reply size after a successful change
					curReplySize = size;
				}
			} catch (SQLException e) {
				hdrl.addError(e.getMessage());
				hdrl.setComplete();
				return;
			}
			// }}} set reply size

			// If the query is larger than the TCP buffer size, use a
			// special send thread to avoid deadlock with the server due
			// to blocking behaviour when the buffer is full.  Because
			// the server will be writing back results to us, it will
			// eventually block as well when its TCP buffer gets full,
			// as we are blocking an not consuming from it.  The result
			// is a state where both client and server want to write,
			// but block.
			if (hdrl.query().length() > MonetSocketBlockMode.BLOCK) {
				// get a reference to the send thread
				if (sendThread == null) sendThread = new SendThread(monet);
				// tell it to do some work!
				sendThread.runQuery(hdrl);
				sendThreadInUse = true;
			} else {
				// this is a simple call, which is a lot cheaper and will
				// always succeed for small queries.
				monet.writeLine(queryTempl, hdrl.query());
			}

			// go for new results
			String tmpLine = monet.readLine();
			int linetype = monet.getLineType();
			Header hdr = null;
			RawResults rawr = null;
			int lastState = linetype;
			while (linetype != MonetSocketBlockMode.PROMPT1) {
				switch (linetype) {
					case MonetSocketBlockMode.ERROR:
						// store the error message in the HeaderList object
						hdrl.addError(tmpLine.substring(1));
					break;
					case MonetSocketBlockMode.SOHEADER:
						// close previous if set
						if (hdr != null) {
							hdr.complete();
							hdrl.addHeader(hdr);
						}
						if (rawr != null) rawr.finish();

						// {{{ soh line parsing
						// parse the start of header line
						CharBuffer soh = CharBuffer.wrap(tmpLine);
						soh.get();	// skip the &
						try {
							switch (soh.get()) {
								default:
									throw new java.text.ParseException("Unknown header", 1);
								case Q_PARSE:
									throw new java.text.ParseException("Q_PARSE header not allowed here", 1);
								case Q_TABLE:
								case Q_PREPARE:
									soh.get();	// skip space
									hdr = new ResultSetHeader(
											parseNumber(soh),	// id
											parseNumber(soh),	// tuplecount
											parseNumber(soh),	// columncount
											parseNumber(soh),	// rowcount
											this,
											hdrl.cachesize,
											hdrl.rstype,
											hdrl.rsconcur,
											hdrl.seqnr
											);
									break;
								case Q_UPDATE:
									soh.get();	// skip space
									hdr = new AffectedRowsHeader(
											parseNumber(soh)	// count
											);
									break;
								case Q_SCHEMA:
									hdr = new AffectedRowsHeader(
											Statement.SUCCESS_NO_INFO
											);
									break;
								case Q_TRANS:
									soh.get();	// skip space
									if (soh.position() == soh.length()) throw
										new java.text.ParseException("unexpected end of string", soh.position() - 1);
									boolean ac = soh.get() == 't' ? true : false;
									if (autoCommit && ac) {
										addWarning("Server enabled auto commit " +
												"mode while local state " +
												"already is auto commit."
												);
									}
									autoCommit = ac;
									// note: the use of a special header
									// here is not really clear.  Maybe
									// ditch it and use AffectedRowsHeader
									// (which is a superclass of
									// AutoCommitHeader anyway).
									hdr = new AutoCommitHeader(
											ac
											);
									break;
							}
						} catch (java.text.ParseException e) {
							throw new SQLException(e.getMessage() +
									" found: '" + soh.get(e.getErrorOffset()) + "'" +
									" in: \"" + tmpLine + "\"" +
									" at pos: " + e.getErrorOffset());
						}
						// }}} soh line parsing

						rawr = null;
					break;
					case MonetSocketBlockMode.HEADER:
						if (hdr == null) throw
							new SQLException("Protocol violation: header sent before start of header was issued!");
						hdr.addHeader(tmpLine);
					break;
					case MonetSocketBlockMode.RESULT:
						// complete the header info and add to list
						if (lastState == MonetSocketBlockMode.HEADER) {
							// we can only have a ResultSetHeader here
							ResultSetHeader rsh = (ResultSetHeader)hdr;
							rsh.complete();
							rawr = new RawResults(size != 0 ? Math.min(size, rsh.tuplecount) : rsh.tuplecount, null, rsh.getRSType() == ResultSet.TYPE_FORWARD_ONLY);
							rsh.addRawResults(0, rawr);
							// a RawResults must be in hdr at this point!!!
							hdrl.addHeader(hdr);
							hdr = null;
						}
						if (rawr == null) throw
							new SQLException("Protocol violation: result sent before header!");
						rawr.addRow(tmpLine);
					break;
					default:
						// unknown, will mean a protocol violation
						addWarning("Protocol violation: unknown linetype.  Ignoring line: " + tmpLine);
					break;
				}
				lastState = linetype;
				tmpLine = monet.readLine();
				linetype = monet.getLineType();
			}
			// Tell the RawResults object there is nothing going to be
			// added right now.  We need to do this because MonetDB
			// sometimes plays games with us and just doesn't send what
			// it promises.
			if (rawr != null) rawr.finish();
			// catch resultless headers
			if (hdr != null) {
				hdr.complete();
				hdrl.addHeader(hdr);
			}
			// if we used the sendThread, make sure it has finished
			if (sendThreadInUse) sendThread.throwErrors();
		} catch (SQLException e) {
			hdrl.addError(e.getMessage());
			// if MonetDB sent us an incomplete or malformed header, we have
			// big problems, thus discard the whole bunch and quit processing
			// this one
			try {
				monet.waitForPrompt();
			} catch (IOException ioe) {
				hdrl.addError(e.toString());
			}
		} catch (IOException e) {
			closed = true;
			hdrl.addError(e.getMessage() + " (Mserver still alive?)");
		}
		// close the header list, no more headers will follow
		hdrl.setComplete();
	}

	/**
	 * Returns the numeric value in the given CharBuffer.  The value is
	 * considered to end at the end of the CharBuffer or at a space.  If
	 * a non-numeric character is encountered a ParseException is
	 * thrown.
	 *
	 * @param str CharBuffer to read from
	 * @throws java.text.ParseException if no numeric value could be
	 * read
	 */
	private final int parseNumber(CharBuffer str)
		throws java.text.ParseException
	{
		if (!str.hasRemaining()) throw
			new java.text.ParseException("Unexpected end of string", str.position() - 1);
		int tmp = MonetResultSet.getIntrinsicValue(str.get(), str.position() - 1);
		char chr;
		while (str.hasRemaining() && (chr = str.get()) != ' ') {
			tmp *= 10;
			tmp += MonetResultSet.getIntrinsicValue(chr, str.position() - 1);
		}

		return(tmp);
	}

	/**
	 * Retrieves a continuation block of a previously (partly) fetched
	 * result.  The data is stored in the given RawResults which also
	 * holds the Xeport query to issue on the server.
	 *
	 * @param rawr a RawResults containing the Xexport to execute
	 */
	private void fetchBlock(RawResults rawr) {
		synchronized (monet) {
			try {
				// make sure we're ready to send query; read data till
				// we have the prompt it is possible (and most likely)
				// that we already have the prompt and do not have to
				// skip any lines. Ignore errors from previous result
				// sets.
				monet.waitForPrompt();

				// send the query
				monet.writeLine(commandTempl, rawr.getXexport());

				// go for new results, everything should be result (or
				// error :( )
				String tmpLine;
				int linetype;
				do {
					tmpLine = monet.readLine();
					linetype = monet.getLineType();
					switch (linetype) {
						case MonetSocketBlockMode.SOHEADER:
						case MonetSocketBlockMode.PROMPT1:
							// we don't care actually right now
						break;
						case MonetSocketBlockMode.RESULT:
							rawr.addRow(tmpLine);
						break;
						case MonetSocketBlockMode.ERROR:
							rawr.addError(tmpLine.substring(1));
						break;
						default:
							rawr.addError("Unexpected line found: " + tmpLine);
						break;
					}
				} while (linetype != MonetSocketBlockMode.PROMPT1);
				// Tell the RawResults object there is nothing going to be
				// added right now.  We need to do this because MonetDB
				// sometimes plays games with us and just doesn't send what
				// it promises.
				rawr.finish();
			} catch (IOException e) {
				closed = true;
				rawr.addError("Unexpected end of stream, Mserver still alive? " + e.toString());
			}
		}
	}


	/**
	 * Inner class which holds the raw data as read from the server, and
	 * the associated header information, in a parsed manor, ready for easy
	 * retrieval.
	 * <br /><br />
	 * This object is not intended to be queried by multiple threads
	 * synchronously. It is designed to work for one thread retrieving rows
	 * from it. When multiple threads will retrieve rows from this object, it
	 * is likely for some threads to get locked forever.
	 */
	class RawResults {
		/** The String array to keep the data in */
		private String[] data;
		/** The Xexport query that results in this block */
		private String export;

		/** The counter which keeps the current position in the data array */
		private int pos;
		/** The line to watch for and notify upon when added */
		private int watch;
		/** The errors generated for this ResultBlock */
		private String error;
		/** Whether we can discard lines as soon as we have read them */
		private boolean forwardOnly;

		/**
		 * Constructs a RawResults object
		 * @param size the size of the data array to create
		 * @param export the Xexport query
		 * @param forward whether this is a forward only result
		 */
		RawResults(int size, String export, boolean forward) {
			pos = -1;
			data = new String[size];
			// a newly set watch will always be smaller than size
			watch = data.length;
			this.export = export;
			this.forwardOnly = forward;
			error = "";
		}


		/**
		 * addRow adds a String of data to this object's data array.
		 * Note that an IndexOutOfBoundsException can be thrown when an
		 * attempt is made to add more than the original construction size
		 * specified.
		 *
		 * @param line the String of data to add
		 */
		synchronized void addRow(String line) {
			data[++pos] = line;
		}

		/**
		 * finish marks this RawResult as complete.  In most cases this
		 * is a redundant operation because the data array is full.
		 * However... it can happen that this is NOT the case!
		 */
		void finish() {
			if ((pos + 1) != data.length) {
				addError("Inconsistent state detected!  Current block capacity: " + data.length + ", block usage: " + (pos + 1) + ".  Did MonetDB send what it promised to?");
			}
		}

		/**
		 * Retrieves the required row. If the row is not present, this method
		 * blocks until the row is available. <br />
		 *
		 * @param line the row to retrieve
		 * @return the requested row as String
		 * @throws IllegalArgumentException if the row to watch for is not
		 *         within the possible range of values (0 - (size - 1))
		 */
		synchronized String getRow(int line)
			throws IllegalArgumentException, SQLException
		{
			if (error != "") throw new SQLException(error);

			if (line >= data.length || line < 0)
				throw new IllegalArgumentException("Row index out of bounds: " + line);

			if (forwardOnly) {
				String ret = data[line];
				data[line] = null;
				return(ret);
			} else {
				return(data[line]);
			}
		}

		/**
		 * Returns the Xexport query associated with this RawResults block.
		 *
		 * @return the Xexport query
		 */
		String getXexport() {
			return(export);
		}

		/**
		 * Adds an error to this object's error queue
		 *
		 * @param error the error string to add
		 */
		synchronized void addError(String error) {
			this.error += error + "\n";
			// notify listener for our lock object; maybe this is bad news
			// that must be heard...
			this.notify();
		}
	}

	/**
	 * A Header represents a Mapi SQL header which looks like:
	 *
	 * <pre>
	 * &amp;4 1 28 2 10 0 f
	 * # name,     value # name
	 * # varchar,  varchar # type
	 * </pre>
	 * (&amp;"qt" "id" "tc" "cc" "rc" "of" "ac").
	 */
	interface Header {
		/**
		 * Adds a header line to the underlying Header implementation.
		 * 
		 * @param line the header line as String
		 * @throws SQLException if the header line is invalid, or header
		 *         lines are not allowed.
		 */
		public abstract void addHeader(String line) throws SQLException;

		/**
		 * Indicates that no more header lines will be added to this
		 * Header implementation.
		 * 
		 * @throws SQLException if the contents of the Header is not
		 *         consistent or sufficient.
		 */
		public abstract void complete() throws SQLException;

		/**
		 * Instructs the Header implementation to close and do the
		 * necessary clean up procedures.
		 *
		 * @throws SQLException
		 */
		public abstract void close();
	}

	class ResultSetHeader implements Header {
		/** The number of columns in this result */
		public final int columncount;
		/** The total number of rows this result set has */
		public final int tuplecount;
		/** The number of rows that will follow the header */
		private int rowcount;
		/** The number of rows from the start of the result set that are
		 *  left out */
		private int offset;
		/** The table ID of this result */
		public final int id;
		/** The names of the columns in this result */
		private String[] name;
		/** The types of the columns in this result */
		private String[] type;
		/** The max string length for each column in this result */
		private int[] columnLengths;
		/** The table for each column in this result */
		private String[] tableNames;
		/** The query sequence number */
		private final int seqnr;
		/** A Map of result blocks (chunks of size fetchSize/cacheSize) */
		private Map resultBlocks;

		/** A bitmap telling whether the headers are set or not */
		private boolean[] isSet;
		/** Whether this Header is closed */
		private boolean closed;

		/** The Connection that we should use when requesting a new block */
		private MonetConnection connection;
		/** A local copy of fetchSize, so its protected from changes made by
		 *  the Statement parent */
		private int cacheSize;
		/** Whether the fetchSize was explitly set by the user */
		private boolean cacheSizeSetExplicitly = false;
		/** A local copy of resultSetType, so its protected from changes made
		 *  by the Statement parent */
		private int rstype;
		/** A local copy of resultSetConcurrency, so its protected from changes
		 *  made by the Statement parent */
		private int rsconcur;
		/** Whether we should send an Xclose command to the server
		 *  if we close this Header */
		private boolean destroyOnClose;
		/** the offset to be used on Xexport queries */
		private int blockOffset = 0;

		private final static int NAMES	= 0;
		private final static int TYPES	= 1;
		private final static int TABLES	= 2;
		private final static int LENS	= 3;


		/**
		 * Sole constructor, which requires a MonetConnection parent to
		 * be given.
		 *
		 * @param id the ID of the result set
		 * @param tuplecount the total number of tuples in the result set
		 * @param columncount the number of columns in the result set
		 * @param rowcount the number of rows in the current block
		 * @param parent the CacheThread that created this Header and will
		 *               supply new result blocks
		 * @param cs the cache size to use
		 * @param mr the maximum number of results to return
		 * @param rst the ResultSet type to use
		 * @param rsc the ResultSet concurrency to use
		 * @param seq the query sequence number
		 */
		ResultSetHeader(
			int id,
			int tuplecount,
			int columncount,
			int rowcount,
			MonetConnection parent,
			int cs,
			int rst,
			int rsc,
			int seq)
			throws SQLException
		{
			isSet = new boolean[7];
			resultBlocks = new HashMap();
			connection = parent;
			if (cs == 0) {
				cacheSize = MonetConnection.DEF_FETCHSIZE;
				cacheSizeSetExplicitly = false;
			} else {
				cacheSize = cs;
				cacheSizeSetExplicitly = true;
			}
			rstype = rst;
			rsconcur = rsc;
			seqnr = seq;
			closed = false;
			destroyOnClose = false;

			this.id = id;
			this.tuplecount = tuplecount;
			this.columncount = columncount;
			this.rowcount = rowcount;
			this.offset = 0;
		}

		/**
		 * Parses the given string and changes the value of the matching
		 * header appropriately.
		 *
		 * @param tmpLine the string that contains the header
		 * @throws SQLException if the header cannot be parsed or is unknown
		 */
		public void addHeader(String tmpLine) throws SQLException {
			char[] chrLine = tmpLine.toCharArray();
			int len = chrLine.length;

			int pos = 0;
			boolean foundChar = false;
			boolean nameFound = false;
			// find header name
			for (int i = len - 1; i >= 0; i--) {
				switch (chrLine[i]) {
					case ' ':
					case '\n':
					case '\t':
					case '\r':
						if (!foundChar) {
							len = i - 1;
						} else {
							pos = i + 1;
						}
					break;
					case '#':
						// found!
						nameFound = true;
						if (pos == 0) pos = i + 1;
						i = 0;	// force the loop to terminate
					break;
					default:
						foundChar = true;
						pos = 0;
					break;
				}
			}
			if (!nameFound)
				throw new SQLException("Illegal header: " + tmpLine);

			// depending on the name of the header, we continue
			switch (chrLine[pos]) {
				default:
					throw new SQLException("Unknown header: " +
							(new String(chrLine, pos, len - pos)));
				case 'n':
					if (len - pos == 4 &&
							tmpLine.regionMatches(pos + 1, "name", 1, 3))
					{
						setNames(getValues(chrLine, 2, pos - 3));
					} else {
						throw new SQLException("Unknown header: " +
								(new String(chrLine, pos, len - pos)));
					}
				break;
				case 'l':
					if (len - pos == 6 &&
							tmpLine.regionMatches(pos + 1, "length", 1, 5))
					{
						setColumnLengths(getIntValues(chrLine, 2, pos - 3));
					} else {
						throw new SQLException("Unknown header: " +
								(new String(chrLine, pos, len - pos)));
					}
				break;
				case 't':
					if (len - pos == 4 &&
							tmpLine.regionMatches(pos + 1, "type", 1, 3))
					{
						setTypes(getValues(chrLine, 2, pos - 3));
					} else if (len - pos == 10 &&
							tmpLine.regionMatches(pos + 1, "table_name", 1, 9))
					{
						setTableNames(getValues(chrLine, 2, pos - 3));
					} else {
						throw new SQLException("Unknown header: " +
								(new String(chrLine, pos, len - pos)));
					}
				break;
			}
		}

		/**
		 * Returns an array of Strings containing the values between
		 * ',\t' separators.
		 *
		 * @param chrLine a character array holding the input data
		 * @param start where the relevant data starts
		 * @param stop where the relevant data stops
		 * @return an array of Strings
		 */
		final private String[] getValues(char[] chrLine, int start, int stop) {
			int elem = 0;
			String[] values = new String[columncount];
			
			for (int i = start; i < stop; i++) {
				if (chrLine[i] == '\t' && chrLine[i - 1] == ',') {
					values[elem++] =
						new String(chrLine, start, i - 1 - start);
					start = i + 1;
				}
			}
			// at the left over part
			values[elem++] = new String(chrLine, start, stop - start);

			return(values);
		}

		/**
		 * Returns an array of ints containing the values between
		 * ',\t' separators.
		 *
		 * @param chrLine a character array holding the input data
		 * @param start where the relevant data starts
		 * @param stop where the relevant data stops
		 * @return an array of ints
		 */
		final private int[] getIntValues(
				char[] chrLine,
				int start,
				int stop
			) throws SQLException
		{
			int elem = 0;
			int tmp = 0;
			int[] values = new int[columncount];

			try {
				for (int i = start; i < stop; i++) {
					if (chrLine[i] == ',' && chrLine[i + 1] == '\t') {
						values[elem++] = tmp;
						tmp = 0;
						start = ++i;
					} else {
						tmp *= 10;
						tmp += MonetResultSet.getIntrinsicValue(chrLine[i], i);
					}
				}
				// at the left over part
				values[elem++] = tmp;
			} catch (java.text.ParseException e) {
				throw new SQLException(e.getMessage() +
						" found: '" + chrLine[e.getErrorOffset()] + "'" +
						" in: " + new String(chrLine) +
						" at pos: " + e.getErrorOffset());
			}

			return(values);
		}

		/**
		 * Returns an the first String that appears before the first
		 * occurrence of the ',\t' separator.
		 *
		 * @param chrLine a character array holding the input data
		 * @param start where the relevant data starts
		 * @param stop where the relevant data stops
		 * @return the first String found
		 */
		private final String getValue(char[] chrLine, int start, int stop) {
			for (int i = start; i < stop; i++) {
				if (chrLine[i] == '\t' && chrLine[i - 1] == ',') {
					return(new String(chrLine, start, i - 1 - start));
				}
			}
			return(new String(chrLine, start, stop - start));
		}

		/**
		 * Sets the name header and updates the bitmask
		 *
		 * @param name an array of Strings holding the column names
		 */
		private void setNames(String[] name) {
			this.name = name;
			isSet[NAMES] = true;
		}

		/**
		 * Sets the type header and updates the bitmask
		 *
		 * @param type an array of Strings holding the column types
		 */
		private void setTypes(String[] type) {
			this.type = type;
			isSet[TYPES] = true;
		}
		
		/**
		 * Sets the table_name header and updates the bitmask
		 *
		 * @param name an array of Strings holding the column's table names
		 */
		private void setTableNames(String[] name) {
			this.tableNames = name;
			isSet[TABLES] = true;
		}

		/**
		 * Sets the length header and updates the bitmask
		 *
		 * @param len an array of ints holding the column lengths
		 */
		private void setColumnLengths(int[] len) {
			this.columnLengths = len;
			isSet[LENS] = true;
		}

		/**
		 * Adds the given RawResults to this Header at the given block
		 * position.
		 *
		 * @param block the result block the RawResults object represents
		 * @param rr the RawResults to add
		 */
		void addRawResults(int block, RawResults rr) {
			resultBlocks.put("" + block, rr);
		}

		/**
		 * Marks this Header as being completed.  A complete Header needs
		 * to be consistent with regard to its internal data.
		 *
		 * @throws SQLException if the data currently in this Header is not
		 *                      sufficient to be consistant
		 */
		public void complete() throws SQLException {
			String error = "";
			if (!isSet[NAMES]) error += "name header missing\n";
			if (!isSet[TYPES]) error += "type header missing\n";
			if (!isSet[TABLES]) error += "table name header missing\n";
			if (!isSet[LENS]) error += "column width header missing\n";
			if (error != "") throw new SQLException(error);

			// make sure the cache size is minimal to
			// reduce overhead and memory usage
			if (cacheSize == 0) {
				cacheSize = rowcount;
			} else {
				cacheSize = Math.min(rowcount, cacheSize);
			}
		}

		/**
		 * Returns the names of the columns
		 *
		 * @return the names of the columns
		 */
		String[] getNames() {
			return(name);
		}

		/**
		 * Returns the types of the columns
		 *
		 * @return the types of the columns
		 */
		String[] getTypes() {
			return(type);
		}

		/**
		 * Returns the tables of the columns
		 *
		 * @return the tables of the columns
		 */
		String[] getTableNames() {
			return(tableNames);
		}

		/**
		 * Returns the lengths of the columns
		 *
		 * @return the lengths of the columns
		 */
		int[] getColumnLengths() {
			return(columnLengths);
		}

		/**
		 * Returns the cache size used within this Header
		 *
		 * @return the cache size
		 */
		int getCacheSize() {
			return(cacheSize);
		}

		/**
		 * Returns the result set type used within this Header
		 *
		 * @return the result set type
		 */
		int getRSType() {
			return(rstype);
		}

		/**
		 * Returns the result set concurrency used within this Header
		 *
		 * @return the result set concurrency
		 */
		int getRSConcur() {
			return(rsconcur);
		}

		/**
		 * Returns the current block offset
		 *
		 * @return the current block offset
		 */
		int getBlockOffset() {
			return(blockOffset);
		}


		/**
		 * Returns a line from the cache. If the line is already present in the
		 * cache, it is returned, if not apropriate actions are taken to make
		 * sure the right block is being fetched and as soon as the requested
		 * line is fetched it is returned.
		 *
		 * @param row the row in the result set to return
		 * @return the exact row read as requested or null if the requested row
		 *         is out of the scope of the result set
		 * @throws SQLException if an database error occurs
		 */
		String getLine(int row) throws SQLException {
			if (row >= tuplecount || row < 0) return null;

			int block = (row - blockOffset) / cacheSize;
			int blockLine = (row - blockOffset) % cacheSize;

			// do we have the right block loaded? (optimistic try)
			RawResults rawr = (RawResults)(resultBlocks.get("" + block));
			// if not, try again and load if appropriate
			if (rawr == null) synchronized(resultBlocks) {
				rawr = (RawResults)(resultBlocks.get("" + block));
				if (rawr == null) {
					/// TODO: ponder about a maximum number of blocks to keep
					///       in memory when dealing with random access to
					///       reduce memory blow-up

					// if we're running forward only, we can discard the old
					// block loaded
					if (rstype == ResultSet.TYPE_FORWARD_ONLY) {
						resultBlocks.clear();

						if (MonetConnection.seqCounter - 1 == seqnr) {
							// there has no query been issued after this
							// one, so we can consider this a uninterrupted
							// continuation request.  Let's increase the
							// blocksize if it was not explicitly set,
							// as the chances are high that we won't bother
							// anyone else by doing so, and just gaining
							// some performance.
							if (!cacheSizeSetExplicitly) {
								// store the previous position in the
								// blockOffset variable
								blockOffset += cacheSize;
								
								// increase the cache size (a lot)
								cacheSize *= 10;
								
								// by changing the cacheSize, we also
								// change the block measures.  Luckily
								// we don't care about previous blocks
								// because we have a forward running
								// pointer only.  However, we do have
								// to recalculate the block number, to
								// ensure the next call to find this
								// new block.
								block = (row - blockOffset) / cacheSize;
								blockLine = (row - blockOffset) % cacheSize;
							}
						}
					}
					
					// ok, need to fetch cache block first
					rawr = connection.addBlock(this, block);
					resultBlocks.put("" + block, rawr);
				}
			}

			try {
				return(rawr.getRow(blockLine));
			} catch (IllegalArgumentException e) {
				throw new SQLException(e.getMessage());
			}
		}

		/**
		 * Closes this Header by sending an Xclose to the server indicating
		 * that the result can be closed at the server side as well.
		 */
		public void close() {
			if (closed) return;
			try {
				// send command to server indicating we're done with this
				// result only if we had an ID in the header and this result
				// was larger than the reply size
				if (destroyOnClose) {
					// since it is not really critical `when' this command is
					// executed, we put it on the CacheThread's queue. If we
					// would want to do it ourselves here, a deadlock situation
					// may occur if the HeaderList calls us.
					connection.closeResult(id);
				}
			} catch (IllegalStateException e) {
				// too late, cache thread is gone or shutting down
			}
			closed = true;
		}

		/**
		 * Returns whether this Header is closed
		 *
		 * @return whether this Header is closed
		 */
		boolean isClosed() {
			return(closed);
		}


		protected void finalize() throws Throwable {
			close();
			super.finalize();
		}
	}

	/**
	 * The AffectedRowsHeader represents an update or schema message.
	 * It keeps an additional count field that represents the affected
	 * rows for update statements, and a success flag (negative numbers,
	 * actually) for schema messages.
	 */
	class AffectedRowsHeader implements Header {
		public final int count;
		
		public AffectedRowsHeader(int cnt) {
			// fill the blank final
			this.count = cnt;
		}

		public void addHeader(String line) throws SQLException {
			throw new SQLException("Header lines are not supported for a AffectedRowsHeader");
		}

		public void complete() {
			// we're empty, because we don't need to check anything...
		}

		public void close() {
			// nothing to do here...
		}
	}

	/**
	 * The AutoCommitHeader represents a transaction message.  It stores
	 * (a change in) the server side auto commit mode.
	 */
	class AutoCommitHeader extends AffectedRowsHeader {
		public final boolean autocommit;
		
		public AutoCommitHeader(boolean ac) {
			super(Statement.SUCCESS_NO_INFO);
			// fill the blank final
			this.autocommit = ac;
		}
	}

	/**
	 * A list of Header objects.  Headers are added to this list till the
	 * setComplete() method is called.  This allows users of this HeaderList
	 * to determine whether more Headers can be added or not.  Upon add or
	 * completion, the object itself is notified, so a user can use this object
	 * to wait on when figuring out whether a new Header is available.
	 */
	class HeaderList {
		/** The query or query list that resulted in this HeaderList */
		final String query;
		/** The cache size (number of rows in a RawResults object) */
		final int cachesize;
		/** The maximum number of results for this query */
		final int maxrows;
		/** The ResultSet type to produce */
		final int rstype;
		/** The ResultSet concurrency to produce */
		final int rsconcur;
		/** The sequence number of this HeaderList */
		final int seqnr;
		/** Whether there are more Headers to come or not */
		private boolean complete;
		/** A list of the Headers associated with the query,
		 *  in the right order */
		private List headers;

		/** The current header returned by getNextHeader() */
		private int curHeader;
		/** The errors produced by the query */
		private String error;

		/**
		 * Main constructor.  The query argument can either be a String
		 * or List.  An SQLException is thrown if another object
		 * instance is supplied.
		 *
		 * @param query the query that is the 'cause' of this HeaderList
		 * @param cachesize overall cachesize to use
		 * @param maxrows maximum number of rows to allow in the set
		 * @param rstype the type of result sets to produce
		 * @param rsconcur the concurrency of result sets to produce
		 */
		HeaderList(
				String query,
				int cachesize,
				int maxrows,
				int rstype,
				int rsconcur)
			throws SQLException
		{
			this.query = query;
			this.cachesize = cachesize;
			this.maxrows = maxrows;
			this.rstype = rstype;
			this.rsconcur = rsconcur;
			complete = false;
			headers = new ArrayList();
			curHeader = -1;
			error = "";
			seqnr = MonetConnection.seqCounter++;
		}


		/** Sets the complete flag to true and notifies this object. */
		synchronized void setComplete() {
			complete = true;
			this.notify();
		}

		/** Adds a Header to this object and notifies this object. */
		synchronized void addHeader(Header header) {
			headers.add(header);
			this.notify();
		}

		/**
		 * Retrieves the number of Headers currently in this list.
		 *
		 * @return the number of Header objects in this list
		 */
		synchronized int getSize() {
			return(headers.size());
		}

		/**
		 * Returns whether this HeaderList is completed.
		 *
		 * @return whether this HeaderList is completed
		 */
		synchronized boolean isCompleted() {
			return(complete);
		}

		/**
		 * Returns the query.
		 * 
		 * @return the query
		 */
		String query() {
			return(query);
		}

		/**
		 * Retrieves the requested Header.
		 *
		 * @return the Header in this list at position i
		 */
		private synchronized Header getHeader(int i) {
			return((Header)(headers.get(i)));
		}

		/**
		 * Retrieves the next available header, or null if there are no next
		 * headers to come.
		 *
		 * @return the next Header available or null
		 */
		synchronized Header getNextHeader() throws SQLException {

			curHeader++;
			while(curHeader >= getSize() && !isCompleted()) {
				try {
					this.wait();
				} catch (InterruptedException e) {
					// hmmm... recheck to see why we were woken up
				}
			}

			if (error != "") throw new SQLException(error);

			if (curHeader >= getSize()) {
				// header is obviously completed so, there are no more headers
				return(null);
			} else {
				// return this header
				return(getHeader(curHeader));
			}
		}

		/** Adds an error to the pile of errors for this object */
		synchronized void addError(String error) {
			this.error += error + "\n";
		}

		/**
		 * Closes the Header at index i, if not null
		 *
		 * @param i the index position of the header to close
		 */
		private synchronized void closeHeader(int i) {
			if (i < 0 || i >= getSize()) return;
			Header tmp = getHeader(i);
			if (tmp != null) tmp.close();
		}

		/**
		 * Closes the current header
		 */
		synchronized void closeCurrentHeader() {
			closeHeader(curHeader);
		}

		/**
		 * Closes the current and previous headers
		 */
		synchronized void closeCurOldHeaders() {
			for (int i = curHeader; i >= 0; i--) {
				closeHeader(i);
			}
		}

		/**
		 * Closes this HeaderList by closing all the Headers in this
		 * HeaderList.
		 */
		synchronized void close() {
			for (int i = 0; i < headers.size(); i++) {
				getHeader(i).close();
			}
		}


		protected void finalize() throws Throwable {
			close();
			super.finalize();
		}
	}

	/**
	 * A thread to send a query to the server.  When sending large
	 * amounts of data to a server, the output buffer of the underlying
	 * communication socket may overflow.  In such case the sending
	 * process blocks.  In order to prevent deadlock, it might be
	 * desirable that the driver as a whole does not block.  This thread
	 * facilitates the prevention of such 'full block', because this
	 * separate thread only will block.<br />
	 * This thread is designed for reuse, as thread creation costs are
	 * high.<br />
	 * <br />
	 * NOTE: This thread is neither thread safe nor synchronised.  The
	 * reason for this is that program wise only one thread (the
	 * CacheThread) will use this thread, so costly locking mechanisms
	 * can be avoided.
	 */
	class SendThread extends Thread {
		/** The state WAIT represents this thread to be waiting for
		 *  something to do */
		private final static int WAIT = 0;
		/** The state QUERY represents this thread to be executing a query */
		private final static int QUERY = 1;

		private HeaderList hdrl;
		private MonetSocketBlockMode conn;
		private String error;
		private int state = WAIT;

		/**
		 * Constructor which immediately starts this thread and sets it into
		 * daemon mode.
		 *
		 * @param monet the socket to write to
		 */
		public SendThread(MonetSocketBlockMode conn) {
			super("SendThread");
			setDaemon(true);
			this.conn = conn;
			start();
		}

		public synchronized void run() {
			while (true) {
				while (state == WAIT) {
					try {
						// wait requires the object to be exclusive
						// (synchronized)
						this.wait();
					} catch (InterruptedException e) {
						// woken up, eh?
					}
				}

				// state is QUERY here
				try {
					// we issue notify here, so incase we get blocked on IO
					// the thread that waits on us in runQuery can continue
					this.notify();
					conn.writeLine(queryTempl, hdrl.query());
				} catch (IOException e) {
					error = e.getMessage();
				}

				// update our state, and notify, maybe someone is waiting
				// for us in throwErrors
				state = WAIT;
				this.notify();
			}
		}

		/**
		 * Starts sending the given query over the given socket.  Beware
		 * that the thread should be finished (assured by calling
		 * throwErrors()) before this method is called!
		 *
		 * @param hdrl a HeaderList containing the query to send
		 * @throws SQLException if this SendThread is already in use
		 */
		public synchronized void runQuery(HeaderList hdrl) 
			throws SQLException
		{
			if (state != WAIT) throw
				new SQLException("SendThread already in use!");

			this.hdrl = hdrl;

			// let the thread know there is some work to do
			state = QUERY;
			this.notify();

			// implement the following behaviour:
			// - let the SendThread first try to send whatever it can over
			//   the socket
			// - return as soon as the SendThread gets blocked
			// the effect is a relatively high chance of data waiting to be
			// read when returning from this method.
			try {
				this.wait();
			} catch (InterruptedException e) {
				// Woken up, eh?  Let's hope it's all good
			}
		}

		/**
		 * Throws errors encountered during the sending process or about
		 * the current state of the thread.
		 *
		 * @throws AssertionError (note: Error) if this thread is not
		 *         finished at the time of calling this method (should
		 *         theoretically never happen, since this method should
		 *         never be called before a prompt is seen (and hence
		 *         the full query was sent))
		 * @throws SQLException in case an (IO) error occurred while
		 *         sending the query to the server.
		 */
		public synchronized void throwErrors() throws SQLException {
			// make sure the thread is in WAIT state, not QUERY
			while (state != WAIT) {
				try {
					this.wait();
				} catch (InterruptedException e) {
					// just try again
				}
			}
			if (error != null) throw new SQLException(error);
		}
	}
}

// vim: foldmethod=marker:
