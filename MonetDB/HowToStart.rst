How To Start with MonetDB
=========================

.. This document is written in reStructuredText (see
   http://docutils.sourceforge.net/ for more information).
   Use ``rst2html.py`` to convert this file to HTML.

This document helps you compile and install the MonetDB suite from
scratch on Unix-like systems (this includes of course Linux, but also
MacOS X and Cygwin).  This document is meant to be used when you want
to compile and install from CVS source.  When you use the prepared tar
balls, some of the steps described here should be skipped.

In case you prefer installing a pre-compiled binary distribution,
please check out `the binary distribution`__.

This document assumes that you are planning on compiling and
installing MonetDB on a Unix-like system (e.g., Linux, IRIX, Solaris,
AIX, Mac OS X/Darwin, or CYGWIN).  For compilation and installation on
a native Windows system (NT, 2000, XP) see the instructions in the
file `../buildtools/doc/windowsbuild.rst`__.

__ http://sourceforge.net/project/showfiles.php?group_id=56967
__ Windows-Installation.html

The Suite
---------

The MonetDB software suite consists of the following parts which need
to be built in the correct order:

buildtools
	Tools used only for building the other parts of the suite.
	These tools are only needed when building from CVS.  When
	building from the source distribution (i.e. the tar balls),
	you do not need this.

MonetDB
	Fundamental libraries used in the other parts of the suite.

clients
	Libraries and programs to communicate with the server(s) that
	are part of the suite.

MonetDB4
	The MIL-based server.  This is required if you want to use
	XML/XQuery (pathfinder), and can be used with SQL.

MonetDB5
	The MAL-based server.  This can be used with and is
	recommended for SQL.

pathfinder
	The XML/XQuery engine built on top of MonetDB4.

sql
	The SQL server built on top of (targeted on) either MonetDB4
	or MonetDB5.

MonetDB4 and MonetDB5 are the basic database engines.  One or the
other is required, but you can have both.  Pathfinder currently needs
MonetDB4, sql can run on both MonetDB4 and MonetDB5 (the latter is
recommended).

The order of compilation and installation is important.  It is best to
use the above order (where pathfinder and sql can be interchanged) and
to configure-make-make install each package before proceeding with the
next.

Prerequisites
-------------

CVS
	You only need this if you are building from CVS.  If you start
	with the source distribution from `SourceForge`__ you don't
	need CVS.

	You need to have a working CVS.  For instructions, see `the
	SourceForge documentation`__ and look under the heading CVS
	Instructions.

Python
	MonetDB uses Python (version 2.0.0 or better) during
	configuration of the software.  See http://www.python.org/ for
	more information.  (It must be admitted, version 2.0.0 is
	ancient and has not recently been tested, we currently use
	2.4 and newer.)

autoconf/automake/libtool
	MonetDB uses GNU autoconf__ (>= 2.57) and automake__ (>= 1.5)
	during the Bootstrap_ phase, and libtool__ (>= 1.4) during the
	Make_ phase.  autoconf and automake are not needed when you
	start with the source distribution.

standard software development tools
	To compile MonetDB, you also need to have the following
	standard software development tools installed and ready for
	use on you system:

	- a C compiler (e.g. GNU's ``gcc``);
	- GNU ``make`` (``gmake``) (native ``make`` on, e.g., IRIX and Solaris
	  usually don't work).

	The following are not needed when you start with the source
	distribution:

	- a C++ compiler (e.g. GNU's ``g++``);
	- a lexical analyzer generator (e.g., ``lex`` or ``flex``);
	- a parser generator (e.g., ``yacc`` or ``bison``).

	The following are optional.  They are checked for during
	configuration and if they are missing, the feature is just
	missing:

	- swig
	- perl
	- php

buildtools (Mx, mel, autogen, and burg)
	These tools are not needed when you start with the source
	distribution.

	Before building any of the other packages from the CVS
	sources, you first need to build and install the buildtools.
	Check out buildtools with

	::

	 cvs -d:pserver:anonymous@monetdb.cvs.sourceforge.net:/cvsroot/monetdb checkout buildtools

	and follow the instructions in the README file, then proceed
	with MonetDB.  For this step only you need the C++ compiler.

libxml2
	The XML parsing library `libxml2`__ is only used by
	XML/XQuery (pathfinder).  The library is used for:

	(a) the XML Schema import feature of the Pathfinder compiler, and
	(b) the XML document loader (runtime/shredder.mx).

	If libxml2 is not available on your system, the Pathfinder
	compiler will be compiled without XML Schema support.  The XML
	document loader will not be compiled at all in that case.
	Current Linux distributions all come with libxml2.

__ http://sourceforge.net/project/showfiles.php?group_id=56967
__ http://sourceforge.net/docman/?group_id=1
__ http://www.gnu.org/software/autoconf/
__ http://www.gnu.org/software/automake/
__ http://www.gnu.org/software/libtool/
__ http://www.xmlsoft.org

Space Requirements
~~~~~~~~~~~~~~~~~~

The packages take about this much space:

==========  =======  =======  =======
 Package    Source   Build    Install
==========  =======  =======  =======
buildtools  1.5 MB   8 MB     2.5 MB
MonetDB     2 MB     21 MB    4 MB
clients     9 MB     25 MB    10 MB
MonetDB4    35.5 MB  50 MB    14 MB
MonetDB5    26 MB    46 MB    12 MB
sql         100 MB   22.5 MB  8 MB
pathfinder  130 MB   43 MB    12 MB
==========  =======  =======  =======

Some of the source packages are so large because they include lots of
data for testing purposes.


Getting the Software
--------------------

There are two ways to get the source code:

(1) checking it out from the CVS repository on SourceForge;
(2) downloading the pre-packaged source distribution from
    SourceForge__.

The following instructions first describe how to check out the source
code from the CVS repository on SourceForge; in case you downloaded
the pre-packaged source distribution, you can skip this section and
proceed to `Bootstrap, Configure and Make`_.

__ http://sourceforge.net/project/showfiles.php?group_id=56967

CVS checkout
~~~~~~~~~~~~

This command should be done once.  It records a password on the local
machine to be used for all subsequent CVS accesses with this server.

::

 cvs -d:pserver:anonymous@monetdb.cvs.sourceforge.net:/cvsroot/monetdb login

Just type RETURN when asked for the password.

Then get the software by using the command::

 cvs -d:pserver:anonymous@monetdb.cvs.sourceforge.net:/cvsroot/monetdb checkout \
 buildtools MonetDB clients MonetDB4 MonetDB5 pathfinder sql

This will create the named directories in your current working
directory.  Then first follow the instructions in
``buildtools/README`` before continuing with the others.  Naturally,
you don't need to check out packages you're not going to use.

Also see `the SourceForge documentation`__ for more information about
using CVS.

__ http://sourceforge.net/cvs/?group_id=56967

Bootstrap, Configure and Make
-----------------------------

Before executing the following steps, make sure that your shell
environment (especially the variables ``PATH``.  ``LD_LIBRARY_PATH``,
and ``PYTHONPATH``) is set up so that the tools listed above can be
found.  Also, set up PATH to include the *prefix*/bin directory where
*prefix* is the prefix is where you want everything to be installed,
and set up PYTHONPATH to include the *prefix*/lib/*python2.X*
directory where *python2.X* is the version of Python being used.  It
is recommended to use the same *prefix* for all packages.  Only the
*prefix*/lib/*python2.X* directory for buildtools is needed in
PYTHONPATH.

In case you checked out the CVS version, you have to run ``bootstrap``
first; in case you downloaded the pre-packaged source distribution,
you should skip ``bootstrap`` and start with ``configure`` (see
`Configure`_).

For each of the packages do all the following steps (bootstrap,
configure, make, make install) *before* proceeding to the next
package.

Bootstrap
~~~~~~~~~

This step is only needed when building from CVS.

In the top-level directory of the package type the command (note that
this uses ``autogen.py`` which is part of the ``buildtools`` package
--- make sure it can be found in your ``$PATH``)::

 ./bootstrap

Configure
~~~~~~~~~

Then in any directory (preferably a *new, empty* directory and *not*
in the ``MonetDB`` top-level directory) give the command::

 .../configure [<options>]

where ``...`` is replaced with the (absolute or relative) path to the
``MonetDB`` top-level directory.

The directory where you execute ``configure`` is the place where all
intermediate source and object files are generated during compilation
via ``make``.

By default, MonetDB is installed in ``/usr/local``.  To choose another
target directory, you need to call

::

 .../configure --prefix=<prefixdir> [<options>]

Some other useful ``configure`` options are:

--enable-debug          enable full debugging default=[see `Configure defaults and recommendations`_ below]
--enable-optimize       enable extra optimization default=[see `Configure defaults and recommendations`_ below]
--enable-assert         enable assertions in the code default=[see `Configure defaults and recommendations`_ below]
--enable-strict         enable strict compiler flags default=[see `Configure defaults and recommendations`_ below]
--enable-warning        enable extended compiler warnings default=off
--enable-profile        enable profiling default=off
--enable-instrument     enable instrument default=off
--with-mx=<Mx>          which Mx binary to use (default: whichever
                        Mx is found in your PATH)
--with-mel=<mel>        which mel binary to use (default: whichever
                        mel is found in your PATH)
--enable-bits=<#bits>   specify number of bits (32 or 64)
                        default is compiler default
--enable-oid32          use 32-bit OIDs on 64-bit systems default=off

You can also add options such as ``CC=<compiler>`` to specify the
compiler and compiler flags to use.

Use ``configure --help`` to find out more about ``configure`` options.

The ``--with-mx`` and ``--with-mel`` options are only used when
configuring the sources as retrieved through CVS.

Configure defaults and recommendations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For convenience of both developers and users as well as to comply even more
with open source standards, we now set/use the following defaults for the
configure options

::

 --enable-strict, --enable-assert, --enable-debug, --enable-optimize

When compiling from CVS sources
(as mainly done by developers):

::

 strict=yes  assert=yes  debug=yes  optimize=no (*)

When compiling from packaged/distributed sources (i.e., tarballs)
(as mainly done by users):

::

 strict=no   assert=no   debug=no   optimize=no (*)

For building binary distributions (RPMs):

::

 strict=no   assert=no   debug=no   optimize=yes

``(*)``
IMPORTANT NOTE:

Since ``--enable-optimize=yes`` is no longer the default for any case except
binary packages, it is *strongly recommended* to (re)compile everything from
scratch, *explicitly configured* with

::

 --enable-debug=no --enable-assert=no --enable-optimize=yes

in case you want/need to run any performance experiments with MonetDB!

Please note:
``--enable-X=yes`` is equivalent to ``--enable-X``, and
``--enable-X=no``  is equivalent to ``--disable-X``.

Make
~~~~

In the same directory (where you called ``configure``) give the
command

::

 make

to compile the source code.  Please note that parallel make
runs (e.g. ``make -j2``) are currently known to be unsuccessful.

Testing the Build
~~~~~~~~~~~~~~~~~

This step is optional and only relevant for the packages clients, MonetDB4,
MonetDB5, pathfinder, and sql.

If ``make`` went successfully, you can try

::

 make check

This will perform a large number of tests, some are unfortunately
still expected to fail, but most should go successfully.  At the end
of the output there is a reference to an HTML file which is created by
the test process that shows the test results.

Install
~~~~~~~

Give the command

::

 make install

By default (if no ``--prefix`` option was given to ``configure`` above),
this will install in ``/usr/local``.  Make sure you have appropriate
privileges.


Testing the Installation
~~~~~~~~~~~~~~~~~~~~~~~~

This step is optional and only relevant for the packages clients, MonetDB4,
MonetDB5, pathfinder, and sql.

Make sure that *prefix*/bin is in your ``PATH``.  Then
in the package top-level directory issue the command

::

 Mtest.py -r [--package=<package>]

where *package* is one of ``clients``, ``MonetDB4``, ``MonetDB5``, ``sql``,
or ``pathfinder`` (the ``--package=<package>`` option can be omitted when
using a CVS checkout; see

::

 Mtest.py --help

for more options).

This should produce much the same output as ``make check`` above, but
uses the installed version of MonetDB.

You need write permissions in part of the installation directory for
this command: it will create subdirectories ``var/dbfarm`` and
``Tests``.


Usage
-----

The MonetDB4 and MonetDB5 engines can be used interactively or as a
server.  The XQuery and SQL back-ends can only be used as servers.

To run MonetDB4 interactively, just run::

 Mserver

To run MonetDB5 interactively, just run::

 mserver5

The disadvantage of running the systems interactively is that you
don't get readline support (if available on your system).  A more
pleasant environment can be had by using the system as a server and
using ``mclient`` to interact with the system.  For MonetDB4 use::

 Mserver --dbinit 'module(mapi); mil_start();'

When MonetDB5 is started as above, it automatically starts the server
in addition to the interactive "console".

In order to use the XQuery back-end, which is only available with
MonetDB4, start the server as follows::

 Mserver --dbinit 'module(pathfinder);'

If you want to have a MIL server in addition to the XQuery server,
use::

 Mserver --dbinit 'module(pathfinder); mil_start();'

In order to use the SQL back-end with MonetDB4, use::

 Mserver --dbinit 'module(sql_server);'

If you want to have a MIL server in addition to the SQL server, use::

 Mserver --dbinit 'module(sql_server); mil_start();'

In order to use the SQL back-end with MonetDB5, use::

 mserver5 --dbinit 'include sql;'

Once the server is running, you can use ``mclient`` to interact
with the server.  ``mclient`` needs to be told which language you
want to use, but it does not need to be told whether you're using
MonetDB4 or MonetDB5.  In another shell window start::

 mclient -l<language>

where *language* is one of ``mil``, ``mal``, ``sql``, or ``xquery``.
If no ``-l`` option is given, ``mil`` is the default.

With ``mclient``, you get a text-based interface that supports
command-line editing and a command-line history.  The latter can even
be stored persistently to be re-used after stopping and restarting
``mclient``; see

::

 mclient --help

for global details and 

::

 mclient -l<language> --help

for language-specific details.

At the ``mclient`` prompt some extra commands are available.  Type
a single question mark to get a list of options.  Note that one of the
options is to read input from a file using ``<``.  This interferes
with XQuery syntax.  This is a known bug.


Troubleshooting
---------------

``bootstrap`` fails if any of the requisite programs cannot be found
or is an incompatible version.

``bootstrap`` adds files to the source directory, so it must have
write permissions.

During ``bootstrap``, warnings like

::

 Remember to add `AC_PROG_LIBTOOL' to `configure.in'.
 You should add the contents of `/usr/share/aclocal/libtool.m4' to `aclocal.m4'.
 configure.in:37: warning: do not use m4_patsubst: use patsubst or m4_bpatsubst
 configure.in:104: warning: AC_PROG_LEX invoked multiple times
 configure.in:334: warning: do not use m4_regexp: use regexp or m4_bregexp
 automake/aclocal 1.6.3 is older than 1.7.
 Patching aclocal.m4 for Intel compiler on Linux (icc/ecc).
 patching file aclocal.m4
 Hunk #1 FAILED at 2542.
 1 out of 1 hunk FAILED -- saving rejects to file aclocal.m4.rej
 patching file aclocal.m4
 Hunk #1 FAILED at 1184.
 Hunk #2 FAILED at 2444.
 Hunk #3 FAILED at 2464.
 3 out of 3 hunks FAILED -- saving rejects to file aclocal.m4.rej

might occur.  For some technical reasons, it's hard to completely
avoid them.  However, it is usually safe to ignore them and simply
proceed with the usual compilation procedure.  Only in case the
subsequent ``configure`` or ``make`` fails, these warning might have
to be taken more seriously.  In any case, you should include the
``bootstrap`` output whenever you report (see `Reporting Problems`_)
compilation problems.

``configure`` will fail if certain essential programs cannot be found
or certain essential tasks (such as compiling a C program) cannot be
executed.  The problem will usually be clear from the error message.

E.g., if ``configure`` cannot find package XYZ, it is either not
installed on your machine, or it is not installed in places that
``configure`` searches (i.e., ``/usr``, ``/usr/local``).  In the first
case, you need to install package XYZ before you can ``configure``,
``make``, and install MonetDB.  In the latter case, you need to tell
``configure`` via ``--with-XYZ=<DIR>`` where to find package XYZ on
your machine.  ``configure`` then looks for the header files in
<DIR>/include, and for the libraries in <DIR>/lib.

In case one of ``bootstrap``, ``configure``, or ``make`` fails ---
especially after a ``cvs update``, or after you changed some code
yourself --- try the following steps (in this order; if you are using
the pre-packaged source distribution, you can skip steps 2 and 3):

(In case you experience problems after a ``cvs update``, first make
sure that you used ``cvs update -dP`` (or have a line ``update -dP``
in your ``~/.cvsrc``); ``-d`` ensures that cvs checks out directories
that have been added since your last ``cvs update``; ``-P`` removes
directories that have become empty, because all their file have been
removed from the cvs repository.  In case you did not use ``cvs update
-dP``, re-run ``cvs update -dP``, and remember to always use ``cvs
update -dP`` from now on (or simply add a line ``update -dP`` to your
``~/.cvsrc``)!)

0) In case only ``make`` fails, you can try running::

	make clean

   in your build directory and proceed with step 5; however, if ``make``
   then still fails, you have to re-start with step 1.
1) Clean up your whole build directory (i.e., the one where you ran
   ``configure`` and ``make``) by going there and running::

	make maintainer-clean

   In case your build directory is different from your source
   directory, you are advised to remove the whole build directory.
2) Go to the top-level source directory and run::

	./de-bootstrap

   and type ``y`` when asked whether to remove the listed files.  This
   will remove all the files that were created during ``bootstrap``.
   Only do this with sources obtained through CVS.
3) In the top-level source directory, re-run::

	./bootstrap

   Only do this with sources obtained through CVS.
4) In the build-directory, re-run::

	configure

   as described above.
5) In the build-directory, re-run::

	make
	make install

   as described above.

If this still does not help, please contact us.

Reporting Problems
------------------

Bugs and other problems with compiling or running MonetDB should be
reported using the bug tracking system at SourceForge__ (preferred) or
emailed to monet@cwi.nl; see also
http://monetdb.cwi.nl/Development/Bugtracker/index.html.  Please make
sure that you give a *detailed* description of your problem!

__ https://sourceforge.net/tracker/?group_id=56967&atid=482468
