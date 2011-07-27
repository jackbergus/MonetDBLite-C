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
 * Copyright August 2008-2011 MonetDB B.V.
 * All Rights Reserved.
 */

/*
 * @' The contents of this file are subject to the MonetDB Public License
 * @' Version 1.1 (the "License"); you may not use this file except in
 * @' compliance with the License. You may obtain a copy of the License at
 * @' http://www.monetdb.org/Legal/MonetDBLicense
 * @'
 * @' Software distributed under the License is distributed on an "AS IS"
 * @' basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * @' License for the specific language governing rights and limitations
 * @' under the License.
 * @'
 * @' The Original Code is the MonetDB Database System.
 * @'
 * @' The Initial Developer of the Original Code is CWI.
 * @' Portions created by CWI are Copyright (C) 1997-July 2008 CWI.
 * @' Copyright August 2008-2011 MonetDB B.V.
 * @' All Rights Reserved.
 *
 * @a M. Ivanova, M. Kersten, N. Nes
 * @f fits
 * @- This module contains primitives for accessing data in FITS file format.
 *
 * @-
 */
/*
 * @-
 *
 */
#include "monetdb_config.h"
#include <glob.h>

/* clash with GDK? */
#undef htype
#undef ttype
#include <fitsio.h>
#include <fitsio2.h>
#include <longnam.h>

#include "fits.h"
#include "mutils.h"
#include "sql_mvc.h"
#include "sql_scenario.h"
#include "sql.h"
#include "clients.h"
#include "mal_exception.h"

#define FITS_INS_COL "INSERT INTO fits_columns(id, name, type, units, number, table_id) \
	 VALUES(%d,'%s','%s','%s',%d,%d);"
#define FILE_INS "INSERT INTO fits_files(id, name) VALUES (%d, '%s');"
#define DEL_TABLE "DELETE FROM fitsfiles;"
#define ATTACHDIR "call fitsattach('%s');"

static void
FITSinitCatalog(mvc *m)
{
	sql_schema *sch;
	sql_table *fits_tp, *fits_fl, *fits_tbl, *fits_col;

	sch = mvc_bind_schema(m, "sys");

	fits_fl = mvc_bind_table(m, sch, "fits_files");
	if (fits_fl == NULL) {
		fits_fl = mvc_create_table(m, sch, "fits_files", tt_table, 0, SQL_PERSIST, 0, 2);
		mvc_create_column_(m, fits_fl, "id", "int", 32);
		mvc_create_column_(m, fits_fl, "name", "varchar", 80);
	}

	fits_tbl = mvc_bind_table(m, sch, "fits_tables");
	if (fits_tbl == NULL) {
		fits_tbl = mvc_create_table(m, sch, "fits_tables", tt_table, 0, SQL_PERSIST, 0, 8);
		mvc_create_column_(m, fits_tbl, "id", "int", 32);
		mvc_create_column_(m, fits_tbl, "name", "varchar", 80);
		mvc_create_column_(m, fits_tbl, "columns", "int", 32);
		mvc_create_column_(m, fits_tbl, "file_id", "int", 32);
		mvc_create_column_(m, fits_tbl, "hdu", "int", 32);
		mvc_create_column_(m, fits_tbl, "date", "varchar", 80);
		mvc_create_column_(m, fits_tbl, "origin", "varchar", 80);
		mvc_create_column_(m, fits_tbl, "comment", "varchar", 80);
	}

	fits_col = mvc_bind_table(m, sch, "fits_columns");
	if (fits_col == NULL) {
		fits_col = mvc_create_table(m, sch, "fits_columns", tt_table, 0, SQL_PERSIST, 0, 6);
		mvc_create_column_(m, fits_col, "id", "int", 32);
		mvc_create_column_(m, fits_col, "name", "varchar", 80);
		mvc_create_column_(m, fits_col, "type", "varchar", 80);
		mvc_create_column_(m, fits_col, "units", "varchar", 10);
		mvc_create_column_(m, fits_col, "number", "int", 32);
		mvc_create_column_(m, fits_col, "table_id", "int", 32);
	}

	fits_tp = mvc_bind_table(m, sch, "fits_table_properties");
	if (fits_tp == NULL) {
		fits_tp = mvc_create_table(m, sch, "fits_table_properties", tt_table, 0, SQL_PERSIST, 0, 5);
		mvc_create_column_(m, fits_tp, "table_id", "int", 32);
		mvc_create_column_(m, fits_tp, "xtension", "varchar", 80);
		mvc_create_column_(m, fits_tp, "bitpix", "int", 32);
		mvc_create_column_(m, fits_tp, "stilvers", "varchar", 80);
		mvc_create_column_(m, fits_tp, "stilclas", "varchar", 80);
	}
}

