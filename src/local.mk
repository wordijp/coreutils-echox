# Make coreutils programs.                             -*-Makefile-*-
# This is included by the top-level Makefile.am.

## Copyright (C) 1990-2016 Free Software Foundation, Inc.

## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

# FIXME: once lib/ and gnulib-tests/ are also converted, hoist to Makefile.am
AM_CFLAGS = $(WERROR_CFLAGS)

# The list of all programs (separated in different variables to express
# the how and when they should be installed) is defined in this makefile
# fragment, autogenerated by the 'gen-lists-of-programs.sh' auxiliary
# script.
include $(srcdir)/src/cu-progs.mk

EXTRA_PROGRAMS = \
   $(no_install__progs) \
   $(build_if_possible__progs) \
   $(default__progs)

# The user can tweak these lists at configure time.
bin_PROGRAMS = @bin_PROGRAMS@
pkglibexec_PROGRAMS = @pkglibexec_PROGRAMS@

# Needed by the testsuite.
noinst_PROGRAMS =

noinst_HEADERS =

EXTRA_DIST +=

CLEANFILES += $(SCRIPTS)

# Also remove these sometimes-built programs.
# For example, even when excluded, they're built via 'sc_check-AUTHORS'
# or 'dist'.
CLEANFILES += $(no_install__progs)

noinst_LIBRARIES += src/libver.a
nodist_src_libver_a_SOURCES = src/version.c src/version.h

# Tell the linker to omit references to unused shared libraries.
AM_LDFLAGS = $(IGNORE_UNUSED_LIBRARIES_CFLAGS)

# Extra libraries needed by more than one program.  Will be updated later.
copy_ldadd =
remove_ldadd =

# Sometimes, the expansion of $(LIBINTL) includes -lc which may
# include modules defining variables like 'optind', so libcoreutils.a
# must precede $(LIBINTL) in order to ensure we use GNU getopt.
# But libcoreutils.a must also follow $(LIBINTL), since libintl uses
# replacement functions defined in libcoreutils.a.
LDADD = src/libver.a lib/libcoreutils.a $(LIBINTL) lib/libcoreutils.a

# First, list all programs, to make listing per-program libraries easier.

src_echox_LDADD = $(LDADD)


# for eaccess, euidaccess
copy_ldadd += $(LIB_EACCESS)
remove_ldadd += $(LIB_EACCESS)

# Get the release year from lib/version-etc.c.
RELEASE_YEAR = \
  `sed -n '/.*COPYRIGHT_YEAR = \([0-9][0-9][0-9][0-9]\) };/s//\1/p' \
    $(top_srcdir)/lib/version-etc.c`

selinux_sources = \
  src/selinux.c \
  src/selinux.h

copy_sources = \
  src/copy.c \
  src/cp-hash.c \
  src/extent-scan.c \
  src/extent-scan.h

# Use 'ginstall' in the definition of PROGRAMS and in dependencies to avoid
# confusion with the 'install' target.  The install rule transforms 'ginstall'
# to install before applying any user-specified name transformations.

# Don't apply prefix transformations to libstdbuf shared lib
# as that's not generally needed, and we need to reference the
# name directly in LD_PRELOAD etc.  In general it's surprising
# that $(transform) is applied to libexec at all given that is
# for internal package naming, not privy to $(transform).

transform = s/ginstall/install/;/libstdbuf/!$(program_transform_name)

BUILT_SOURCES += src/coreutils.h

CLEANFILES += src/coreutils_symlinks
src/coreutils_symlinks: Makefile
	$(AM_V_GEN)touch $@
	$(AM_V_at)${MKDIR_P} src
	$(AM_V_at)for i in x $(single_binary_progs); do \
		test $$i = x && continue; \
		rm -f src/$$i$(EXEEXT) || exit $$?; \
		$(LN_S) -s coreutils$(EXEEXT) src/$$i$(EXEEXT) || exit $$?; \
	done

CLEANFILES += src/coreutils_shebangs
src/coreutils_shebangs: Makefile
	$(AM_V_GEN)touch $@
	$(AM_V_at)${MKDIR_P} src
	$(AM_V_at)for i in x $(single_binary_progs); do \
		test $$i = x && continue; \
		rm -f src/$$i$(EXEEXT) || exit $$?; \
		printf '#!%s --coreutils-prog-shebang=%s\n' \
			$(abs_top_builddir)/src/coreutils$(EXEEXT) $$i \
			>src/$$i$(EXEEXT) || exit $$?; \
		chmod a+x,a-w src/$$i$(EXEEXT) || exit $$?; \
	done

clean-local:
	$(AM_V_at)for i in x $(single_binary_progs); do \
		test $$i = x && continue; \
		rm -f src/$$i$(EXEEXT) || exit $$?; \
	done


