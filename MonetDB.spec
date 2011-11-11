%define name MonetDB
%define version 11.8.0
%{!?buildno: %define buildno %(date +%Y%m%d)}

# groups of related archs
%define all_x86 i386 i586 i686

%ifarch %{all_x86}
%define bits 32
%else
%define bits 64
%endif

# only add .oidXX suffix if oid size differs from bit size
%if %{bits} == 64 && %{?oid32:1}%{!?oid32:0}
%define oidsuf .oid32
%endif

%define release %{buildno}%{?dist}%{?oidsuf:.oidsuf}

Name: %{name}
Version: %{version}
Release: %{release}
Summary: MonetDB - Monet Database Management System
Vendor: MonetDB BV <info@monetdb.org>

Group: Applications/Databases
License: MPL - http://www.monetdb.org/Legal/MonetDBLicense
URL: http://www.monetdb.org/
Source: http://dev.monetdb.org/downloads/sources/Aug2011-SP3/%{name}-%{version}.tar.bz2

BuildRequires: bison
BuildRequires: bzip2-devel
# BuildRequires: cfitsio-devel
BuildRequires: flex
%if %{?centos:0}%{!?centos:1}
# no geos library on CentOS
BuildRequires: geos-devel >= 2.2.0
%endif
BuildRequires: libcurl-devel
BuildRequires: libuuid-devel
BuildRequires: libxml2-devel
BuildRequires: openssl-devel
BuildRequires: pcre-devel >= 4.5
BuildRequires: perl
BuildRequires: python
# BuildRequires: raptor-devel >= 1.4.16
BuildRequires: readline-devel
BuildRequires: ruby
BuildRequires: rubygems
BuildRequires: unixODBC-devel
BuildRequires: zlib-devel

Obsoletes: %{name}-devel