static int
fits2mtype(int t)
{
	switch (t) {
	case TBIT:
	case TLOGICAL:
		return TYPE_bit;
	case TBYTE:
	case TSBYTE:
		return TYPE_chr;
	case TSTRING:
		return TYPE_str;
	case TUSHORT:
	case TSHORT:
		return TYPE_sht;
	case TUINT:
	case TINT:
		return TYPE_int;
	case TLONG:
	case TULONG:
	case TLONGLONG:
		return TYPE_lng;
	case TFLOAT:
		return TYPE_flt;
	case TDOUBLE:
		return TYPE_dbl;
	/* missing */
	case TCOMPLEX:
	case TDBLCOMPLEX:
		return -1;
	}
	return -1;
}

static int
fits2subtype(sql_subtype *tpe, int t, long rep, long wid)
{
	(void)rep;
	switch (t) {
	case TBIT:
	case TLOGICAL:
		sql_find_subtype(tpe, "boolean", 0, 0);
		break;
	case TBYTE:
	case TSBYTE:
		sql_find_subtype(tpe, "char", 1, 0);
		break;
	case TSTRING:
		sql_find_subtype(tpe, "varchar", (unsigned int)wid, 0);
		break;
	case TUSHORT:
	case TSHORT:
		sql_find_subtype(tpe, "smallint", 16, 0);
		break;
	case TUINT:
	case TINT:
		sql_find_subtype(tpe, "int", 32, 0);
		break;
	case TULONG:
	case TLONG:
	case TLONGLONG:
		sql_find_subtype(tpe, "bigint", 64, 0);
		break;
	case TFLOAT:
		sql_find_subtype(tpe, "real", 32, 0);
		break;
	case TDOUBLE:
		sql_find_subtype(tpe, "double", 51, 0);
		break;
	/* missing */
	case TCOMPLEX:
	case TDBLCOMPLEX:
		return -1;
	}
	return 1;
}

str FITSdir(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	str msg = MAL_SUCCEED;
	str dir = *(str*)getArgReference(stk, pci, 1);
	DIR *dp;
	struct dirent *ep;
	fitsfile *fptr;
	char *s;
	int status = 0;
	(void)mb;

	dp = opendir(dir);
	if (dp != NULL) {
		char stmt[BUFSIZ];
		char fname[BUFSIZ];

		s = stmt;

		while ((ep = readdir(dp)) != NULL) {
			snprintf(fname, BUFSIZ, "%s%s", dir, ep->d_name);
			status = 0;
			fits_open_file(&fptr, fname, READONLY, &status);
			if (status == 0) {
				snprintf(stmt, BUFSIZ, ATTACHDIR, fname);
				msg = SQLstatementIntern(cntxt, &s, "fits.listofdir", TRUE, FALSE);
				fits_close_file(fptr, &status);
			}
		}
		(void)closedir(dp);
	}else
		msg = createException(MAL, "listdir", "Couldn't open the directory");

	return msg;
}

