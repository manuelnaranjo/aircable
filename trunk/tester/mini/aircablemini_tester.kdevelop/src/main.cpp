/***************************************************************************
 *   Copyright (C) 2006 by Manuel Naranjo   *
 *   manuel@aircable.net   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/


#include "aircablemini_tester.h"
#include <kapplication.h>
#include <kaboutdata.h>
#include <kcmdlineargs.h>
#include <klocale.h>

static const char description[] =
    I18N_NOOP("A KDE KPart Application");

static const char version[] = "0.1";

static KCmdLineOptions options[] =
{
	{ "+file", I18N_NOOP("An optional path to the script file, by default /usr/share/aircable/scriptmini.txt is used"), 0 },
	{"", I18N_NOOP("See the example for sintaxis.")},
	KCmdLineLastOption
};

int main(int argc, char **argv)
{
    KAboutData about("AIRcable Mini Tester", I18N_NOOP("AIRcable Mini Tester"), version, description,
		     KAboutData::License_GPL, "(C) 2006 Manuel Naranjo", 0, 0, "manuel@aircable.net");
    about.addAuthor( "Manuel Naranjo", 0, "manuel@aircable.net" );
    KCmdLineArgs::init(argc, argv, &about);
    KCmdLineArgs::addCmdLineOptions( options );
    KApplication app;
    aircablemini_tester *mainWin = 0;

    /*if (app.isRestored())
    {
        RESTORE(aircablemini_tester);
    }*/
    //else
    {
        // no session.. just start up normally
        KCmdLineArgs *args = KCmdLineArgs::parsedArgs();

        mainWin = new aircablemini_tester();
		if (args->count() > 0)
			mainWin->setScript( args->arg(0));
        app.setMainWidget( mainWin );
        mainWin->show();

        args->clear();
    }

    // mainWin has WDestructiveClose flag by default, so it will delete itself.
    return app.exec();
}

