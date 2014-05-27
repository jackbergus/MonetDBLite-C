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
 * Copyright August 2008-2014 MonetDB B.V.
 * All Rights Reserved.
 */

import java.math.BigDecimal;
import java.math.BigInteger;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/* Test whether we can represent a full-size int128 as JDBC results */
public class Test_Int128 {
	public static void main(String[] args) throws Exception {
		Class.forName("nl.cwi.monetdb.jdbc.MonetDriver");
		Connection con = DriverManager.getConnection(args[0]);
		BigInteger bd = new BigInteger(
				"123000000001037407179000000000695893739");
		try {
			con.setAutoCommit(false);
			Statement s = con.createStatement();
			s.executeUpdate("CREATE TABLE HUGEINTT (I HUGEINT)");
			s.executeUpdate("CREATE TABLE HUGEDECT (I DECIMAL(38,2))");

			PreparedStatement insertStatement = con
					.prepareStatement("INSERT INTO HUGEINTT VALUES (?)");
			insertStatement.setBigDecimal(1, new BigDecimal(bd));
			insertStatement.executeUpdate();
			insertStatement.close();

			ResultSet rs = s.executeQuery("SELECT I FROM HUGEINTT");
			rs.next();
			BigInteger bdRes = rs.getBigDecimal(1).toBigInteger();
			rs.close();
			s.close();
			
			if (!bd.equals(bdRes)) {
				throw new RuntimeException("Expecting " + bd + ", got " + bdRes);
			}
			System.out.println("SUCCESS");

		} catch (SQLException e) {
			System.out.println("FAILED :( " + e.getMessage());
			System.out.println("ABORTING TEST!!!");
		}

		con.close();
	}
}
