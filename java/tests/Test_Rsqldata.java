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
 * Copyright August 2008-2012 MonetDB B.V.
 * All Rights Reserved.
 */

import java.sql.*;
import nl.cwi.monetdb.jdbc.types.*;

public class Test_Rsqldata {
	public static void main(String[] args) throws Exception {
		Class.forName("nl.cwi.monetdb.jdbc.MonetDriver");
		Connection con = DriverManager.getConnection(args[0]);
		Statement stmt = con.createStatement();
		ResultSet rs = null;
		ResultSetMetaData rsmd = null;

		con.setAutoCommit(false);
		// >> false: auto commit should be off now
		System.out.println("0. false\t" + con.getAutoCommit());

		try {
			stmt.executeUpdate("CREATE TABLE table_Test_Rsqldata ( myinet inet, myurl url )");

			// all NULLs
			stmt.executeUpdate("INSERT INTO table_Test_Rsqldata VALUES (NULL, NULL)");
			// all filled in
			stmt.executeUpdate("INSERT INTO table_Test_Rsqldata VALUES ('172.5.5.5' , 'http://www.monetdb.org/')");
			stmt.executeUpdate("INSERT INTO table_Test_Rsqldata VALUES ('172.5.5.5/32' , 'http://www.monetdb.org/Home')");
			stmt.executeUpdate("INSERT INTO table_Test_Rsqldata VALUES ('172.5.5.5/16' , 'http://www.monetdb.org/Home#someanchor')");
			stmt.executeUpdate("INSERT INTO table_Test_Rsqldata VALUES ('172.5.5.5/26' , 'http://www.monetdb.org/?query=bla')");

			rs = stmt.executeQuery("SELECT * FROM table_Test_Rsqldata");
			rsmd = rs.getMetaData();

			System.out.println("0. 4 columns:\t" + rsmd.getColumnCount());
			for (int col = 1; col <= rsmd.getColumnCount(); col++) {
				System.out.println("" + col + ".\t" + rsmd.getCatalogName(col));
				System.out.println("\tclassname     " + rsmd.getColumnClassName(col));
				System.out.println("\tschemaname    " + rsmd.getSchemaName(col));
				System.out.println("\ttablename     " + rsmd.getTableName(col));
				System.out.println("\tname          " + rsmd.getColumnName(col));
			}

			for (int i = 1; rs.next(); i++) {
				for (int col = 1; col <= rsmd.getColumnCount(); col++) {
					Object x = rs.getObject(col);
					if (x == null) {
						System.out.println("" + i + ".\t<null>");
					} else {
						System.out.println("" + i + ".\t" + x.toString());
						if (x instanceof INET) {
							INET inet = (INET)x;
							System.out.println("\t" + inet.getAddress() + "/" + inet.getNetmaskBits());
							System.out.println("\t" + inet.getInetAddress().toString());
						} else if (x instanceof URL) {
							URL url = (URL)x;
							System.out.println("\t" + url.getURL().toString());
						}
					}
				}
			}
		} catch (SQLException e) {
			System.out.println("failed :( "+ e.getMessage());
			System.out.println("ABORTING TEST!!!");
		}

		con.rollback();
		con.close();
	}
}