str FITSdirpat(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	str msg = MAL_SUCCEED;
	str dir = *(str*)getArgReference(stk, pci, 1);
	str pat = *(str*)getArgReference(stk, pci, 2);
	fitsfile *fptr;
	char *s;
	int status = 0;
	glob_t globbuf;
	char fulldirectory[BUFSIZ];
	size_t j = 0;

	(void)mb;
	globbuf.gl_offs = 0;
	snprintf(fulldirectory, BUFSIZ, "%s%s", dir, pat);
	glob(fulldirectory, GLOB_DOOFFS, NULL, &globbuf);

	/*	mnstr_printf(GDKout,"#fulldir: %s \nSize: %lu\n",fulldirectory, globbuf.gl_pathc);*/

	if (globbuf.gl_pathc == 0)
		msg = createException(MAL, "listdir", "Couldn't open the directory or there are no files that match the pattern");

	for (j = 0; j < globbuf.gl_pathc; j++) {
		char stmt[BUFSIZ];
		char fname[BUFSIZ];

		s = stmt;
		snprintf(fname, BUFSIZ, "%s", globbuf.gl_pathv[j]);
		status = 0;
		fits_open_file(&fptr, fname, READONLY, &status);
		if (status == 0) {
			snprintf(stmt, BUFSIZ, ATTACHDIR, fname);
			msg = SQLstatementIntern(cntxt, &s, "fits.listofdirpat", TRUE, FALSE);
			fits_close_file(fptr, &status);
		}
	}

	return msg;
}


str
FITStest(int *res, str *fname)
{
	fitsfile *fptr;       /* pointer to the FITS file, defined in fitsio.h */
	str msg = MAL_SUCCEED;
	int status = 0, hdutype;

	*res = 0;
	if (fits_open_file(&fptr, *fname, READONLY, &status))
		msg = createException(MAL, "fits.test", "Missing FITS file %s", *fname);
	else {
		fits_movabs_hdu(fptr, 2, &hdutype, &status);
		*res = hdutype;
		fits_close_file(fptr, &status);
	}

	return msg;
}

