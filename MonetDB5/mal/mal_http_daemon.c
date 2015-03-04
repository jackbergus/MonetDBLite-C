/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0.  If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Copyright 2008-2015 MonetDB B.V.
 */

/* (author) A. de Rijke
 * For documentation see website
 */

#include "monetdb_config.h"

#ifdef HAVE_MICROHTTPD
#include <sys/types.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <stdint.h>
#include <stdarg.h>
#include <stdio.h>

#include "mal_client.h"
#include "mal_http_daemon.h"
#include "mal_private.h"
#include <microhttpd.h>

static MT_Id hdthread;
static int volatile hdrunning;
struct MHD_Daemon *http_daemon;
#define PORT 8998
#define POSTBUFFERSIZE  512
#define MAXNAMESIZE     512
#define MAXANSWERSIZE   512

#define GET             0
#define POST            1

static
http_request_handler http_handler;

void register_http_handler(http_request_handler handler) {
	http_handler = handler;
}

struct connection_info_struct
{
	int connectiontype;
	char *answerstring;
	struct MHD_PostProcessor *postprocessor;
};

static int
send_page (struct MHD_Connection *connection, const char * url,
	   const char * method, char *page, char * postdata)
{
	int ret;
	int rest;
	struct MHD_Response *response;

	rest = (*http_handler)(url, method, &page, postdata);
	(void)rest;
	response =
		MHD_create_response_from_buffer (strlen (page),
						 (void *) page,
						 MHD_RESPMEM_MUST_COPY);
	if (!response)
		return MHD_NO;

	ret = MHD_queue_response (connection, MHD_HTTP_OK, response);
	MHD_destroy_response (response);

	return ret;
}

static int
iterate_post (void *coninfo_cls, enum MHD_ValueKind kind, const char *key,
              const char *filename, const char *content_type,
              const char *transfer_encoding, const char *data, uint64_t off,
              size_t size)
{
	struct connection_info_struct *con_info = coninfo_cls;
	char *answerstring;

	(void)key;
	(void)kind;
	(void)filename;
	(void)content_type;
	(void)transfer_encoding;
	(void)off;

	if (strcmp (key, "json") == 0)
	{
		if ((size > 0) && (size <= MAXNAMESIZE))
		{
			answerstring = malloc (MAXANSWERSIZE);
			if (!answerstring)
				return MHD_NO;

			snprintf (answerstring, MAXANSWERSIZE, "%s", data);
			con_info->answerstring = answerstring;
		} else
			con_info->answerstring = NULL;

		return MHD_NO;
	}
	
	if (strcmp (key, "file") == 0)
	{
		if ((size > 0) && (size <= MAXNAMESIZE))
		{
			answerstring = malloc (MAXANSWERSIZE);
			if (!answerstring)
				return MHD_NO;

			snprintf (answerstring, MAXANSWERSIZE, "%s", data);
			con_info->answerstring = answerstring;
		} else
			con_info->answerstring = NULL;

		return MHD_NO;
	}
	
	return MHD_YES;
}

static void
request_completed (void *cls, struct MHD_Connection *connection,
                   void **con_cls, enum MHD_RequestTerminationCode toe)
{
	struct connection_info_struct *con_info = *con_cls;

	(void)cls;
	(void)connection;
	(void)toe;

	if (con_info == NULL)
		return;

	if (con_info->connectiontype == POST)
	{
		MHD_destroy_post_processor (con_info->postprocessor);
		if (con_info->answerstring)
			free (con_info->answerstring);
	}

	free (con_info);
	*con_cls = NULL;
}

static int
answer_to_connection (void *cls, struct MHD_Connection *connection,
                      const char *url, const char *method,
                      const char *version, const char *upload_data,
                      size_t *upload_data_size, void **con_cls)
{
	char * page = NULL;
	struct connection_info_struct *con_info = NULL;
	int *done = cls;
	char *answerstring = NULL;
	char *errorpage =
		"<html><body>"
		"Failed to handle error in http request."
		"</body></html>";

	(void)version;

	if (*con_cls == NULL) {
		con_info = malloc (sizeof (struct connection_info_struct));
		if (con_info == NULL)
			return MHD_NO;
		con_info->answerstring = NULL;

		if (strcmp (method, "POST") == 0) {
			con_info->postprocessor =
				MHD_create_post_processor (connection,
							   POSTBUFFERSIZE,
							   iterate_post,
							   (void *) con_info);

			if (con_info->postprocessor == NULL) {
				free (con_info);
				return MHD_NO;
			}
			con_info->connectiontype = POST;
		} else {
			con_info->connectiontype = GET;
		}
		*con_cls = (void *) con_info;
		return MHD_YES;
	}

	if (strcmp (method, "POST") == 0) {
		con_info = *con_cls;
		if (*upload_data_size != 0) {
			MHD_post_process (con_info->postprocessor, upload_data,
					  *upload_data_size);
			*upload_data_size = 0;
			return MHD_YES;
		} else {
			if (con_info->answerstring != NULL) {
				return send_page(connection, url, method, page,
						 con_info->answerstring);
			}
		}
	}

	if (strcmp (method, "PUT") == 0) {
		if (*upload_data_size != 0) {
			// TODO: check free answerstring
			answerstring = malloc (MAXANSWERSIZE);
			if (!answerstring)
				return MHD_NO;

			snprintf (answerstring, MAXANSWERSIZE, "%s", upload_data);
			*upload_data_size = 0;
			return send_page(connection, url, method, page,
					 answerstring);
		}
		*done = 1;
	}

	if ((strcmp (method, "GET") == 0) ||
	    (strcmp (method, "DELETE") == 0)) {
		// TODO: double check if this is needed
		if (con_info == NULL) {
			con_info = malloc (sizeof (struct connection_info_struct));
		}
		return send_page(connection, url, method, page,
				 con_info->answerstring);
	}
	return send_page (connection, url, method, page, errorpage);
}

static void handleHttpdaemon(void *dummy)
{
  int done_flag = 0;
	http_daemon = MHD_start_daemon (MHD_USE_SELECT_INTERNALLY|MHD_USE_DEBUG, PORT, NULL, NULL,
									&answer_to_connection, &done_flag,
									MHD_OPTION_NOTIFY_COMPLETED, request_completed,
									NULL, MHD_OPTION_END);

	if (http_daemon == NULL)
		return;

	(void) dummy;
	while (hdrunning) {
		MT_sleep_ms(50);
	}
}

void startHttpdaemon(void)
{
	hdrunning = 1;
	if (MT_create_thread(&hdthread, handleHttpdaemon, NULL, MT_THR_JOINABLE) < 0) {
		/* it didn't happen */
		hdthread = 0;
		hdrunning = 0;
	}
}

void stopHttpdaemon(void){
	hdrunning = 0;
	MHD_stop_daemon (http_daemon);
	if (hdthread)
		MT_join_thread(hdthread);
}

#else

#include "mal.h"
#include "mal_exception.h"
#include "mal_private.h"
#include "mal_http_daemon.h"

/* dummy noop functions to implement the exported API, if these had been
 * defined to return a str, we could have informed the caller no
 * implementation was available */

void
register_http_handler(http_request_handler handler)
{
	(void)handler;
}

void
startHttpdaemon(void)
{
}

void
stopHttpdaemon(void)
{
}

#endif
