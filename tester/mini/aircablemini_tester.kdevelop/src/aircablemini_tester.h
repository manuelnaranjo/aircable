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


#ifndef _AIRCABLEMINI_TESTER_H_
#define _AIRCABLEMINI_TESTER_H_

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <qvariant.h>
#include <qdialog.h>
#include <qtimer.h>
#include <qstring.h>
#include "aircableOS.h"

#define DEFAULT_SCRIPT	"/usr/share/aircable/scriptmini.txt"
//#define DEFAULT_SCRIPT	"./scriptmini.txt"

#include <kmainwindow.h>

class QVBoxLayout;
class QHBoxLayout;
class QGridLayout;
class QSpacerItem;
class QAction;
class QActionGroup;
class QToolBar;
class QPopupMenu;
class QLineEdit;
class KLed;
class QLabel;
class QPushButton;
class QListBox;
class QListBoxItem;

/**
 * @short AIRcable Mini Tester
 * @author Manuel Naranjo <manuel@aircable.net>
 * @version 0.1
 */
class aircablemini_tester : public QDialog
{
    Q_OBJECT

private:
	// state = 0 IDLE need to send +++
	// state = 1 Check for command line
	// state = 2 Found run script
	int 			state;
	QString			file;
	AIRcableOS*		mini;
	int				count;
public:
    /**
     * Default Constructor
     */
    aircablemini_tester(QWidget* parent = 0, const char* name = 0, bool modal = FALSE, WFlags fl = 0 );

    /**
     * Default Destructor
     */
    virtual ~aircablemini_tester();

	void setFailure();
	void clrFailure();
	
	void setWorking();
	void clrWorking();

	void setDone();
	void clrDone();

	void setScript(QString arg);

    QLineEdit* Script;
    KLed* Done;
    QLabel* Status;
    KLed* Working;
    KLed* Failure;
    QPushButton* Start;
    QPushButton* End;
    QPushButton* SelectScript;
    QListBox* DeviceSelector;

protected slots:
	void alarmHandler();
};

#endif // _AIRCABLEMINI_TESTER_H_
