#!/usr/bin/perl -w

use ExtUtils::MakeMaker ;

WriteMakefile(
    'ABSTRACT'	=>	q[Perl interface to OBEX filesytem] ,
    'AUTHOR'	=>	q[Christian W. Zuckschwerdt <zany@triq.net>] ,
#    'VERSION'	=>	q[0.22],
# Avoid compilation problem for Fedora Core 1
    'DEFINE'    =>	q[-DSKIP_SEARCH_H -DHAVE_CONFIG_H],
    'INC'       =>	q[-I../.. ],
# Default value for LDDLFLAGS is $Config{lddlflags}="-shared -L/usr/local/lib"
# but we want rpath to be ${exec_prefix}/lib or ${prefix}/lib
    'LDDLFLAGS' =>      q[-shared -Wl,-rpath=/usr/lib],
    'LIBS'      =>	q[-L../../obexftp/.libs -lobexftp
    			  -L../../multicobex/.libs -lmulticobex
			  -L../../bfb/.libs -lbfb
			  -lopenobex -lbluetooth   -lbluetooth   ],
    'OBJECT'	=>	'perl_wrap.o', # $(OBJ_EXT)
    'NAME'      =>	'OBEXFTP',
    'FIRST_MAKEFILE'      =>	'Makefile.perl',
) ;