%define perl_libdir %(perl -MConfig -e '$x=$Config{installvendorarch}; $x =~ s|$Config{vendorprefix}/||; print $x;')
%if ! (0%{?fedora} > 12 || 0%{?rhel} > 5)
%{!?python_sitelib: %global python_sitelib %(%{__python} -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")}
%endif
%{!?ruby_sitelib: %global ruby_sitelib %(ruby -rrbconfig -e 'puts Config::CONFIG["sitelibdir"] ')}
%define gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)

%description
MonetDB is a database management system that is developed from a
main-memory perspective with use of a fully decomposed storage model,
automatic index management, extensibility of data types and search
accelerators.  It also has an SQL frontend.

This package contains the core components of MonetDB in the form of a
single shared library.  If you want to use MonetDB, you will certainly
need this package, but you will also need one of the server packages.

%files
%defattr(-,root,root)
%{_libdir}/libbat.so.*

%package stream
Summary: MonetDB stream library
Group: Applications/Databases

%description stream
MonetDB is a database management system that is developed from a
main-memory perspective with use of a fully decomposed storage model,
automatic index management, extensibility of data types and search
accelerators.  It also has an SQL frontend.

This package contains a shared library (libstream) which is needed by
various other components.

%files stream
%defattr(-,root,root)
%{_libdir}/libstream.so.*

%package stream-devel
Summary: MonetDB stream library
Group: Applications/Databases
Requires: %{name}-stream = %{version}-%{release}
Requires: bzip2-devel
Requires: libcurl-devel
Requires: zlib-devel

%description stream-devel
MonetDB is a database management system that is developed from a
main-memory perspective with use of a fully decomposed storage model,
automatic index management, extensibility of data types and search
accelerators.  It also has an SQL frontend.

This package contains the files to develop with the %{name}-stream
library.

%files stream-devel
%defattr(-,root,root)
%dir %{_includedir}/monetdb
%{_libdir}/libstream.so
%{_libdir}/libstream.la
%{_includedir}/monetdb/stream.h
%{_includedir}/monetdb/stream_socket.h
%{_libdir}/pkgconfig/monetdb-stream.pc

%package client
Summary: MonetDB - Monet Database Management System Client Programs
Group: Applications/Databases

%description client
MonetDB is a database management system that is developed from a
main-memory perspective with use of a fully decomposed storage model,
automatic index management, extensibility of data types and search
accelerators.  It also has an SQL frontend.

This package contains mclient, the main client program to communicate
with the database server, and msqldump, a program to dump the SQL
database so that it can be loaded back later.  If you want to use
MonetDB, you will very likely need this package.

%files client
%defattr(-,root,root)
%{_bindir}/mclient
%{_bindir}/mnc
%{_bindir}/msqldump
%{_bindir}/stethoscope
%{_libdir}/libmapi.so.*
%doc %{_mandir}/man1/mclient.1.gz
%doc %{_mandir}/man1/msqldump.1.gz

%package client-devel
Summary: MonetDB - Monet Database Management System Client Programs
Group: Applications/Databases
Requires: %{name}-client = %{version}-%{release}
Requires: %{name}-stream-devel = %{version}-%{release}
Requires: openssl-devel

%description client-devel
MonetDB is a database management system that is developed from a
main-memory perspective with use of a fully decomposed storage model,
automatic index management, extensibility of data types and search
accelerators.  It also has an SQL frontend.

This package contains the files needed to develop with the
%{name}-client package.

%files client-devel
%defattr(-,root,root)
%dir %{_includedir}/monetdb
%{_libdir}/libmapi.so
%{_libdir}/libmapi.la
%{_includedir}/monetdb/mapi.h
%{_libdir}/pkgconfig/monetdb-mapi.pc

%package client-odbc
Summary: MonetDB ODBC driver
Group: Applications/Databases
Requires: %{name}-client = %{version}-%{release}
Requires(pre): unixODBC

%description client-odbc
MonetDB is a database management system that is developed from a
main-memory perspective with use of a fully decomposed storage model,
automatic index management, extensibility of data types and search
accelerators.  It also has an SQL frontend.

This package contains the MonetDB ODBC driver.

%post client-odbc
# install driver if first install of package or if driver not installed yet
if [ "$1" -eq 1 ] || ! grep -q MonetDB /etc/odbcinst.ini; then
odbcinst -i -d -r <<EOF
[MonetDB]
Description = ODBC for MonetDB
Driver = %{_exec_prefix}/lib/libMonetODBC.so
Setup = %{_exec_prefix}/lib/libMonetODBCs.so
Driver64 = %{_exec_prefix}/lib64/libMonetODBC.so
Setup64 = %{_exec_prefix}/lib64/libMonetODBCs.so
EOF
fi

%postun client-odbc
if [ "$1" -eq 0 ]; then
odbcinst -u -d -n MonetDB
fi

%files client-odbc
%defattr(-,root,root)
%{_libdir}/libMonetODBC.so
%{_libdir}/libMonetODBCs.so

%package client-php
Summary: MonetDB php interface
Group: Applications/Databases
Requires: php
BuildArch: noarch

%description client-php
MonetDB is a database management system that is developed from a
main-memory perspective with use of a fully decomposed storage model,
automatic index management, extensibility of data types and search
accelerators.  It also has an SQL frontend.

This package contains the files needed to use MonetDB from a PHP
program.

%files client-php
%defattr(-,root,root)
%dir %{_datadir}/php/monetdb
%{_datadir}/php/monetdb/*

%package client-perl
Summary: MonetDB perl interface
Group: Applications/Databases
Requires: %{name}-client = %{version}-%{release}
Requires: perl
Requires: perl(DBI)

%description client-perl
MonetDB is a database management system that is developed from a
main-memory perspective with use of a fully decomposed storage model,
automatic index management, extensibility of data types and search
accelerators.  It also has an SQL frontend.

This package contains the files needed to use MonetDB from a Perl
program.

%files client-perl
%defattr(-,root,root)
%{_prefix}/%{perl_libdir}/*

%package client-ruby
Summary: MonetDB ruby interface
Group: Applications/Databases
Requires: ruby
BuildArch: noarch

%description client-ruby
MonetDB is a database management system that is developed from a
main-memory perspective with use of a fully decomposed storage model,
automatic index management, extensibility of data types and search
accelerators.  It also has an SQL frontend.

This package contains the files needed to use MonetDB from a Ruby
program.

%files client-ruby
%defattr(-,root,root)
%docdir %{gemdir}/doc/activerecord-monetdb-adapter-0.1
%docdir %{gemdir}/doc/ruby-monetdb-sql-0.1
%{gemdir}/doc/activerecord-monetdb-adapter-0.1/*
%{gemdir}/doc/ruby-monetdb-sql-0.1/*
%{gemdir}/cache/*.gem
# %dir %{gemdir}/gems/activerecord-monetdb-adapter-0.1
# %dir %{gemdir}/gems/ruby-monetdb-sql-0.1
%{gemdir}/gems/activerecord-monetdb-adapter-0.1
%{gemdir}/gems/ruby-monetdb-sql-0.1
%{gemdir}/specifications/*.gemspec

%package client-tests
Summary: MonetDB Client tests package
Group: Applications/Databases
Requires: MonetDB5-server = %{version}-%{release}
Requires: %{name}-client = %{version}-%{release}
Requires: %{name}-client-odbc = %{version}-%{release}
Requires: %{name}-client-perl = %{version}-%{release}
Requires: %{name}-client-php = %{version}-%{release}
Requires: %{name}-SQL-server5 = %{version}-%{release}
Requires: python-monetdb = %{version}-%{release}

%description client-tests
MonetDB is a database management system that is developed from a
main-memory perspective with use of a fully decomposed storage model,
automatic index management, extensibility of data types and search
accelerators.  It also has an SQL frontend.

This package contains the sample MAPI programs used for testing other
MonetDB packages.  You probably don't need this, unless you are a
developer.

%files client-tests
%defattr(-,root,root)
%{_bindir}/odbcsample1
%{_bindir}/sample0
%{_bindir}/sample1
%{_bindir}/sample2
%{_bindir}/sample3
%{_bindir}/sample4
%{_bindir}/smack00
%{_bindir}/smack01
%{_bindir}/testgetinfo
%{_bindir}/malsample.pl
%{_bindir}/sqlsample.php
%{_bindir}/sqlsample.pl
%{_bindir}/sqlsample.py

%if %{?centos:0}%{!?centos:1}
%package geom-MonetDB5
Summary: MonetDB5 SQL GIS support module
Group: Applications/Databases
Requires: MonetDB5-server = %{version}-%{release}
Obsoletes: %{name}-geom
Obsoletes: %{name}-geom-devel

%description geom-MonetDB5
MonetDB is a database management system that is developed from a
main-memory perspective with use of a fully decomposed storage model,
automatic index management, extensibility of data types and search
accelerators.  It also has an SQL frontend.

This package contains the GIS (Geographic Information System)
extensions for MonetDB-SQL-server5.

%files geom-MonetDB5
%defattr(-,root,root)
%{_libdir}/monetdb5/autoload/*_geom.mal
%{_libdir}/monetdb5/createdb/*_geom.sql
%{_libdir}/monetdb5/geom.mal
%{_libdir}/monetdb5/lib_geom.so
%endif

%package -n MonetDB5-server
Summary: MonetDB - Monet Database Management System
Group: Applications/Databases
Requires(pre): shadow-utils
Requires: %{name}-client = %{version}-%{release}
Obsoletes: MonetDB5-server-devel
Obsoletes: MonetDB5-server-rdf

%description -n MonetDB5-server
MonetDB is a database management system that is developed from a
main-memory perspective with use of a fully decomposed storage model,
automatic index management, extensibility of data types and search
accelerators.  It also has an SQL frontend.

This package contains the MonetDB5 server component.  You need this
package if you want to work using the MAL language, or if you want to
use the SQL frontend (in which case you need MonetDB-SQL-server5 as
well).

%pre -n MonetDB5-server
getent group monetdb >/dev/null || groupadd -r monetdb
getent passwd monetdb >/dev/null || \
useradd -r -g monetdb -d %{_localstatedir}/MonetDB -s /sbin/nologin \
    -c "MonetDB Server" monetdb
exit 0

%post -n MonetDB5-server
# move database from old location to new location
if [ -d %{_localstatedir}/MonetDB5/dbfarm -a ! %{_localstatedir}/MonetDB5/dbfarm -ef %{_localstatedir}/monetdb5/dbfarm ]; then
	# old database exists and is different from new
	if [ $(find %{_localstatedir}/monetdb5 -print | wc -l) -le 2 ]; then
		# new database is still empty
		rmdir %{_localstatedir}/monetdb5/dbfarm
		rmdir %{_localstatedir}/monetdb5
		mv %{_localstatedir}/MonetDB5 %{_localstatedir}/monetdb5
	fi
fi

%files -n MonetDB5-server
%defattr(-,root,root)
%attr(750,monetdb,monetdb) %dir %{_localstatedir}/MonetDB
%attr(2770,monetdb,monetdb) %dir %{_localstatedir}/monetdb5
%attr(2770,monetdb,monetdb) %dir %{_localstatedir}/monetdb5/dbfarm
%{_bindir}/mserver5
%{_libdir}/libmonetdb5.so.*
%dir %{_libdir}/monetdb5
%dir %{_libdir}/monetdb5/autoload
%if %{?centos:0}%{!?centos:1}
%exclude %{_libdir}/monetdb5/geom.mal
%endif
# %exclude %{_libdir}/monetdb5/rdf.mal
%exclude %{_libdir}/monetdb5/sql.mal
%{_libdir}/monetdb5/*.mal
# %{_libdir}/monetdb5/autoload/*_fits.mal
%{_libdir}/monetdb5/autoload/*_vault.mal
%{_libdir}/monetdb5/autoload/*_lsst.mal
%{_libdir}/monetdb5/autoload/*_udf.mal
%if %{?centos:0}%{!?centos:1}
%exclude %{_libdir}/monetdb5/lib_geom.so
%endif
# %exclude %{_libdir}/monetdb5/lib_rdf.so
%exclude %{_libdir}/monetdb5/lib_sql.so
%{_libdir}/monetdb5/*.so
%doc %{_mandir}/man1/mserver5.1.gz

# %package -n MonetDB5-server-rdf
# Summary: MonetDB RDF interface
# Group: Applications/Databases
# Requires: MonetDB5-server = %{version}-%{release}

# %description -n MonetDB5-server-rdf
# MonetDB is a database management system that is developed from a
# main-memory perspective with use of a fully decomposed storage model,
# automatic index management, extensibility of data types and search
# accelerators.  It also has an SQL frontend.

# This package contains the MonetDB5 RDF module.

# %files -n MonetDB5-server-rdf
# %defattr(-,root,root)
# %{_libdir}/monetdb5/autoload/*_rdf.mal
# %{_libdir}/monetdb5/lib_rdf.so
# %{_libdir}/monetdb5/rdf.mal
# %{_libdir}/monetdb5/createdb/*_rdf.sql

%package SQL-server5
Summary: MonetDB5 SQL server modules
Group: Applications/Databases
Requires: MonetDB5-server = %{version}-%{release}
%if (0%{?fedora} > 14)
# for systemd-tmpfiles
Requires: systemd-units
%endif
Obsoletes: MonetDB-SQL-devel
Obsoletes: %{name}-SQL

%description SQL-server5
MonetDB is a database management system that is developed from a
main-memory perspective with use of a fully decomposed storage model,
automatic index management, extensibility of data types and search
accelerators.  It also has an SQL frontend.

This package contains the SQL frontend for MonetDB5.  If you want to
use SQL with MonetDB, you will need to install this package.

%if (0%{?fedora} > 14)
%post SQL-server5
systemd-tmpfiles --create %{_sysconfdir}/tmpfiles.d/monetdbd.conf
%endif

%files SQL-server5
%defattr(-,root,root)
%{_bindir}/monetdb
%{_bindir}/monetdbd
%dir %attr(775,monetdb,monetdb) %{_localstatedir}/log/monetdb
%if (0%{?fedora} > 14)
# Fedora 15 and newer
%{_sysconfdir}/tmpfiles.d/monetdbd.conf
%else
# Fedora 14 and older
%dir %attr(775,monetdb,monetdb) %{_localstatedir}/run/monetdb
%exclude %{_sysconfdir}/tmpfiles.d/monetdbd.conf
%endif
%config(noreplace) %{_localstatedir}/monetdb5/dbfarm/.merovingian_properties
%{_libdir}/monetdb5/autoload/*_sql.mal
%{_libdir}/monetdb5/lib_sql.so
%{_libdir}/monetdb5/*.sql
%dir %{_libdir}/monetdb5/createdb
%if %{?centos:0}%{!?centos:1}
%exclude %{_libdir}/monetdb5/createdb/*_geom.sql
%endif
# %exclude %{_libdir}/monetdb5/createdb/*_rdf.sql
%{_libdir}/monetdb5/createdb/*
%{_libdir}/monetdb5/sql*.mal
%doc %{_mandir}/man1/monetdb.1.gz
%doc %{_mandir}/man1/monetdbd.1.gz
%docdir %{_datadir}/doc/MonetDB-SQL-%{version}
%{_datadir}/doc/MonetDB-SQL-%{version}/*

%package -n python-monetdb
Summary: Native MonetDB client Python API
Group: Applications/Databases
Requires: python
BuildArch: noarch
Obsoletes: MonetDB-client-python

%description -n python-monetdb
MonetDB is a database management system that is developed from a
main-memory perspective with use of a fully decomposed storage model,
automatic index management, extensibility of data types and search
accelerators.  It also has an SQL frontend.

This package contains the files needed to use MonetDB from a Python
program.

%files -n python-monetdb
%defattr(-,root,root)
%dir %{python_sitelib}/monetdb
%{python_sitelib}/monetdb/*
%{python_sitelib}/python_monetdb-*.egg-info
%doc clients/python/README.rst

%package testing
Summary: MonetDB - Monet Database Management System
Group: Applications/Databases
Obsoletes: MonetDB-python

%description testing
MonetDB is a database management system that is developed from a
main-memory perspective with use of a fully decomposed storage model,
automatic index management, extensibility of data types and search
accelerators.  It also has an SQL frontend.

This package contains the programs and files needed for testing the
MonetDB packages.  You probably don't need this, unless you are a
developer.  If you do want to test, install %{name}-testing-python.

%files testing
%defattr(-,root,root)
%{_bindir}/Mdiff
%{_bindir}/MkillUsers
%{_bindir}/Mlog
%{_bindir}/Mtimeout

%package testing-python
Summary: MonetDB - Monet Database Management System
Group: Applications/Databases
Requires: %{name}-testing = %{version}-%{release}
Requires: %{name}-client-tests = %{version}-%{release}
Requires: python
BuildArch: noarch

%description testing-python
MonetDB is a database management system that is developed from a
main-memory perspective with use of a fully decomposed storage model,
automatic index management, extensibility of data types and search
accelerators.  It also has an SQL frontend.

This package contains the Python programs and files needed for testing
the MonetDB packages.  You probably don't need this, unless you are a
developer, but if you do want to test, this is the package you need.

%files testing-python
%defattr(-,root,root)
# at least F12 doesn't produce these
# %exclude %{_bindir}/*.pyc
# %exclude %{_bindir}/*.pyo
%{_bindir}/Mapprove.py
%{_bindir}/Mfilter.py
%{_bindir}/Mtest.py
%dir %{python_sitelib}/MonetDBtesting
%{python_sitelib}/MonetDBtesting/*

%prep
%setup -q

%build

%{configure} \
	--enable-assert=no \
	--enable-bits=%{bits} \
	--enable-console=yes \
	--enable-crackers=no \
	--enable-datacell=no \
	--enable-debug=no \
	--enable-developer=no \
	--enable-fits=no \
	--enable-gdk=yes \
	--enable-geom=%{?centos:no}%{!?centos:yes} \
	--enable-instrument=no \
	--enable-jdbc=no \
	--enable-merocontrol=no \
	--enable-monetdb5=yes \
	--enable-noexpand=no \
	--enable-odbc=yes \
	--enable-oid32=%{?oid32:yes}%{!?oid32:no} \
	--enable-optimize=yes \
	--enable-profile=no \
	--enable-rdf=no \
	--enable-sql=yes \
	--enable-strict=no \
	--enable-testing=yes \
	--with-ant=no \
	--with-bz2=yes \
	--with-geos=%{?centos:no}%{!?centos:yes} \
	--with-hwcounters=no \
	--with-java=no \
	--with-mseed=no \
	--with-perl=yes \
	--with-pthread=yes \
	--with-python=yes \
	--with-readline=yes \
	--with-rubygem=yes \
	--with-sphinxclient=no \
	--with-unixodbc=yes \
	--with-valgrind=no \
	%{?comp_cc:CC="%{comp_cc}"}

make

%install
rm -rf $RPM_BUILD_ROOT

%makeinstall

mkdir -p $RPM_BUILD_ROOT%{_localstatedir}/MonetDB
mkdir -p $RPM_BUILD_ROOT%{_localstatedir}/monetdb5/dbfarm
mkdir -p $RPM_BUILD_ROOT%{_localstatedir}/log/monetdb
mkdir -p $RPM_BUILD_ROOT%{_localstatedir}/run/monetdb

# remove unwanted stuff
# .la files
rm -f $RPM_BUILD_ROOT%{_libdir}/monetdb5/*.la
# internal development stuff
rm -f $RPM_BUILD_ROOT%{_bindir}/calibrator
rm -f $RPM_BUILD_ROOT%{_bindir}/Maddlog
rm -f $RPM_BUILD_ROOT%{_libdir}/libbat.la
rm -f $RPM_BUILD_ROOT%{_libdir}/libbat.so
rm -f $RPM_BUILD_ROOT%{_libdir}/libMonetODBC*.la
rm -f $RPM_BUILD_ROOT%{_libdir}/libmonet.la
rm -f $RPM_BUILD_ROOT%{_libdir}/libmonet.so
rm -f $RPM_BUILD_ROOT%{_libdir}/libmonetdb5.la
rm -f $RPM_BUILD_ROOT%{_libdir}/libmonetdb5.so

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%clean
rm -fr $RPM_BUILD_ROOT

%changelog
* Fri Nov 11 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.9-20111111
- Rebuilt.

* Sun Nov  6 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.9-20111111
- merovingian: Fixed a bug where monetdbd's socket files from /tmp were removed when
  a second monetdbd was attempted to be started using the same port.

* Wed Oct 26 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.9-20111111
- sql: Added a fix for bug #2834, which caused weird (failing) behaviour
  with PreparedStatements.

* Fri Oct 21 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.5.7-20111021
- Rebuilt.

* Thu Oct 20 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.5.7-20111021
- clients: ODBC: Implemented a workaround in SQLTables for bug 2908.

* Tue Oct 18 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.5.5-20111018
- Rebuilt.

* Mon Oct 17 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.5-20111018
- clients: Small improvement to mclient's table rendering for tables without
  any rows.  Previously, the column names in the header could be
  squeezed to very small widths, degrading readability.

* Wed Oct 12 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.5-20111018
- clients: Python DB API connect() function now supports PEP 249-style arguments
  user and host, bug #2901

* Wed Oct 12 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.5.5-20111018
- clients: mclient now checks the result of encoding conversions using the iconv
  library.

* Mon Oct 10 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.5.5-20111018
- clients: Fixed a source of crashes in mclient when a query on the command line
  using the -s option is combined with input on standard input (e.g. in
  the construct mclient -s 'COPY INTO t FROM STDIN ...' < file.csv).

* Sun Oct  9 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.5-20111018
- merovingian: Resolved problem where monetdbd would terminate abnormally when
  databases named 'control', 'discovery' or 'merovingian' were stopped.

* Fri Oct  7 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.5-20111018
- merovingian: monetdbd get status now also reports the version of the running monetdbd

* Fri Oct  7 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.5.5-20111018
- clients: Fixed bug 2897 where slow (network) reads could cause blocks to not
  be fully read in one go, causing errors in the subsequent use of
  those blocks.  With thanks to Rémy Chibois.

* Thu Oct  6 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.5-20111018
- merovingian: Improved response time of 'monetdb start' when the database fails
  to start.

* Wed Oct  5 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.5-20111018
- merovingian: Fixed a bug in monetdbd where starting a failing database could
  incorrectly be reported as a 'running but dead' database.

* Fri Sep 30 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.5-20111018
- merovingian: To avoid confusion, all occurrences of merovingian were changed into
  monetdbd for error messages sent to a client.

* Tue Sep 27 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.5-20111018
- clients: Fixed a bug in mclient where processing queries from files could result
  in ghost empty results to be reported in the output

* Sun Sep 25 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.3-20110925
- Rebuilt.

* Fri Sep 23 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.3-20110925
- clients: Fixed Perl DBD rowcount for larger results, bug #2889

* Wed Sep 21 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.5.3-20110925
- monetdb5: Fixed a problem where MAL variables weren't properly cleared before
  reuse of the data strucutre.  This problem could cause the data flow
  scheduler to generate dependencies between instructions that didn't
  actually exist, which in turn could cause circular dependencies among
  instructions with deadlock as a result.  Bugs 2865 and 2888.

* Wed Sep 21 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.5.3-20110925
- sql: Fixed a bug when using default values for interval columns.  Bug 2877.

* Mon Sep 19 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.5.3-20110925
- clients: Perl: We now distinguish properly between TABLE and GLOBAL TEMPORARY
  (the latter are recognized by being in the "tmp" schema).
- clients: Perl: fixed a bunch of syntax errors.  This fixes bug 2884.  With thanks
  to Rémy Chibois.
- clients: Perl: Fixed DBD::monetdb table_info and tabletype_info.  This fixes
  bug 2885.  With thanks to Rémy Chibois.

* Fri Sep 16 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.5.3-20110925
- sql: A bug was fixed where deleted rows weren't properly accounted for in
  all operations.  This was bug 2882.
- sql: A bug was fixed which caused an update to an internal table to
  happen too soon.  The bug could be observed on a multicore system
  with a query INSERT INTO t (SELECT * FROM t) when the table t is
  "large enough".  This was bug 2883.

* Tue Sep 13 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.5.3-20110925
- clients: mclient: fix display of varchar columns with only NULL values.
- clients: Fixed a bug in mclient/msqldump where an internal error occurred during
  dump when there are GLOBAL TEMPORARY tables.

* Wed Sep 07 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.5.1-20110907
- Rebuilt.

* Wed Aug 31 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.5.1-20110907
- clients: msqldump now also accepts the database name as last argument on the
  command line (i.e. without -d).

* Fri Aug 26 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.1-20110907
- clients: Made error messages from the server in mclient go to stderr, instead
  of stdout.

* Thu Aug 25 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.5.1-20110907
- gdk: Removed conversion code for databases that still used the (more than
  two year) old format of "string heaps".

* Tue Aug 23 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.1-20110907
- merovingian: Fixed confusing 'Success' error message for monetdb commands where an
  invalid hostname was given

* Fri Aug 19 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.1-20110907
- merovingian: The path to the mserver5 binary is no longer returned for the mserver
  property with monetdbd get for a dbfarm which is currently served by
  a monetdbd.  Since the called monetdbd needs not to be the same as
  the running monetdbd, the reported mserver5 binary may be incorrect,
  and obviously lead to confusing situations.  Refer to the running
  monetdbd's logfile to determine the mserver5 binary location instead.

* Thu Aug 18 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.5.1-20110907
- clients: Implemented SQL_ATTR_METADATA_ID attribute.  The attribute is used
  in SQLColumns, SQLProcedures, and SQLTablePrivileges.
- clients: Implemented SQLTablePrivileges in the ODBC driver.

* Wed Aug 17 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.1-20110907
- merovingian: Added -n option to monetdbd start command, which prevents monetdbd
  from forking into the background.

* Wed Aug 10 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.5.1-20110907
- gdk: On Windows and Linux/Unix we can now read databases built on the other
  O/S, as long as the hardware-related architecture (bit size, floating
  point format, etc.) is identical.

* Sat Aug  6 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.1-20110907
- merovingian: Fix incorrect (misleading) path for pidfile in pidfile error message,
  bug #2851

* Sat Aug  6 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.5.1-20110907
- buildtools: Fixed Fedora 15 (and presumably later) configuration that uses a tmpfs
  file system for /var/run.  This fixes bug 2850.

* Fri Aug  5 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.5.1-20110907
- clients: mclient now automatically sets the SQL `TIME ZONE' variable to its
  (the client's) time zone.

* Fri Jul 29 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.5.1-20110907
- geom: Implemented NULL checks in the geom module.  Now when given NULL
  as input, the module functions return NULL instead of an exception.
  This fixes bug 2814.

* Tue Jul 26 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.1-20110907
- clients: Removed perl/Cimpl, MonetDB-CLI-MapiLib and MonetDB-CLI-MapiXS
- clients: Switched implementation of MonetDB::CLI::MapiPP to Mapi.pm, and made
  it the default MonetDB::CLI provider.

* Tue Jul 26 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.5.1-20110907
- buildtools: The default OID size for 64-bit Windows is now 64 bits.  Databases with
  32 bit OIDs are converted automatically.

* Tue Jul 26 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.1-20110907
- clients: Made Mapi.pm usable with current versions of MonetDB again

* Tue Jul 26 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.1-20110907
- monetdb5: Make crackers optional and disable by default, since it wasn't used
  normally

* Tue Jul 26 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.1-20110907
- java: Add so_timeout Driver property to specify a SO_TIMEOUT value for the
  socket in use to the database.  Setting this property to a value in
  milliseconds defines the timeout for read calls, which may 'unlock'
  the driver if the server hangs, bug #2828

* Tue Jul 26 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.1-20110907
- java: Added a naive implementation for PreparedStatement.setCharacterStream

* Tue Jul 26 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.5.1-20110907
- gdk: Implemented automatic conversion of a 64-bit database with 32-bit OIDs
  to one with 64-bit OIDs.

* Tue Jul 26 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.1-20110907
- merovingian: added status property to get command

* Tue Jul 26 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.1-20110907
- monetdb5: Authorisation no longer takes scenarios into account.  Access for only
  sql or mal is no longer possible.  Any credentials now mean access to
  all scenarios that the server has available.

* Tue Jul 26 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.1-20110907
- clients: When the first non-option argument of mclient does not refer to an
  exising file, it now is taken as database name.  This allows to simply
  do `mclient mydb`.

* Tue Jul 26 2011 Fabian Groffen <fabian@cwi.nl> - 11.5.1-20110907
- java: The obsolete Java-based implementation for PreparedStatements (formerly
  activated using the java_prepared_statements property) has been dropped

* Tue Jul 26 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.3.7-20110726
- Rebuilt.

* Wed Jul 20 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.3.5-20110720
- Rebuilt.

* Tue Jul 19 2011 Fabian Groffen <fabian@cwi.nl> - 11.3.5-20110720
- sql: Fixed regression where the superuser password could no longer be
  changed, bug #2844

* Wed Jul 13 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.3.5-20110720
- buildtools: We can now build RPMs on CentOS 6.0.  Since there is no geos library
  on CentOS, we do not support the geom modules there.

* Sat Jul  9 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.3.5-20110720
- gdk: Fixed a problem where appending string BATs could cause enormous growth
  of the string heap.  This fixes bug 2820.

* Fri Jul  8 2011 Fabian Groffen <fabian@cwi.nl> - 11.3.5-20110720
- java: Return false from Statement.getMoreResults() instead of a
  NullPointerException when no query has been performed on the Statement
  yet, bug #2833

* Fri Jul  1 2011 Fabian Groffen <fabian@cwi.nl> - 11.3.5-20110720
- clients: Fix stethoscope's mod.fcn filter when using multiple targets, bug #2827

* Wed Jun 29 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.3.5-20110720
- buildtools: We can now also build on Fedora 15.  This required some very minor
  changes.
- buildtools: Changed configure check for OpenSSL so that we can also build on CentOS
  5.6.  We now no longer demand that OpenSSL is at least version 0.9.8f,
  but instead we require that the hash functions we need are supported.

* Wed Jun 29 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.3.5-20110720
- clients: The separate Python distribution now uses the same version number as
  the main package.

* Wed Jun 29 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.3.5-20110720
- gdk: Fixes to memory detection on FreeBSD.

* Wed Jun 29 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.3.5-20110720
- sql: Fixed incorrect insert counts.
- sql: Fixed bug 2823: MAL exeption on SQL query with subquery in the where
  part.
- sql: Redirect error from create scripts back to the first client.  This
  fixes bug 2813.
- sql: Added joinidx based semijoin; push join through union (using
  joinidx).
- sql: Fixed pushing select down.

* Mon Jun  6 2011 Fabian Groffen <fabian@cwi.nl> - 11.3.5-20110720
- java: Fixed read-only interpretation.  Connection.isReadOnly now always
  returns false, setReadOnly now generates a warning when called with
  true.  Partly from bug #2818
- java: Allow readonly to be set when autocommit is disabled as well.  Bug #2818

* Tue May 17 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.3.3-20110517
- Rebuilt.

* Fri May 13 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.3.3-20110517
- gdk: Fixed a bug where large files (> 2GB) didn't always get deleted on
Windows.

* Wed May 11 2011 Fabian Groffen <fabian@cwi.nl> - 11.3.3-20110517
- java: Insertion via PreparedStatement and retrieval via ResultSet of timestamp
and time fields with and without timezones was improved to better
respect timezones, as partly indicated in bug #2781.

* Wed May 11 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.3.3-20110517
- monetdb5: Fixed a bug in conversion from string to the URL type.  The bug was
an incorrect call to free().

* Wed Apr 27 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.3.3-20110517
- geom: Fixed various problems so that now all our tests work correctly on
all our testing platforms.

* Thu Apr 21 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.3.1-20110421
- Rebuilt.

* Mon Apr 18 2011 Fabian Groffen <fabian@cwi.nl> - 11.3.1-20110421
- merovingian: Fix monetdb return code upon failure to start/stop a database

* Thu Apr 14 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.3.1-20110414
- Rebuilt.

* Thu Apr 14 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.3.1-20110414
- gdk: Fixed bugs in antiselect which gave the incorrect result when upper
  and lower bound were equal.  This bug could be triggered by the SQL
  query SELECT * FROM t WHERE x NOT BETWEEN y AND y.

* Thu Apr 14 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.3.1-20110414
- sql: Some names in the SQL catalog were changed.  This means that the
  database in the Apr2011 release is not compatible with pre-Apr2011
  databases.  The database is converted automatically when opened the
  first time.  This database can then no longer be read by an older
  release.

* Tue Apr  5 2011 Fabian Groffen <fabian@cwi.nl> - 11.3.1-20110414
- clients: Plugged a small memory leak occurring upon redirects by the server
  (e.g. via monetdbd)

* Tue Apr  5 2011 Fabian Groffen <fabian@cwi.nl> - 11.3.1-20110414
- java: clarify exception messages for unsupported methods

* Thu Mar 24 2011 Fabian Groffen <fabian@cwi.nl> - 11.3.1-20110414
- merovingian: The forward property for databases has been removed.  Instead, only
  a global proxy or redirect mode can be set using monetdbd.

* Thu Mar 24 2011 Fabian Groffen <fabian@cwi.nl> - 11.3.1-20110414
- merovingian: monetdbd can no longer log error and normal messages to separate
  logfiles, logging to stdout and stderr is no longer possible either.
- merovingian: The .merovingian_pass file is no longer in use, and replaced by the
  .merovingian_properties file.  Use monetdbd (get|set) passphrase to
  view/edit the control passphrase.  Existing .merovingian_pass files
  will automatically be migrated upon startup of monetdbd.
- merovingian: monetdbd now understands commands that allow to create, start, stop,
  get and set properties on a given dbfarm.  This behaviour is intended
  as primary way to start a MonetDB Database Server, on a given location
  of choice.  monetdbd get and set are the replacement of editing the
  monetdb5.conf file (which is no longer in use as of the Apr2011
  release).  See monetdbd(1).

* Thu Mar 24 2011 Fabian Groffen <fabian@cwi.nl> - 11.3.1-20110414
- clients: Remove XQuery related code from Ruby adapter, PHP driver and Perl Mapi
  library

* Thu Mar 24 2011 Fabian Groffen <fabian@cwi.nl> - 11.3.1-20110414
- java: Removed XQuery related XRPC wrapper and XML:DB code, removed support
  for language=xquery and language=mil from JDBC.

* Thu Mar 24 2011 Fabian Groffen <fabian@cwi.nl> - 11.3.1-20110414
- clients: Make SQL the default language for mclient, e.g. to use when --language=
  or -l is omitted

* Thu Mar 24 2011 Fabian Groffen <fabian@cwi.nl> - 11.3.1-20110414
- monetdb5: mserver5 no longer reads monetdb5.conf upon startup by default.
  Use --config=file to have mserver5 read a configuration on startup

* Thu Mar 24 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.1.1-20110324
- Rebuilt.

* Tue Mar 22 2011 Fabian Groffen <fabian@cwi.nl> - 11.1.1-20110324
- gdk: Fixed memory detection on Darwin (Mac OS X) systems not to return
  bogus values

* Thu Mar 17 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.1.1-20110317
- Rebuilt.

* Tue Mar 15 2011 Fabian Groffen <fabian@cwi.nl> - 11.1.1-20110317
- geom: Set endianness for wkb en/decoding.

* Sat Mar 05 2011 Stefan de Konink <stefan@konink.de> - 11.1.1-20110317
- monetdb5: sphinx module: update, adding limit/max_results support

* Mon Feb 14 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.1.1-20110317
- clients: Fixed bug 2677: SQL_DESC_OCTET_LENGTH should give the size in bytes
  required to copy the data.

* Mon Jan 24 2011 Fabian Groffen <fabian@cwi.nl> - 11.1.1-20110317
- clients: Disable timer functionality for non-XQuery languages since it is
  incorrect, bug #2705

* Mon Jan 24 2011 Fabian Groffen <fabian@cwi.nl> - 11.1.1-20110317
- sql: Fix bug #2648, do not allow restarting a sequence with NULL via the
  result of a sub-query.

* Fri Jan 14 2011 Fabian Groffen <fabian@cwi.nl> - 11.1.1-20110317
- gdk: MonetDB/src/gdk was moved to gdk

* Tue Jan  4 2011 Fabian Groffen <fabian@cwi.nl> - 11.1.1-20110317
- clients: Added mapi_get_uri function to retrieve mapi URI for the connection

* Tue Jan  4 2011 Fabian Groffen <fabian@cwi.nl> - 11.1.1-20110317
- merovingian: Allow use of globs with all commands that accept database names as
  their parameters

* Tue Jan  4 2011 Fabian Groffen <fabian@cwi.nl> - 11.1.1-20110317
- java: PreparedStatements now free the server-side resources attached to them
  when closed.  This implements bug #2720

* Tue Jan  4 2011 Niels Nes <niels@cwi.nl> - 11.1.1-20110317
- sql: Allow clients to release prepared handles using Xrelease commands

* Tue Jan  4 2011 Fabian Groffen <fabian@cwi.nl> - 11.1.1-20110317
- clients: Allow to dump table data using INSERT INTO statements, rather than COPY
  INTO + CSV data using the -N/--inserts flag of mclient and msqldump.
  Bug #2727

* Tue Jan  4 2011 Fabian Groffen <fabian@cwi.nl> - 11.1.1-20110317
- clients: Added support for \dn to list schemas or describe a specific one

* Tue Jan  4 2011 Fabian Groffen <fabian@cwi.nl> - 11.1.1-20110317
- clients: Added support for \df to list functions or describe a specific one
- clients: Added support for \ds to list sequences or describe a specific one

* Tue Jan  4 2011 Fabian Groffen <fabian@cwi.nl> - 11.1.1-20110317
- clients: Added support for wildcards * and ? in object names given to \d
  commands, such that pattern matching is possible, e.g. \d my*
- clients: Added support for \dS that lists also system tables

* Tue Jan  4 2011 Fabian Groffen <fabian@cwi.nl> - 11.1.1-20110317
- clients: object names given to \d are now lowercased, unless quoted by either
  single or double quotes
- clients: Strip any trailing whitespace with the \d command

* Tue Jan  4 2011 Fabian Groffen <fabian@cwi.nl> - 11.1.1-20110317
- merovingian: merovingian has been renamed into monetdbd.  Internally, monetdbd keeps
  referring to merovingian for e.g. settings and logfiles.  Merovingian
  has been renamed to make the process more recognisable as part of the
  MonetDB suite.

* Tue Jan  4 2011 Fabian Groffen <fabian@cwi.nl> - 11.1.1-20110317
- monetdb5: Improve the performance of remote.put for BAT arguments.  The put
  speed is now roughly equal to the speed of get on a BAT.

* Tue Jan  4 2011 Sjoerd Mullender <sjoerd@acm.org> - 11.0.0-0
- Created top-level bootstrap/configure/make with new version numbers.

