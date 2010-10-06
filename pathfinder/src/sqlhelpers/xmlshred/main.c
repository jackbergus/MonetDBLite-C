/**
 * Copyright Notice:
 * -----------------
 *
 * The contents of this file are subject to the Pathfinder Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of the License at
 * http://monetdb.cwi.nl/Legal/PathfinderLicense-1.1.html
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied.  See
 * the License for the specific language governing rights and limitations
 * under the License.
 *
 * The Original Code is the Pathfinder system.
 *
 * The Original Code has initially been developed by the Database &
 * Information Systems Group at the University of Konstanz, Germany and
 * the Database Group at the Technische Universitaet Muenchen, Germany.
 * It is now maintained by the Database Systems Group at the Eberhard
 * Karls Universitaet Tuebingen, Germany.  Portions created by the
 * University of Konstanz, the Technische Universitaet Muenchen, and the
 * Universitaet Tuebingen are Copyright (C) 2000-2005 University of
 * Konstanz, (C) 2005-2008 Technische Universitaet Muenchen, and (C)
 * 2008-2010 Eberhard Karls Universitaet Tuebingen, respectively.  All
 * Rights Reserved.
 *
 * $Id$
 */

#include "pf_config.h"

#include <assert.h>
#include <stdio.h>
#ifdef HAVE_STDBOOL_H
#include <stdbool.h>
#endif
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h> 

/* alternative definitions for strdup and strndup
 * and some helper functions
 */
#include "shred_helper.h"
/* hashtable support */
#include "hash.h"
/* main shredding */
#include "encoding.h"
/* ... SHoops */
#include "oops.h"

/* SAX parser interface (libxml2) */
#include "libxml/parser.h"
#include "libxml/parserInternals.h"

#if HAVE_GETOPT_H && HAVE_GETOPT_LONG
#include <getopt.h>

/**
 * long (GNU-style) command line options and their abbreviated
 * one-character variants.  Keep this list SORTED in ascending
 * order of one-character option names.
 */
static struct option long_options[] = {
    { "format",              required_argument, NULL, 'F' },
    { "attributes-separate", no_argument,       NULL, 'a' },
    { "doc-name",            required_argument, NULL, 'd' },
    { "in-file",             required_argument, NULL, 'f' },
    { "help",                no_argument,       NULL, 'h' },
    { "names-inline",        no_argument,       NULL, 'n' },
    { "out-file",            required_argument, NULL, 'o' },
    { "quiet",               no_argument,       NULL, 'q' },
    { "strip-values",        required_argument, NULL, 's' },
    { "table",               no_argument,       NULL, 't' },
    { NULL,                  no_argument,       NULL, 0   }
};
/* also see definition of OPT_STRING below */

/**
 * character buffer large enough to hold longest
 * command line option plus some extra formatting space
 */
static char opt_buf[sizeof ("attributes-separate") + 8];

static int 
cmp_opt (const void *o1, const void *o2) 
{
    return ((struct option *)o1)->val - ((struct option *)o2)->val;
}

/**
 * map a one-character command line option to its equivalent
 * long form
 */
static const char 
*long_option (char *buf, char *t, char o) 
{
    struct option key = { 0, 0, 0, o };
    struct option *l;

    if ((l = (struct option *) bsearch (&key, long_options,
                                        sizeof (long_options) / 
                                            sizeof (struct option) - 1,
                                        sizeof (struct option),
                                        cmp_opt))) {
        snprintf (buf, sizeof (opt_buf), t, l->name);
        buf[sizeof(opt_buf) - 1] = 0;
        return buf;
    } else
        return "";
}

#else

#ifndef HAVE_GETOPT_H 

#include "win32_getopt.c" /* fall back on a standalone impl */

#define getopt win32_getopt
#define getopt_long win32_getopt_long
#define getopt_long_only win32_getopt_long_only
#define _getopt_internal _win32_getopt_internal
#define opterr win32_opterr
#define optind win32_optind
#define optopt win32_optopt
#define optarg win32_optarg
#endif

/* no long option names w/o GNU getopt */
#include <unistd.h>

#define long_option(buf,t,o) ""
#define opt_buf 0

#endif

#define OPT_STRING "F:ad:f:hno:qs:t"
                                  
/** 
 * Default format (for SQL-based XQuery processing)
 */
#define SQL_FORMAT "%e, %s, %l, %k, %n, %t, %g, %u"

