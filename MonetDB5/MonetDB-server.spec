%define name MonetDB5-server
%define version 5.18.0
%{!?buildno: %define buildno %(date +%Y%m%d)}
%define release %{buildno}%{?dist}%{?oid32:.oid32}%{!?oid32:.oid%{bits}}

# groups of related archs
%define all_x86 i386 i586 i686

%ifarch %{all_x86}
%define bits 32
%else
%define bits 64
%endif

# buildsystem is set to 1 when building an rpm from within the build
# directory; it should be set to 0 (or not set) when building a proper
# rpm
%{!?buildsystem: %define buildsystem 0}

Name: %{name}
Version: %{version}
Release: %{release}
Summary: MonetDB - Monet Database Management System
Vendor: MonetDB BV <monet@cwi.nl>

Group: Applications/Databases
License:   MPL - http://monetdb.cwi.nl/Legal/MonetDBLicense-1.1.html
URL: http://monetdb.cwi.nl/
Source: http://downloads.sourceforge.net/monetdb/MonetDB5-server-%{version}.tar.gz
BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

%{!?_with_raptor: %{!?_without_raptor: %define _with_raptor --with-raptor}}

Requires(pre): shadow-utils
BuildRequires: pcre-devel
%if %{?_with_raptor:1}%{!?_with_raptor:0}
BuildRequires: raptor-devel >= 1.4.16
%endif
BuildRequires: libxml2-devel

# when we want MonetDB to run as system daemon, we need this
# also see the scriptlets below
# the init script should implement start, stop, restart, condrestart, status
# Requires(post): /sbin/chkconfig
# Requires(preun): /sbin/chkconfig
# Requires(preun): /sbin/service
# Requires(postun): /sbin/service

%define builddoc 0

Requires: MonetDB-client >= 1.36
#                           ^^^^
# Maintained via vertoo. Please don't modify by hand!
# Contact MonetDB-developers@lists.sourceforge.net for details and/or assistance.
%if !%{?buildsystem}
BuildRequires: MonetDB-devel >= 1.36
#                               ^^^^
# Maintained via vertoo. Please don't modify by hand!
# Contact MonetDB-developers@lists.sourceforge.net for details and/or assistance.
BuildRequires: MonetDB-client-devel >= 1.36
#                                      ^^^^
# Maintained via vertoo. Please don't modify by hand!
# Contact MonetDB-developers@lists.sourceforge.net for details and/or assistance.
%endif

%package devel
Summary: MonetDB development package
Group: Applications/Databases
Requires: %{name} = %{version}-%{release}
Requires: MonetDB-devel
Requires: MonetDB-client-devel
Requires: libxml2-devel

%description
MonetDB is a database management system that is developed from a
main-memory perspective with use of a fully decomposed storage model,
automatic index management, extensibility of data types and search
accelerators, SQL- and XML- frontends.

This package contains the MonetDB5 server component.  You need this
package if you want to work using the MAL language, or if you want to
use the SQL frontend (in which case you need MonetDB-SQL-server5 as
well).

%description devel
MonetDB is a database management system that is developed from a
main-memory perspective with use of a fully decomposed storage model,
automatic index management, extensibility of data types and search
accelerators, SQL- and XML- frontends.

This package contains the files needed to develop with MonetDB5.

%prep
rm -rf $RPM_BUILD_ROOT

%setup -q -n MonetDB5-server-%{version}

%build

%configure \
	--enable-strict=no \
	--enable-assert=no \
	--enable-debug=no \
	--enable-optimize=yes \
	--enable-bits=%{bits} \
	%{?oid32:--enable-oid32} \
	%{?comp_cc:CC="%{comp_cc}"} \
	%{?_with_raptor} %{?_without_raptor}

make

%install
rm -rf $RPM_BUILD_ROOT

make install DESTDIR=$RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT/%{_localstatedir}/MonetDB
mkdir -p $RPM_BUILD_ROOT/%{_localstatedir}/MonetDB5
# insert example db here!

# cleanup stuff we don't want to install
find $RPM_BUILD_ROOT -name .incs.in -print -o -name \*.la -print | xargs rm -f
rm -rf $RPM_BUILD_ROOT%{_libdir}/MonetDB5/Tests/*

%pre
getent group monetdb >/dev/null || groupadd -r monetdb
getent passwd monetdb >/dev/null || \
useradd -r -g monetdb -d %{_localstatedir}/MonetDB -s /sbin/nologin \
    -c "MonetDB Server" monetdb
exit 0

%post
/sbin/ldconfig

# when we want MonetDB to run as system daemon, we need this
# # This adds the proper /etc/rc*.d links for the script
# /sbin/chkconfig --add monetdb5

# %preun
# if [ $1 = 0 ]; then
# 	/sbin/service monetdb5 stop >/dev/null 2>&1
# 	/sbin/chkconfig --del monetdb5
# fi

%postun
/sbin/ldconfig

# when we want MonetDB to run as system daemon, we need this
# if [ "$1" -ge "1" ]; then
# 	/sbin/service monetdb5 condrestart >/dev/null 2>&1 || :
# fi

%clean
rm -fr $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%{_bindir}/mserver5
%{_bindir}/Mbeddedmal
%{_bindir}/stethoscope

%{_libdir}/*.so.*
%dir %{_libdir}/MonetDB5
%dir %{_libdir}/MonetDB5/lib
%{_libdir}/MonetDB5/lib/*.so*
%{_libdir}/MonetDB5/*.mal

%attr(770,monetdb,monetdb) %dir %{_localstatedir}/MonetDB
%attr(770,monetdb,monetdb) %dir %{_localstatedir}/MonetDB5

%config(noreplace) %{_sysconfdir}/monetdb5.conf

%files devel
%defattr(-,root,root)
%{_bindir}/monetdb5-config
%dir %{_includedir}/MonetDB5
%dir %{_includedir}/MonetDB5/atoms
%dir %{_includedir}/MonetDB5/compiler
%dir %{_includedir}/MonetDB5/crackers
%dir %{_includedir}/MonetDB5/kernel
%dir %{_includedir}/MonetDB5/mal
%dir %{_includedir}/MonetDB5/optimizer
%dir %{_includedir}/MonetDB5/scheduler
%dir %{_includedir}/MonetDB5/rdf
%dir %{_includedir}/MonetDB5/tools
%{_includedir}/MonetDB5/*/*.[hcm]
%{_libdir}/*.so

%changelog
