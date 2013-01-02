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

package nl.cwi.monetdb.merovingian;

/**
 * An Exception raised when monetdbd specific problems occur.
 * <br /><br />
 * This class is a shallow wrapper around Exception to identify an
 * exception as one originating from the monetdbd instance being
 * communicated with, instead of a locally generated one.
 *
 * @author Fabian Groffen <Fabian.Groffen@cwi.nl>
 * @version 1.0
 */
public class MerovingianException extends Exception {
	public MerovingianException(String reason) {
		super(reason);
	}
}