/* print help message */
static void
print_help (char *progname)
{
    printf ("Pathfinder XML Shredder\n");
    printf ("(c) Database Systems Group, ");
    printf (    "Eberhard Karls Universitaet Tuebingen\n\n");
    printf ("Produces relational encodings of XML input documents, one node/tuple\n\n");

    printf ("Usage: %s [OPTION] -f [FILE] -o [PREFIX]\n\n", progname);            

    printf ("  -f filename%s: encode given input XML document\n",
            long_option (opt_buf, ", --%s=filename", 'f'));
    printf ("  -o prefix%s: writes encoding to file PREFIX.csv\n",
            long_option (opt_buf, ", --%s=prefix", 'o'));
    printf ("  -d docname%s: assign document name to document(s)\n",
            long_option (opt_buf, ", --%s=docname", 'd'));
    printf ("  -F format%s: format selected encoding components\n"
            "\t(default: '%s')\n"
            "\t%%e: node preorder rank\n"
            "\t%%o: node postorder rank\n"
            "\t%%E: node preorder rank in stretched pre/post plane\n"
            "\t%%O: node postorder rank in stretched pre/post plane\n"
            "\t%%h: node ORDPATH label as required by SQL SERVERs hierarchyid type\n"
            "\t%%s: size of subtree below node\n"
            "\t%%l: length of path from root to node (level)\n"
            "\t%%k: node kind\n"
            "\t%%p: preorder rank of parent node\n"
            "\t%%P: preorder rank of parent node in stretched pre/post plane\n"
            "\t%%n: element/attribute localname\n"
            "\t%%u: element/attribute namespace URI\n"
            "\t%%t: text node content\n"
            "\t%%d: text node content stored as number (if possible)\n"
            "\t%%g: guide node for node (also writes dataguide to file PREFIX_guide.xml)\n",
            long_option (opt_buf, ", --%s=format", 'F'), SQL_FORMAT);
    printf ("  -a%s: attributes separate (default: attributes inline)\n"
            "\twrites attribute encoding to file PREFIX_atts.csv\n",
            long_option (opt_buf, ", --%s", 'a'));
    printf ("  -n%s: element/attribute names inline (default: names separate)\n"
            "\twrites localname/URI encoding to files PREFIX_names.csv/PREFIX_uris.csv\n",
            long_option (opt_buf, ", --%s", 'n'));
    printf ("  -h%s: print this help message\n",
            long_option (opt_buf, ", --%s", 'h'));
    printf ("  -s n%s: strip values to n characters\n",
            long_option (opt_buf, ", --%s=n", 's'));
    printf ("  -t%s: interpret input as table of document references\n",
            long_option (opt_buf, ", --%s", 't'));
    printf ("  -q%s: don't report warnings\n",
            long_option (opt_buf, ", --%s", 'q'));
}

#define MAIN_EXIT(rtn)                                  \
        do { /* free the copied strings ... */          \
             if (progname)       free (progname);       \
             free (status.format);                      \
             if (status.infile)  free (status.infile);  \
             if (status.outfile) free (status.outfile); \
             /* ... and exit */                         \
             exit (rtn);                                \
           } while (0)
