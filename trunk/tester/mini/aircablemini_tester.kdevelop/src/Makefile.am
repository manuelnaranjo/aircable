# set the include path for X, qt and KDE
INCLUDES = $(all_includes)

# these are the headers for your project
noinst_HEADERS = aircablemini_tester.h

# let automoc handle all of the meta source files (moc)
METASOURCES = AUTO

messages: rc.cpp
	$(EXTRACTRC) `find . -name \*.ui -o -name \*.rc` > rc.cpp
	$(XGETTEXT) *.cpp -o $(podir)/aircablemini_tester.pot

KDE_ICON = AUTO

#########################################################################
# APPLICATION SECTION
#########################################################################
# this is the program that gets installed.  it's name is used for all
# of the other Makefile.am variables
bin_PROGRAMS = aircablemini_tester

# the application source, library search path, and link libraries
aircablemini_tester_SOURCES = main.cpp aircablemini_tester.cpp aircableOS.cpp \
		aircableOS.h scriptmini.txt aircablemini_tester.h
aircablemini_tester_LDFLAGS = $(KDE_RPATH) $(all_libraries)
aircablemini_tester_LDADD = -lserial $(LIB_KDEUI)

# this is where the desktop file will go 
shelldesktopdir   = $(kde_appsdir)/Utilities
shelldesktop_DATA = aircablemini_tester.desktop

# this is where the shell's XML-GUI resource file goes
shellrcdir   = $(kde_datadir)/aircablemini_tester
shellrc_DATA = aircablemini_testerui.rc