BUILT_SOURCES += src/dircolors.h
src/dircolors.h: src/dcgen src/dircolors.hin
	$(AM_V_GEN)rm -f $@ $@-t
	$(AM_V_at)${MKDIR_P} src
	$(AM_V_at)$(PERL) -w -- $(srcdir)/src/dcgen \
				$(srcdir)/src/dircolors.hin > $@-t
	$(AM_V_at)chmod a-w $@-t
	$(AM_V_at)mv $@-t $@

# This file is built by maintainers.  It's architecture-independent,
# and it needs to be built on a widest-known-int architecture, so it's
# built only if absent.  It is not cleaned because we don't want to
# insist that maintainers must build on hosts that support the widest
# known ints (currently 128-bit).
BUILT_SOURCES += $(top_srcdir)/src/primes.h
$(top_srcdir)/src/primes.h:
	$(AM_V_at)${MKDIR_P} src
	$(MAKE) src/make-prime-list$(EXEEXT)
	$(AM_V_GEN)rm -f $@ $@-t
	$(AM_V_at)src/make-prime-list$(EXEEXT) 5000 > $@-t
	$(AM_V_at)chmod a-w $@-t
	$(AM_V_at)mv $@-t $@

# false exits nonzero even with --help or --version.
# test doesn't support --help or --version.
# Tell automake to exempt then from that installcheck test.
AM_INSTALLCHECK_STD_OPTIONS_EXEMPT = src/false src/test

# Compare fs.h with the list of file system names/magic-numbers in the
# Linux statfs man page.  This target prints any new name/number pairs.
# Also compare against /usr/include/linux/magic.h
.PHONY: src/fs-magic-compare
src/fs-magic-compare: src/fs-magic src/fs-kernel-magic src/fs-def
	@join -v1 -t@ src/fs-magic src/fs-def
	@join -v1 -t@ src/fs-kernel-magic src/fs-def

CLEANFILES += src/fs-def
src/fs-def: src/fs.h
	grep '^# *define ' src/fs.h | $(ASSORT) > $@-t && mv $@-t $@

# Massage bits of the statfs man page and definitions from
# /usr/include/linux/magic.h to be in a form consistent with what's in fs.h.
fs_normalize_perl_subst =			\
  -e 's/MINIX_SUPER_MAGIC\b/MINIX/;'		\
  -e 's/MINIX_SUPER_MAGIC2\b/MINIX_30/;'	\
  -e 's/MINIX2_SUPER_MAGIC\b/MINIX_V2/;'	\
  -e 's/MINIX2_SUPER_MAGIC2\b/MINIX_V2_30/;'	\
  -e 's/MINIX3_SUPER_MAGIC\b/MINIX_V3/;'	\
  -e 's/CIFS_MAGIC_NUMBER/CIFS/;'		\
  -e 's/(_SUPER)?_MAGIC//;'			\
  -e 's/\s+0x(\S+)/" 0x" . uc $$1/e;'		\
  -e 's/(\s+0x)(\X{3})\b/$${1}0$$2/;'		\
  -e 's/(\s+0x)(\X{6})\b/$${1}00$$2/;'		\
  -e 's/(\s+0x)(\X{7})\b/$${1}0$$2/;'		\
  -e 's/^\s+//;'				\
  -e 's/^\043define\s+//;'			\
  -e 's/^_(XIAFS)/$$1/;'			\
  -e 's/^USBDEVICE/USBDEVFS/;'			\
  -e 's/NTFS_SB/NTFS/;'				\
  -e 's/^/\043 define S_MAGIC_/;'		\
  -e 's,\s*/\* .*? \*/,,;'

CLEANFILES += src/fs-magic
src/fs-magic: Makefile
	@MANPAGER= man statfs \
	  |perl -ne '/File system types:/.../Nobody kno/ and print'	\
	  |grep 0x | perl -p						\
	    $(fs_normalize_perl_subst)					\
	  | grep -Ev 'S_MAGIC_EXT[34]|STACK_END'			\
	  | $(ASSORT)							\
	  > $@-t && mv $@-t $@

DISTCLEANFILES += src/fs-latest-magic.h
# This rule currently gets the latest header, but probably isn't general
# enough to enable by default.
#	@kgit='https://git.kernel.org/cgit/linux/kernel/git'; \
#	wget -q $$kgit/torvalds/linux.git/plain/include/uapi/linux/magic.h \
#	  -O $@
src/fs-latest-magic.h:
	@touch $@