str FITSattach(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	mvc *m = NULL;
	sql_schema *sch;
	sql_table *fits_tp, *fits_fl, *fits_tbl, *fits_col, *tbl = NULL;
	sql_column *col;
	str msg = MAL_SUCCEED;
	str fname = *(str*)getArgReference(stk, pci, 1);
	fitsfile *fptr;  /* pointer to the FITS file */
	int status = 0, i, j, hdutype, hdunum = 1, cnum = 0, bitpixnumber = 0;
	oid fid, tid, cid, rid = oid_nil;
	char tname[BUFSIZ], *tname_low = NULL, *s, bname[BUFSIZ], stmt[BUFSIZ];
	long tbcol;
	char cname[BUFSIZ], tform[BUFSIZ], tunit[BUFSIZ], tnull[BUFSIZ], tdisp[BUFSIZ];
	double tscal, tzero;
	char xtensionname[BUFSIZ] = "", stilversion[BUFSIZ] = "";
	char stilclass[BUFSIZ] = "", tdate[BUFSIZ] = "", orig[BUFSIZ] = "", comm[BUFSIZ] = "";

	msg = getContext(cntxt, mb, &m, NULL);
	if (msg)
		return msg;

	if (fits_open_file(&fptr, fname, READONLY, &status)) {
		msg = createException(MAL, "fits.attach", "Missing FITS file %s.\n", fname);
		return msg;
	}

	sch = mvc_bind_schema(m, "sys");

	fits_fl = mvc_bind_table(m, sch, "fits_files");
	if (fits_fl == NULL)
		FITSinitCatalog(m);

	fits_fl = mvc_bind_table(m, sch, "fits_files");
	fits_tbl = mvc_bind_table(m, sch, "fits_tables");
	fits_col = mvc_bind_table(m, sch, "fits_columns");
	fits_tp = mvc_bind_table(m, sch, "fits_table_properties");

	/* check if the file is already attached */
	col = mvc_bind_column(m, fits_fl, "name");
	rid = table_funcs.column_find_row(m->session->tr, col, fname, NULL);
	if (rid != oid_nil) {
		fits_close_file(fptr, &status);
		msg = createException(SQL, "fits.attach", "File %s already attached\n", fname);
		return msg;
	}

	/* add row in the fits_files catalog table */
	col = mvc_bind_column(m, fits_fl, "id");
	fid = store_funcs.count_col(col) + 1;
	store_funcs.append_col(m->session->tr,
		mvc_bind_column(m, fits_fl, "id"), &fid, TYPE_int);
	store_funcs.append_col(m->session->tr,
		mvc_bind_column(m, fits_fl, "name"), fname, TYPE_str);

	col = mvc_bind_column(m, fits_tbl, "id");
	tid = store_funcs.count_col(col) + 1;

	if ((s = strrchr(fname, DIR_SEP)) == NULL)
		s = fname;
	else
		s++;
	strcpy(bname, s);
	s = strrchr(bname, '.');
	if (s) *s = 0;

	fits_get_num_hdus(fptr, &hdunum, &status);
	for (i = 1; i <= hdunum; i++) {
		fits_movabs_hdu(fptr, i, &hdutype, &status);
		if (hdutype != ASCII_TBL && hdutype != BINARY_TBL)
			continue;

		/* SQL table name - the name of FITS extention */
		fits_read_key(fptr, TSTRING, "EXTNAME", tname, NULL, &status);
		if (status) {
			snprintf(tname, BUFSIZ, "%s_%d", bname, i);
			tname_low = toLower(tname);
			status = 0;
		}else  { /* check table name for existence in the fits catalog */
			tname_low = toLower(tname);
			col = mvc_bind_column(m, fits_tbl, "name");
			rid = table_funcs.column_find_row(m->session->tr, col, tname_low, NULL);
			/* or as regular SQL table */
			tbl = mvc_bind_table(m, sch, tname_low);
			if (rid != oid_nil || tbl) {
				snprintf(tname, BUFSIZ, "%s_%d", bname, i);
				tname_low = toLower(tname);
			}
		}

		fits_read_key(fptr, TSTRING, "BITPIX", &bitpixnumber, NULL, &status);
		if (status) {
			status = 0;
		}
		fits_read_key(fptr, TSTRING, "DATE-HDU", tdate, NULL, &status);
		if (status) {
			status = 0;
		}
		fits_read_key(fptr, TSTRING, "XTENSION", xtensionname, NULL, &status);
		if (status) {
			status = 0;
		}
		fits_read_key(fptr, TSTRING, "STILVERS", stilversion, NULL, &status);
		if (status) {
			status = 0;
		}
		fits_read_key(fptr, TSTRING, "STILCLAS", stilclass, NULL, &status);
		if (status) {
			status = 0;
		}
		fits_read_key(fptr, TSTRING, "ORIGIN", orig, NULL, &status);
		if (status) {
			status = 0;
		}
		fits_read_key(fptr, TSTRING, "COMMENT", comm, NULL, &status);
		if (status) {
			status = 0;
		}

		fits_get_num_cols(fptr, &cnum, &status);

		store_funcs.append_col(m->session->tr,
			mvc_bind_column(m, fits_tbl, "id"), &tid, TYPE_int);
		store_funcs.append_col(m->session->tr,
			mvc_bind_column(m, fits_tbl, "name"), tname_low, TYPE_str);
		store_funcs.append_col(m->session->tr,
			mvc_bind_column(m, fits_tbl, "columns"), &cnum, TYPE_int);
		store_funcs.append_col(m->session->tr,
			mvc_bind_column(m, fits_tbl, "file_id"), &fid, TYPE_int);
		store_funcs.append_col(m->session->tr,
			mvc_bind_column(m, fits_tbl, "hdu"), &i, TYPE_int);
		store_funcs.append_col(m->session->tr,
			mvc_bind_column(m, fits_tbl, "date"), tdate, TYPE_str);
		store_funcs.append_col(m->session->tr,
			mvc_bind_column(m, fits_tbl, "origin"), orig, TYPE_str);
		store_funcs.append_col(m->session->tr,
			mvc_bind_column(m, fits_tbl, "comment"), comm, TYPE_str);

		store_funcs.append_col(m->session->tr,
			mvc_bind_column(m, fits_tp, "table_id"), &tid, TYPE_int);
		store_funcs.append_col(m->session->tr,
			mvc_bind_column(m, fits_tp, "xtension"), xtensionname, TYPE_str);
		store_funcs.append_col(m->session->tr,
			mvc_bind_column(m, fits_tp, "bitpix"), &bitpixnumber, TYPE_int);
		store_funcs.append_col(m->session->tr,
			mvc_bind_column(m, fits_tp, "stilvers"), stilversion, TYPE_str);
		store_funcs.append_col(m->session->tr,
			mvc_bind_column(m, fits_tp, "stilclas"), stilclass, TYPE_str);

		/* read columns description */
		s = stmt;
		col = mvc_bind_column(m, fits_col, "id");
		cid = store_funcs.count_col(col) + 1;
		for (j = 1; j <= cnum; j++, cid++) {
			fits_get_acolparms(fptr, j, cname, &tbcol, tunit, tform, &tscal, &tzero, tnull, tdisp, &status);
			snprintf(stmt, BUFSIZ, FITS_INS_COL, (int)cid, cname, tform, tunit, j, (int)tid);
			msg = SQLstatementIntern(cntxt, &s, "fits.attach", TRUE, FALSE);
		}
		tid++;
	}
	fits_close_file(fptr, &status);

	return MAL_SUCCEED;
}

