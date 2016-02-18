#include "monetdb_config.h"

#ifdef HAVE_EMBEDDED_R
#include "embeddedr.h"
#include "R_ext/Random.h"
#include "monet_options.h"
#include "mal.h"
#include "mal_client.h"
#include "mal_linker.h"
#include "msabaoth.h"
#include "sql_scenario.h"
#include "gdk_utils.h"

int embedded_r_rand(void) {
	int ret;
	GetRNGstate();
	ret = (int) lround(unif_rand() * RAND_MAX);
	PutRNGstate();
	return ret;
}


/* we need the BAT-SEXP-BAT conversion in two places, here and in RAPI */
#include "converters.c"

SEXP monetdb_query_R(SEXP connsexp, SEXP query, SEXP notreallys) {
	res_table* output = NULL;
	char* err = monetdb_query(R_ExternalPtrAddr(connsexp), (char*)CHAR(STRING_ELT(query, 0)), (void**)&output);
	char notreally = LOGICAL(notreallys)[0];

	if (err != NULL) { // there was an error
		return ScalarString(mkCharCE(err, CE_UTF8));
	}
	if (output && output->nr_cols > 0) {
		int i;
		SEXP retlist, names, varvalue = R_NilValue;
		retlist = PROTECT(allocVector(VECSXP, output->nr_cols));
		names = PROTECT(NEW_STRING(output->nr_cols));
		SET_ATTR(retlist, install("__rows"),
			Rf_ScalarReal(BATcount(BATdescriptor(output->cols[0].b))));
		for (i = 0; i < output->nr_cols; i++) {
			res_col col = output->cols[i];
			BAT* b = BATdescriptor(col.b);
			if (notreally) {
				BATsetcount(b, 0); // hehe
			}
			SET_STRING_ELT(names, i, mkCharCE(output->cols[i].name, CE_UTF8));
			varvalue = bat_to_sexp(b);
			if (varvalue == NULL) {
				UNPROTECT(i + 3);
				return ScalarString(mkCharCE("Conversion error", CE_UTF8));
			}
			SET_VECTOR_ELT(retlist, i, varvalue);
		}
		SET_NAMES(retlist, names);
		UNPROTECT(output->nr_cols + 2);

		monetdb_cleanup_result(R_ExternalPtrAddr(connsexp), output);
		return retlist;
	}
	return ScalarLogical(1);
}

SEXP monetdb_startup_R(SEXP dbdirsexp, SEXP silentsexp, SEXP sequentialsexp) {
	char* res = NULL;

	if (monetdb_embedded_initialized) {
		return ScalarLogical(0);
	}

	res = monetdb_startup((char*) CHAR(STRING_ELT(dbdirsexp, 0)),
		LOGICAL(silentsexp)[0], LOGICAL(sequentialsexp)[0]);

	if (res == NULL) {
		return ScalarLogical(1);
	}  else {
		return ScalarString(mkCharCE(res, CE_UTF8));
	}
}


SEXP monetdb_append_R(SEXP connsexp, SEXP schemasexp, SEXP namesexp, SEXP tabledatasexp) {
	const char *schema = NULL, *name = NULL;
	str msg;
	int col_ct, i;
	BAT *b = NULL;
	append_data *ad = NULL;
	int t_column_count;
	char** t_column_names = NULL;
	int* t_column_types = NULL;

	if (!IS_CHARACTER(schemasexp) || !IS_CHARACTER(namesexp)) {
		return ScalarInteger(-1);
	}
	schema = CHAR(STRING_ELT(schemasexp, 0));
	name = CHAR(STRING_ELT(namesexp, 0));
	col_ct = LENGTH(tabledatasexp);

	msg = monetdb_get_columns(R_ExternalPtrAddr(connsexp), schema, name, &t_column_count, &t_column_names, &t_column_types);
	if (msg != MAL_SUCCEED)
		goto wrapup;

	if (t_column_count != col_ct) {
		msg = GDKstrdup("Unequal number of columns"); // TODO: add counts here
		goto wrapup;
	}

	ad = GDKmalloc(col_ct * sizeof(append_data));
	assert(ad != NULL);

	for (i = 0; i < col_ct; i++) {
		SEXP ret_col = VECTOR_ELT(tabledatasexp, i);
		int bat_type = t_column_types[i];
		b = sexp_to_bat(ret_col, bat_type);
		if (b == NULL) {
			msg = createException(MAL, "embedded", "Could not convert column %i %s to type %i ", i, t_column_names[i], bat_type);
			goto wrapup;
		}
		ad[i].colname = t_column_names[i];
		ad[i].batid = b->batCacheid;
	}

	msg = monetdb_append(R_ExternalPtrAddr(connsexp), schema, name, ad, col_ct);

	wrapup:
		if (t_column_names != NULL) {
			GDKfree(t_column_names);
		}
		if (t_column_types != NULL) {
			GDKfree(t_column_types);
		}
		if (msg == NULL) {
			return ScalarLogical(1);
		}
		return ScalarString(mkCharCE(msg, CE_UTF8));
}


SEXP monetdb_connect_R(void) {
	void* llconn = monetdb_connect();
	SEXP conn = NULL;
	if (!llconn) {
		error("Could not create connection.");
	}
	conn = PROTECT(R_MakeExternalPtr(llconn, R_NilValue, R_NilValue));
	R_RegisterCFinalizer(conn, (void (*)(SEXP)) monetdb_disconnect_R);
	UNPROTECT(1);
	return conn;
}

SEXP monetdb_disconnect_R(SEXP connsexp) {
	void* addr = R_ExternalPtrAddr(connsexp);
	if (addr != NULL) {
		monetdb_disconnect(addr);
		R_ClearExternalPtr(connsexp);
	}
	return R_NilValue;
}

SEXP monetdb_shutdown_R(void) {
	monetdb_shutdown();
	return R_NilValue;
}
#endif