CLEANFILES += src/fs-kernel-magic
src/fs-kernel-magic: Makefile src/fs-latest-magic.h
	@perl -ne '/^#define.*0x/ and print'				\
	  /usr/include/linux/magic.h src/fs-latest-magic.h		\
	  | perl -p							\
	    $(fs_normalize_perl_subst)					\
	  | grep -Ev 'S_MAGIC_EXT[34]|STACK_END'			\
	  | $(ASSORT) -u						\
	  > $@-t && mv $@-t $@

BUILT_SOURCES += src/fs-is-local.h
src/fs-is-local.h: src/stat.c src/extract-magic
	$(AM_V_GEN)rm -f $@
	$(AM_V_at)${MKDIR_P} src
	$(AM_V_at)$(PERL) $(srcdir)/src/extract-magic \
			  --local $(srcdir)/src/stat.c > $@t
	$(AM_V_at)chmod a-w $@t
	$(AM_V_at)mv $@t $@

BUILT_SOURCES += src/fs.h
src/fs.h: src/stat.c src/extract-magic
	$(AM_V_GEN)rm -f $@
	$(AM_V_at)${MKDIR_P} src
	$(AM_V_at)$(PERL) $(srcdir)/src/extract-magic \
			  $(srcdir)/src/stat.c > $@t
	$(AM_V_at)chmod a-w $@t
	$(AM_V_at)mv $@t $@

BUILT_SOURCES += src/version.c
src/version.c: Makefile
	$(AM_V_GEN)rm -f $@
	$(AM_V_at)${MKDIR_P} src
	$(AM_V_at)printf '#include <config.h>\n' > $@t
	$(AM_V_at)printf 'char const *Version = "$(PACKAGE_VERSION)";\n' >> $@t
	$(AM_V_at)chmod a-w $@t
	$(AM_V_at)mv $@t $@

BUILT_SOURCES += src/version.h
src/version.h: Makefile
	$(AM_V_GEN)rm -f $@
	$(AM_V_at)${MKDIR_P} src
	$(AM_V_at)printf 'extern char const *Version;\n' > $@t
	$(AM_V_at)chmod a-w $@t
	$(AM_V_at)mv $@t $@

# Generates a list of macro invocations like:
#   SINGLE_BINARY_PROGRAM(program_name_str, main_name)
# once for each program list on $(single_binary_progs). Note that
# for [ the macro invocation is:
#   SINGLE_BINARY_PROGRAM("[", _)
DISTCLEANFILES += src/coreutils.h
src/coreutils.h: Makefile
	$(AM_V_GEN)rm -f $@
	$(AM_V_at)${MKDIR_P} src
	$(AM_V_at)for prog in x $(single_binary_progs); do	\
	  test $$prog = x && continue;				\
	  prog=`basename $$prog`;				\
	  main=`echo $$prog | tr '[' '_'`;			\
	  echo "SINGLE_BINARY_PROGRAM(\"$$prog\", $$main)";	\
	done | sort > $@t
	$(AM_V_at)chmod a-w $@t
	$(AM_V_at)mv $@t $@

DISTCLEANFILES += src/version.c src/version.h
MAINTAINERCLEANFILES += $(BUILT_SOURCES)

all_programs = \
    $(bin_PROGRAMS) \
    $(bin_SCRIPTS) \
    $(EXTRA_PROGRAMS)

pm = progs-makefile
pr = progs-readme
# Ensure that the list of programs in README matches the list
# of programs we can build.
check-local: check-README check-duplicate-no-install
.PHONY: check-README
check-README:
	$(AM_V_GEN)rm -rf $(pr) $(pm)
	$(AM_V_at)echo $(all_programs) \
	 | tr -s ' ' '\n' \
	 | sed -e 's,$(EXEEXT)$$,,' \
	       -e 's,^src/,,' \
	       -e 's/^ginstall$$/install/' \
	 | sed /libstdbuf/d \
	 | $(ASSORT) -u > $(pm) && \
	sed -n '/^The programs .* are:/,/^[a-zA-Z]/p' $(top_srcdir)/README \
	  | sed -n '/^   */s///p' | tr -s ' ' '\n' > $(pr)
	$(AM_V_at)diff $(pm) $(pr) && rm -rf $(pr) $(pm)

# Ensure that a by-default-not-installed program (listed in
# $(no_install__progs) is not also listed as another $(EXTRA_PROGRAMS)
# entry, because if that were to happen, it *would* be installed
# by default.
.PHONY: check-duplicate-no-install
check-duplicate-no-install: src/tr
	$(AM_V_GEN)test -z "`echo '$(EXTRA_PROGRAMS)' | tr ' ' '\n' | uniq -d`"

# Use the just-built 'ginstall', when not cross-compiling.
if CROSS_COMPILING
cu_install_program = @INSTALL_PROGRAM@
else
cu_install_program = src/ginstall
endif
INSTALL_PROGRAM = $(cu_install_program)
