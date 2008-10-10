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
 * Copyright August 2008- MonetDB B.V.
 * All Rights Reserved.
 */

package nl.cwi.monetdb.mcl.io;

import nl.cwi.monetdb.mcl.*;

/**
 * An IOException in the MCL framework.
 *
 * @author Fabian Groffen <Fabian.Groffen>
 */
public class MCLIOException extends MCLException {
	public MCLIOException(String msg) {
		super(msg);
	}
}