str FITSloadTable(Client cntxt, MalBlkPtr mb, MalStkPtr stk, InstrPtr pci)
{
	mvc *m = NULL;
	sql_schema *sch;
	sql_table *fits_fl, *fits_tbl, *tbl = NULL;
	sql_column *col;
	sql_subtype tpe;
	fitsfile *fptr;
	str tname = *(str*)getArgReference(stk, pci, 1);
	str fname;
	str msg = MAL_SUCCEED;
	oid rid = oid_nil, frid = oid_nil;
	int status = 0, cnum = 0, fid, hdu, hdutype, i, j, anynull = 0, mtype;
	int *tpcode = NULL;
	long *rep = NULL, *wid = NULL, rows;
	char keywrd[80], **cname, nm[FLEN_VALUE];
	ptr nilptr;

	msg = getContext(cntxt, mb, &m, NULL);
	if (msg)
		return msg;
	sch = mvc_bind_schema(m, "sys");

	fits_tbl = mvc_bind_table(m, sch, "fits_tables");
	if (fits_tbl == NULL) {
		msg = createException(MAL, "fits.loadtable", "FITS catalog is missing.\n");
		return msg;
	}

	tbl = mvc_bind_table(m, sch, tname);
	if (tbl) {
		msg = createException(MAL, "fits.loadtable", "Table %s is already created.\n", tname);
		return msg;
	}

	col = mvc_bind_column(m, fits_tbl, "name");
	rid = table_funcs.column_find_row(m->session->tr, col, tname, NULL);
	if (rid == oid_nil) {
		msg = createException(MAL, "fits.loadtable", "Table %s is unknown in FITS catalog. Attach first the containing file\n", tname);
		return msg;
	}

	/* Open FITS file and move to the table HDU */
	col = mvc_bind_column(m, fits_tbl, "file_id");
	fid = *(int*)table_funcs.column_find_value(m->session->tr, col, rid);

	fits_fl = mvc_bind_table(m, sch, "fits_files");
	col = mvc_bind_column(m, fits_fl, "id");
	frid = table_funcs.column_find_row(m->session->tr, col, (void *)&fid, NULL);
	col = mvc_bind_column(m, fits_fl, "name");
	fname = (char *)table_funcs.column_find_value(m->session->tr, col, frid);
	if (fits_open_file(&fptr, fname, READONLY, &status)) {
		msg = createException(MAL, "fits.loadtable", "Missing FITS file %s.\n", fname);
		return msg;
	}

	col = mvc_bind_column(m, fits_tbl, "hdu");
	hdu = *(int*)table_funcs.column_find_value(m->session->tr, col, rid);
	fits_movabs_hdu(fptr, hdu, &hdutype, &status);
	if (hdutype != ASCII_TBL && hdutype != BINARY_TBL) {
		msg = createException(MAL, "fits.loadtable", "HDU %d is not a table.\n", hdu);
		fits_close_file(fptr, &status);
		return msg;
	}

	/* create a SQL table to hold the FITS table */
	/*	col = mvc_bind_column(m, fits_tbl, "columns");
	   cnum = *(int*) table_funcs.column_find_value(m->session->tr, col, rid); */
	fits_get_num_cols(fptr, &cnum, &status);
	tbl = mvc_create_table(m, sch, tname, tt_table, 0, SQL_PERSIST, 0, cnum);

	tpcode = (int *)GDKzalloc(sizeof(int) * cnum);
	rep = (long *)GDKzalloc(sizeof(long) * cnum);
	wid = (long *)GDKzalloc(sizeof(long) * cnum);
	cname = (char **)GDKzalloc(sizeof(char *) * cnum);

	for (j = 1; j <= cnum; j++) {
		/*		fits_get_acolparms(fptr, j, cname, &tbcol, tunit, tform, &tscal, &tzero, tnull, tdisp, &status); */
		snprintf(keywrd, 80, "TTYPE%d", j);
		fits_read_key(fptr, TSTRING, keywrd, nm, NULL, &status);
		if (status) {
			snprintf(nm, FLEN_VALUE, "column_%d", j);
			status = 0;
		}
		cname[j - 1] = GDKstrdup(toLower(nm));
		fits_get_coltype(fptr, j, &tpcode[j - 1], &rep[j - 1], &wid[j - 1], &status);
		fits2subtype(&tpe, tpcode[j - 1], rep[j - 1], wid[j - 1]);

		/*		mnstr_printf(cntxt->fdout,"#%d %ld %ld - M: %s\n", tpcode[j-1], rep[j-1], wid[j-1], tpe.type->sqlname); */

		mvc_create_column(m, tbl, cname[j - 1], &tpe);
	}

	/* data load */
	fits_get_num_rows(fptr, &rows, &status);
	mnstr_printf(cntxt->fdout,"#Loading %ld rows in table %s\n", rows, tname);
	for (j = 1; j <= cnum; j++) {
		BAT *tmp = NULL;
		int time0 = GDKms();
		mtype = fits2mtype(tpcode[j - 1]);
		nilptr = ATOMnil(mtype);
		col = mvc_bind_column(m, tbl, cname[j - 1]);

		tmp = BATnew(TYPE_void, mtype, rows);
		if ( tmp == NULL){
			GDKfree(tpcode);
			GDKfree(rep);
			GDKfree(wid);
			GDKfree(cname);
			throw(MAL,"fits.load", MAL_MALLOC_FAIL);
		}
		BATseqbase(tmp, 0);
		if (rows > (long)REMAP_PAGE_MAXSIZE)
			BATmmap(tmp, STORE_MMAP, STORE_MMAP, STORE_MMAP, STORE_MMAP, 0);
		if (mtype != TYPE_str) {
			fits_read_col(fptr, tpcode[j - 1], j, 1, 1, rows, nilptr, (void *)BUNtloc(bat_iterator(tmp), BUNfirst(tmp)), &anynull, &status);
			BATsetcount(tmp, rows);
			tmp->tsorted = 0;
		} else {
/*			char *v = GDKzalloc(wid[j-1]);*/
			int bsize = 50;
			int tm0, tloadtm = 0, tattachtm = 0;
			int batch = bsize, k;
			char **v = (char **) GDKzalloc(sizeof(char *) * bsize);
			for(i = 0; i < bsize; i++)
				v[i] = GDKzalloc(wid[j-1]);
			for(i = 0; i < rows; i += batch) {
				batch = rows - i < bsize ? rows - i: bsize;
				tm0 = GDKms();
				fits_read_col(fptr, tpcode[j - 1], j, 1 + i, 1, batch, nilptr, (void *)v, &anynull, &status);
				tloadtm += GDKms() - tm0;
				tm0 = GDKms();
				for(k = 0; k < batch ; k++)
					BUNappend(tmp, v[k], TRUE);
				tattachtm += GDKms() - tm0;
			}
			for(i = 0; i < bsize ; i++)
				GDKfree(v[i]);
			GDKfree(v);
			mnstr_printf(cntxt->fdout,"#String column load %d ms, BUNappend %d ms\n", tloadtm, tattachtm);
		}

		if (status) {
			char buf[FLEN_ERRMSG + 1];
			fits_read_errmsg(buf);
			msg = createException(MAL, "fits.loadtable", "Cannot load column %s of %s table: %s.\n", cname[j - 1], tname, buf);
			break;
		}
		mnstr_printf(cntxt->fdout,"#Column %s loaded for %d ms\t", cname[j-1], GDKms() - time0);
		store_funcs.append_col(m->session->tr, col, tmp, TYPE_bat);
		mnstr_printf(cntxt->fdout,"#Total %d ms\n", GDKms() - time0);
		BBPunfix(tmp->batCacheid);
	}

	GDKfree(tpcode);
	GDKfree(rep);
	GDKfree(wid);
	GDKfree(cname);

	fits_close_file(fptr, &status);
	return msg;
}

