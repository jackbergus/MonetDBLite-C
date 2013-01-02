/*
 * The contents of this file are subject to the MonetDB Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://www.monetdb.org/Legal/MonetDBLicense
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
 * Copyright August 2008-2013 MonetDB B.V.
 * All Rights Reserved.
 */

import java.sql.*;

public class Test_Rmetadata {
	public static void main(String[] args) throws Exception {
		Class.forName("nl.cwi.monetdb.jdbc.MonetDriver");
		Connection con = DriverManager.getConnection(args[0]);
		Statement stmt = con.createStatement();
		ResultSet rs = null;
		ResultSetMetaData rsmd = null;
		//DatabaseMetaData dbmd = con.getMetaData();

		con.setAutoCommit(false);
		// >> false: auto commit should be off now
		System.out.println("0. false\t" + con.getAutoCommit());

		try {
			stmt.executeUpdate("CREATE TABLE table_Test_Rmetadata ( myint int, mydouble double, mybool boolean, myvarchar varchar(15), myclob clob )");

			// all NULLs
			stmt.executeUpdate("INSERT INTO table_Test_Rmetadata VALUES (NULL, NULL,            NULL,           NULL,                  NULL)");
			// all filled in
			stmt.executeUpdate("INSERT INTO table_Test_Rmetadata VALUES (2   , 3.0,             true,           'A string',            'bla bla bla')");

			rs = stmt.executeQuery("SELECT * FROM table_Test_Rmetadata");
			rsmd = rs.getMetaData();

			System.out.println("0. 4 columns:\t" + rsmd.getColumnCount());
			for (int col = 1; col <= rsmd.getColumnCount(); col++) {
				System.out.println("" + col + ".\t" + rsmd.getCatalogName(col));
				System.out.println("\tclassname     " + rsmd.getColumnClassName(col));
				System.out.println("\tdisplaysize   " + rsmd.getColumnDisplaySize(col));
				System.out.println("\tlabel         " + rsmd.getColumnLabel(col));
				System.out.println("\tname          " + rsmd.getColumnName(col));
				System.out.println("\ttype          " + rsmd.getColumnType(col));
				System.out.println("\ttypename      " + rsmd.getColumnTypeName(col));
				System.out.println("\tprecision     " + rsmd.getPrecision(col));
				System.out.println("\tscale         " + rsmd.getScale(col));
				System.out.println("\tschemaname    " + rsmd.getSchemaName(col));
				System.out.println("\ttablename     " + rsmd.getTableName(col));
				System.out.println("\tautoincrement " + rsmd.isAutoIncrement(col));
				System.out.println("\tcasesensitive " + rsmd.isCaseSensitive(col));
				System.out.println("\tcurrency      " + rsmd.isCurrency(col));
				System.out.println("\tdefwritable   " + rsmd.isDefinitelyWritable(col));
				System.out.println("\tnullable      " + rsmd.isNullable(col));
				System.out.println("\treadonly      " + rsmd.isReadOnly(col));
				System.out.println("\tsearchable    " + rsmd.isSearchable(col));
				System.out.println("\tsigned        " + rsmd.isSigned(col));
				System.out.println("\twritable      " + rsmd.isWritable(col));
			}

			for (int i = 5; rs.next(); i++) {
				for (int col = 1; col <= rsmd.getColumnCount(); col++) {
					System.out.println("" + i + ".\t" +
						isInstance(rs.getObject(col), rsmd.getColumnClassName(col))
					);
				}
			}
		} catch (SQLException e) {
			System.out.println("failed :( "+ e.getMessage());
			System.out.println("ABORTING TEST!!!");
		}

		con.rollback();
		con.close();
	}

	private static String isInstance(Object obj, String type) {
		if (obj == null)
			return("(null)");
		try {
			Class c = Class.forName(type);
			if (c.isInstance(obj)) {
				return(obj.getClass().getName() + " is an instance of " + type);
			} else {
				return(obj.getClass().getName() + " is NOT an instance of " + type);
			}
		} catch (ClassNotFoundException e) {
			return("No such class: " + type);
		}
	}
}
