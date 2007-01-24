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
 * Portions created by CWI are Copyright (C) 1997-2007 CWI.
 * All Rights Reserved.
 */

import java.sql.*;

public class BugConcurrent_clients_1504657 {

	public static void main(String[] args) throws Exception {
		Class.forName("nl.cwi.monetdb.jdbc.MonetDriver");
		Connection con1 = DriverManager.getConnection(args[0]);
		Connection con2 = DriverManager.getConnection(args[0]);
		Connection con3 = DriverManager.getConnection(args[0]);
		Statement stmt1 = con1.createStatement();
		Statement stmt2 = con2.createStatement();
		Statement stmt3 = con2.createStatement();
		ResultSet rs1 = null, rs2= null, rs3 = null;
		//DatabaseMetaData dbmd = con.getMetaData();

		// >> true: auto commit should be on by default
		System.out.println("0. true\t" + con1.getAutoCommit());
		System.out.println("0. true\t" + con2.getAutoCommit());

		// test the creation of a table with concurrent clients
		try {
			System.out.print("1.1. create table t1 using client 1...");
			stmt1.executeUpdate("CREATE TABLE t1 ( id int, name varchar(1024) )");
			System.out.println("passed :)");
			System.out.print("1.2. check table existence in client 2...");
			rs2 = stmt2.executeQuery("SELECT * FROM tables where name='t1'");
			while (rs2.next())
				System.out.println(rs2.getInt("id")+", "+ rs2.getString("name"));
			System.out.println("passed :)");
			System.out.print("1.3. check table existence in client 3...");
			while (rs3.next())
				System.out.println(rs3.getInt("id")+", "+ rs3.getString("name"));
			rs3 = stmt3.executeQuery("SELECT * FROM tables where name='t1'");
			System.out.println("passed :)");
		} catch (SQLException e) {
			// this means we failed (table not there perhaps?)
			System.out.println("FAILED :( " + e.getMessage());
			System.out.println("ABORTING TEST!!!");
			con1.close();
			con2.close();
			con3.close();
			System.exit(-1);
		}

		// test the insertion of values with concurrent clients
		try {
			System.out.print("2 insert into t1 using client 1...");
			stmt1.executeUpdate("INSERT INTO t1 values( 1, 'monetdb' )");
			System.out.println("passed :)");
			stmt1.executeUpdate("INSERT INTO t1 values( 2, 'monet' )");
			System.out.println("passed :)");
			stmt1.executeUpdate("INSERT INTO t1 values( 3, 'mon' )");
			System.out.println("passed :)");
			System.out.print("2.1. check table status with client 1...");
			rs1 = stmt1.executeQuery("SELECT * FROM t1");
			while (rs1.next())
				System.out.println(rs1.getInt("id")+", "+ rs1.getString("name"));
			System.out.println("passed :)");
			System.out.print("2.2. check table status with client 2...");
			rs2 = stmt2.executeQuery("SELECT * FROM t1");
			while (rs2.next())
				System.out.println(rs2.getInt("id")+", "+ rs2.getString("name"));
			System.out.println("passed :)");
			System.out.print("2.3. check table status with client 3...");
			rs3 = stmt3.executeQuery("SELECT * FROM t1");
			while (rs3.next())
				System.out.println(rs3.getInt("id")+", "+ rs3.getString("name"));
			System.out.println("passed :)");
		} catch (SQLException e) {
			// this means we failed (table not there perhaps?)
			System.out.println("FAILED :( " + e.getMessage());
			System.out.println("ABORTING TEST!!!");
			if (rs1 != null) rs1.close();
			if (rs2 != null) rs2.close();
			if (rs3 != null) rs3.close();
			con1.close();
			con2.close();
			con3.close();
			System.exit(-1);
		}

		// test the insertion of values with concurrent clients
		try {
			System.out.print("3 insert into t1 using client 2...");
			stmt2.executeUpdate("INSERT INTO t1 values( 4, 'monetdb' )");
			System.out.println("passed :)");
			stmt2.executeUpdate("INSERT INTO t1 values( 5, 'monet' )");
			System.out.println("passed :)");
			stmt2.executeUpdate("INSERT INTO t1 values( 6, 'mon' )");
			System.out.println("passed :)");
			System.out.print("3.1. check table status with client 1...");
			rs1 = stmt1.executeQuery("SELECT * FROM t1");
			System.out.println("passed :)");
			System.out.print("3.2. check table status with client 2...");
			rs2 = stmt2.executeQuery("SELECT * FROM t1");
			System.out.println("passed :)");
			System.out.print("3.3. check table status with client 3...");
			rs3 = stmt3.executeQuery("SELECT * FROM t1");
			System.out.println("passed :)");
		} catch (SQLException e) {
			// this means we failed (table not there perhaps?)
			System.out.println("FAILED :( " + e.getMessage());
			System.out.println("ABORTING TEST!!!");
			if (rs1 != null) rs1.close();
			if (rs2 != null) rs2.close();
			if (rs3 != null) rs3.close();
			con1.close();
			con2.close();
			con3.close();
			System.exit(-1);
		}

		// test the insertion of values with concurrent clients
		try {
			System.out.print("4 insert into t1 using client 3...");
			stmt3.executeUpdate("INSERT INTO t1 values( 7, 'monetdb' )");
			System.out.println("passed :)");
			stmt3.executeUpdate("INSERT INTO t1 values( 8, 'monet' )");
			System.out.println("passed :)");
			stmt3.executeUpdate("INSERT INTO t1 values( 9, 'mon' )");
			System.out.println("passed :)");
			System.out.print("4.1. check table status with client 1...");
			rs1 = stmt1.executeQuery("SELECT * FROM t1");
			while (rs1.next())
				System.out.println(rs1.getInt("id")+", "+ rs1.getString("name"));
			System.out.println("passed :)");
			System.out.print("4.2. check table status with client 2...");
			rs2 = stmt2.executeQuery("SELECT * FROM t1");
			while (rs2.next())
				System.out.println(rs2.getInt("id")+", "+ rs2.getString("name"));
			System.out.println("passed :)");
			System.out.print("4.3. check table status with client 3...");
			rs3 = stmt3.executeQuery("SELECT * FROM t1");
			while (rs3.next())
				System.out.println(rs3.getInt("id")+", "+ rs3.getString("name"));
			System.out.println("passed :)");
		} catch (SQLException e) {
			// this means we failed (table not there perhaps?)
			System.out.println("FAILED :( " + e.getMessage());
			System.out.println("ABORTING TEST!!!");
			if (rs1 != null) rs1.close();
			if (rs2 != null) rs2.close();
			if (rs3 != null) rs3.close();
			con1.close();
			con2.close();
			con3.close();
			System.exit(-1);
		}

		if (rs1 != null) rs1.close();
		if (rs2 != null) rs2.close();
		if (rs3 != null) rs3.close();

		con1.close();
		con2.close();
		con3.close();
	}
}