int
main (int argc, char **argv)
{
    shred_state_t status;  
    char *progname   = NULL;
    char *doc_name   = NULL;

    FILE *shout      = NULL;
    FILE *attout     = NULL;
    FILE *namesout   = NULL;
    FILE *urisout    = NULL;
    FILE *guideout   = NULL;
    FILE *tableout   = NULL;

    /*
     * Determine basename(argv[0]) and dirname(argv[0]) on
     * of argv[0] as both functions may modify their arguments.
     */
    progname = strndup (argv[0], FILENAME_MAX);

    status.format = strdup(SQL_FORMAT); 
    status.infile = NULL;
    status.outfile = NULL;
    status.statistics = true;
    status.names_separate = true;
    status.attributes_separate = false;
    status.quiet = false;
    status.strip_values = 100; 
    status.table = false;

    /* parse command line using getopt library */
    while (true) {
        int c; 

#if HAVE_GETOPT_H && HAVE_GETOPT_LONG
        int option_index = 0;
        opterr = 1;
        c = getopt_long (argc, argv, OPT_STRING, 
                         long_options, &option_index);
#else
        c = getopt (argc, argv, OPT_STRING);
#endif

        if (c == -1)
            break;
        switch (c) {
            case 'a':
                status.attributes_separate = true;
                break;
            case 'n':
                status.names_separate = false;
                break;
            case 'F':
                free (status.format);
                status.format = strdup (optarg);
                status.statistics = (strstr (status.format, "%g")) != NULL;
                break;
            case 'f':
                status.infile = strndup (optarg, FILENAME_MAX);
                if (!SHreadable (status.infile)) 
                    SHoops (SH_FATAL, "input XML file `%s' not readable: %s",
                            status.infile, strerror (errno));
                if (status.infile)
                    status.doc_name = status.infile;
                else
                    status.doc_name = "";
                break;
            case 'd':
                doc_name = strndup (optarg, FILENAME_MAX);
                break;
            case 'q':
                status.quiet = true;
                break;
            case 'o':
                status.outfile = strndup (optarg, FILENAME_MAX);
                break;
            case 's':
                if (!sscanf (optarg, "%u", &status.strip_values))
                    SHoops (SH_FATAL, "option -s requires numeric argument\n");
                break;
            case 't':
                status.table = true;
                break;
            case 'h':
                print_help (progname);
                exit (0);
            default:
                SHoops (SH_FATAL, "try `%s -h'\n", progname);
        }
    }

    if (doc_name)
        status.doc_name = doc_name;

    /* we can only print to standard out
       if the output ends up in a single 'file' */
    if (!status.outfile &&
        (status.attributes_separate ||
         status.names_separate ||
         status.statistics)) {
        SHoops (SH_FATAL, "output filename required (-o)\n");
    }
    
    if (status.outfile) {
        /* open files */ 
        if (status.attributes_separate) {
            /* attribute file */
            char attoutfile[FILENAME_MAX];
            snprintf (attoutfile, FILENAME_MAX, "%s_atts.csv", status.outfile);
            attoutfile[sizeof(attoutfile) - 1] = 0;
            attout = SHopen_write (attoutfile);
        }
    
        if (status.names_separate) {
            /* names file */
            char namesoutfile[FILENAME_MAX];
            char urisoutfile[FILENAME_MAX];
            snprintf (namesoutfile, FILENAME_MAX, "%s_names.csv", status.outfile);
            namesoutfile[sizeof(namesoutfile) - 1] = 0;
            namesout = SHopen_write (namesoutfile);
            snprintf (urisoutfile, FILENAME_MAX, "%s_uris.csv", status.outfile);
            urisoutfile[sizeof(urisoutfile) - 1] = 0;
            urisout = SHopen_write (urisoutfile);
        }
    
        if (status.statistics) {
            /* guide file */
            char guideoutfile[FILENAME_MAX];
            snprintf (guideoutfile, FILENAME_MAX, "%s_guide.xml", status.outfile);
            guideoutfile[sizeof(guideoutfile) - 1] = 0;
            guideout = SHopen_write (guideoutfile);
        }

        if (status.table) {
            /* table file */
            char tableoutfile[FILENAME_MAX];
            snprintf (tableoutfile, FILENAME_MAX, "%s_table.xml", status.outfile);
            tableoutfile[sizeof(tableoutfile) - 1] = 0;
            tableout = SHopen_write (tableoutfile);
        }

        /* encoding file */
        char outfile[FILENAME_MAX];
        snprintf (outfile, FILENAME_MAX, "%s.csv", status.outfile);
        outfile[sizeof(outfile) - 1] = 0;
        shout = SHopen_write (outfile);
    }
    else
        shout = stdout;
                                
    /* the input XML file is strictly required */
    if (!status.infile)
        SHoops (SH_FATAL, "input XML filename required (-f)\n");
    
    if (status.table)
        /* shred the XML input file */
        SHshredder_table (status.infile,
                          shout, attout, namesout, urisout, guideout, tableout,
                          &status);
    else
        /* shred the XML input file */
        SHshredder (status.infile,
                    shout, attout, namesout, urisout, guideout,
                    &status);

    if (status.outfile)             
        fclose (shout);
    if (status.attributes_separate) 
        fclose (attout);
    if (status.names_separate) { 
        fclose (namesout); 
        fclose (urisout); 
    }
    if (status.statistics)          
        fclose (guideout);
    if (status.table)          
        fclose (tableout);

    MAIN_EXIT (EXIT_SUCCESS);
}
