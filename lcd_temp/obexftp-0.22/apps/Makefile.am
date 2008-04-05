EXTRA_DIST = 			perl_example.pl \
				python_example.py \
				ruby_example.rb \
				tcl_example.tcl \
				ruby_obexftp.rb

INCLUDES =			@OPENOBEX_CFLAGS@ \
				-I$(top_srcdir) \
				-I$(top_srcdir)/includes

LDADD =				@OPENOBEX_LIBS@ \
				@BLUETOOTH_LIBS@ \
				../obexftp/libobexftp.la \
				../multicobex/libmulticobex.la \
				../bfb/libbfb.la

obexftp_SOURCES =		obexftp.c

obexftpd_SOURCES =		obexftpd.c obexftp_sdp.c obexftp_sdp.h
stress_SOURCES =		stress.c
discovery_SOURCES =		discovery.c

bin_PROGRAMS =			obexftp obexftpd

noinst_PROGRAMS =		discovery

install-exec-hook:
	ln -s obexftp $(DESTDIR)$(bindir)/obexls
	ln -s obexftp $(DESTDIR)$(bindir)/obexget
	ln -s obexftp $(DESTDIR)$(bindir)/obexput
	ln -s obexftp $(DESTDIR)$(bindir)/obexrm

# splint -type -predboolint -nullassign -unrecog -nullpass -I.. obexftp_cli.c

