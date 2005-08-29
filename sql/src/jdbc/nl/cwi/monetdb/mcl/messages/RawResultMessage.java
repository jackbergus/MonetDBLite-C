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
 * Portions created by CWI are Copyright (C) 1997-2005 CWI.
 * All Rights Reserved.
 */

package nl.cwi.monetdb.mcl.messages;

import java.util.*;
import nl.cwi.monetdb.mcl.*;

/**
 * A RawResultMessage is a server originated message, sent by the server
 * for a result with large character data.
 *
 * @author Fabian Groffen <Fabian.Groffen>
 */
public class RawResultMessage extends MCLMessage {
	/** The character that identifies this message */
	public static final char identifier = 'r';

	private final static MCLSentence startOfMessageSentence;
	
	static {
		try {
			startOfMessageSentence =
				new MCLSentence(MCLSentence.STARTOFMESSAGE, "" + identifier);
		} catch (MCLException e) {
			throw new AssertionError("Unable to create core sentence");
		}
	}

	// these represent the internal values of this Message
	private String type;
	
	/**
	 * Constructs an empty RawResultMessage.  The sentences need to be
	 * added using the addSentence() method.  This constructor is
	 * suitable when reconstructing messages from a stream.
	 */
	public RawResultMessage() {
		// nothing has to be done here
		sentences = new MCLSentence[2];
	}

	/**
	 * Constructs a filled RawResultMessage.  All required information
	 * is supplied and stored in this RawResultMessage.  If type is
	 * null, the default MIME of <tt>plain/text</tt> is assumed.
	 *
	 * @param type the data MIME type of the data
	 * @param data the actual UTF8 data in this message
	 * @throws MCLException if the data is null
	 */
	public RawResultMessage(String type, byte[] data) throws MCLException {
		if (data == null) throw
			new MCLException("data may not be null");
		if (type == null) type = "plain/text";
		
		sentences = new MCLSentence[2];
		this.type = type;
		sentences[0] = new MCLSentence(MCLSentence.MCLMETADATA, "type", type);
		sentences[1] = new MCLSentence(MCLSentence.DATA, data);
	}

	/**
	 * Returns the type of this Message as an integer type.
	 * 
	 * @return an integer value that represents the type of this Message
	 */
	public int getType() {
		return(identifier);
	}

	/**
	 * Returns the start of message sentence for this Message: &amp;e.
	 *
	 * @return the start of message sentence
	 */
	public MCLSentence getSomSentence() {
		return(startOfMessageSentence);
	}


	/**
	 * Adds the given String to this Message if it matches the Message
	 * type.  The sentence is parsed as far as that is considered to be
	 * necessary to validate it against the Message type.  If a sentence
	 * is not valid, an MCLException is thrown.
	 * 
	 * @param in an MCLSentence object
	 * @throws MCLException if the given sentence is not considered to
	 * be valid
	 */
	public void addSentence(MCLSentence in) throws MCLException {
		// see if it is a supported header
		switch (in.getType()) {
			case MCLSentence.MCLMETADATA:
				String prop = in.getField(1);
				if (prop == null) throw
					new MCLException("Illegal sentence (no property): " + in.getString());
				String value = in.getField(2);
				if (value == null) throw
					new MCLException("Illegal sentence (no value): " + in.getString());

				if (prop.equals("type")) {
					sentences[0] = in;
				} else {
					throw new MCLException("Illegal property '" + prop + "' for this Message");
				}
			break;
			case MCLSentence.DATA:
				if (sentences[1] != null) throw
					new MCLException("Data sentence already set, can only have one!");
				sentences[1] = in;
			break;
			default:
				throw new MCLException("Sentence type not allowed for this message: " + (char)in.getType());
		}
	}


	// the following are message specific getters that retrieve the
	// values inside the message

	/**
	 * Retrieves the reference id contained in this Message object.
	 *
	 * @return the result set id
	 */
	public String getMimeType() {
		return(type);
	}
}
