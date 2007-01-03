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

#include <qstring.h>
#include <qvariant.h>
#include <kled.h>
#include <qlabel.h>
#include <kprogress.h>
#include <qlayout.h>
#include <qtooltip.h>
#include <qtimer.h>
#include <qwhatsthis.h>
#include <qeventloop.h>
#include "kled.h"
#include "kprogress.h"
#include <iostream>
#include <qfile.h>

#include "aircableOS.h"

#define debug		1

aircablemini_tester::aircablemini_tester( QWidget* parent, const char* name, bool modal, WFlags fl )
    : QDialog( parent, name, modal, fl )
{
	QString temp;
	setName( "main" );
	

       Script = new QLineEdit( centralWidget(), "Script" );
    Script->setGeometry( QRect( 160, 301, 210, 50 ) );
    Script->setCursorPosition( 0 );

    Done = new KLed( centralWidget(), "Done" );
    Done->setGeometry( QRect( 20, 240, 101, 101 ) );

    Status = new QLabel( centralWidget(), "Status" );
    Status->setGeometry( QRect( 160, 360, 330, 120 ) );
    Status->setTextFormat( QLabel::LogText );
    Status->setScaledContents( FALSE );
    Status->setAlignment( int( QLabel::WordBreak | QLabel::AlignTop | QLabel::AlignLeft ) );

    Working = new KLed( centralWidget(), "Working" );
    Working->setGeometry( QRect( 20, 120, 100, 101 ) );

    Failure = new KLed( centralWidget(), "Failure" );
    Failure->setGeometry( QRect( 20, 10, 101, 101 ) );

    Start = new QPushButton( centralWidget(), "Start" );
    Start->setGeometry( QRect( 10, 360, 110, 51 ) );
    Start->setDefault( TRUE );

    End = new QPushButton( centralWidget(), "End" );
    End->setGeometry( QRect( 10, 420, 110, 50 ) );

    SelectScript = new QPushButton( centralWidget(), "SelectScript" );
    SelectScript->setGeometry( QRect( 380, 300, 120, 51 ) );

    DeviceSelector = new QListBox( centralWidget(), "DeviceSelector" );
    DeviceSelector->setGeometry( QRect( 160, 20, 340, 270 ) );
    DeviceSelector->setAcceptDrops( FALSE );
    DeviceSelector->setFrameShape( QListBox::Box );
    DeviceSelector->setFrameShadow( QListBox::Plain );
    DeviceSelector->setResizePolicy( QListBox::AutoOneFit );
    DeviceSelector->setVScrollBarMode( QListBox::AlwaysOff );
    DeviceSelector->setHScrollBarMode( QListBox::Auto );
    DeviceSelector->setDragAutoScroll( TRUE );
    DeviceSelector->setSelectionMode( QListBox::Single );
    DeviceSelector->setColumnMode( QListBox::Variable );
    DeviceSelector->setRowMode( QListBox::FixedNumber );
    DeviceSelector->setVariableWidth( FALSE );
    DeviceSelector->setVariableHeight( FALSE );

    resize( QSize(609, 518).expandedTo(minimumSizeHint()) );
    clearWState( WState_Polished );

	//usb = new AIRcableUSB();
	//rfcomm = new RfComm();
    mini = new AIRcableOS();
    mini->Open();

    startTimer( 0 );					// run continuous timer
	state = 0;
    timer = new QTimer( this );
    connect( timer, SIGNAL(timeout()),
             this, SLOT(alarmHandler()) );
    timer->start( 400 );
	
	status->setText("IDLE");
	temp+= "Script: ";
	temp+=DEFAULT_SCRIPT;
	filename->setText(temp);


}

void aircablemini_tester::setScript(QString arg){
	file = arg;
	arg= "Script: " + arg;	
	filename->setText(arg);
}

aircablemini_tester::~aircablemini_tester()
{
	if (mini->IsOpen()){
		mini->sendCommand("e");
		mini->Close();
	}
	timer->stop();
	delete(timer);
	delete(mini);
	delete(failure);
    delete(working);
    delete(done);
    delete(textLabel1);
    delete(rssi);
    delete(status);
	delete(filename);
	std::cerr<<"DESTROY"<<endl;
}

void aircablemini_tester::setFailure(){
	Failure->setColor( QColor( 255, 0, 0 ) );
}

void aircablemini_tester::clrFailure(){
	Failure->setColor( QColor( 125, 0, 0 ) );
}
	
void aircablemini_tester::setWorking(){
	Working->setColor( QColor( 255, 255, 0 ) );
}

void aircablemini_tester::clrWorking(){
	Working->setColor( QColor( 125, 125, 0 ) );
}

void aircablemini_tester::setDone(){
	Done->setColor( QColor( 0, 255, 0 ) );
}

void aircablemini_tester::clrDone() {
	Done->setColor( QColor( 0, 125, 0 ) );
}

void aircablemini_tester::alarmHandler() {
	switch (state){
		case 0:
			if (!mini->IsOpen()){
				mini->Open();
				usleep(100*1000);
			}
			mini->emptyBuffer();			
			status->setText("Detecting Device");
			timer->start(100);
			setWorking();
			clrDone();
			clrFailure();
			state = 1;
			count = 0;
			break;
		case 1:
			timer->stop();
			if (mini->checkConnected()) {
				status->setText("Found a Mini, please wait while I do my job");
				mini->sendCommand(CMD_SEQUENCE);
				sleep(5);
				state = 2;
				timer->start(100);
				return;
			}
			/*count++;
			timer->start(1000);
			if (count < 10)
				return;*/

			mini->sendCommand("e");
			sleep(4);
			status->setText("Timeout, no Mini Connected");			
			timer->start(200);
			clrWorking();
			clrDone();
			clrFailure();
			state = 0;
			//count = 0;
			break;
		case 2:{
			QString line, read;
			time_t ptime;
			timer->stop();
			QFile* script;
			setDone();
			
			if (file != NULL && !file.isNull() && !file.isEmpty())
				script = new QFile(file);
			else
				script = new QFile(DEFAULT_SCRIPT);

			mini->readBuffer();
			if (!script->exists()){
				status->setText("The script file doesn't exist\nAborting script run");
				clrFailure();
				clrWorking();
				clrDone();
				state=0;
				mini->sendCommand("e");
				timer->start(4000);
				state=4;
				return;
			}

			if (!script->open( IO_ReadOnly )) {
				status->setText("I wasn't able to open the script for Read\nCheck Permissions");
				clrFailure();
				clrWorking();
				clrDone();
				state=4;
				mini->sendCommand("e");
				timer->start(2000);
				
				return;
			}
		
			mini->readBuffer();
			sleep(2);

			while ( script->readLine(line,80) > 0){
				mini->emptyBuffer();
				if (line.length()>0){
					line = line.remove('\n');
					line = line.remove('\r');
					if (line.startsWith("+")){
						read="";
						line = line.right(1);
						if (debug>0)
							std::cerr<<"SEND: "<<line<<endl;
						ptime = time(NULL);
						mini->sendCommand(line);
						while (read.find(line)<0) {
							read+=mini->readBuffer();
							usleep(500*1000);
							if (difftime(ptime,time(NULL))>5){
								setFailure();
								clrDone();
								clrWorking();
								status->setText("Did not pass the tests");
								state=3;
							}
						}
						if (debug>0)
							std::cerr<<endl;
					}else if (line.startsWith("*")){
						read="";
						line +=(char)13;
						line = line.right(line.length()-1);
						if (debug>0)
							std::cerr<<"SEND: "<<line<<endl;
						ptime = time(NULL);
						mini->sendCommand(line);
						line=line.left(line.length()-1);
						if (debug>0)
							std::cerr<<"READ; "<<endl;
						while (read.find(line)<0) {
							read+=mini->readBuffer();
							usleep(500*1000);
							if (difftime(ptime,time(NULL))>10){
								setFailure();
								clrDone();
								clrWorking();
								status->setText("Did not pass the tests");
								state=3;
							}
						}
						if (debug>0)
							std::cerr<<endl;
						
					}
				}
			}
			mini->sendCommand("e");
			mini->readBuffer();
			status->setText("Done. Please disconnect the device.");
			clrFailure();
			clrWorking();
			setDone();
			state=3;

			timer->start(100);
			return;
		}	
		case 3:
			if (!mini->IsOpen()){
				mini->Open();
				usleep(100*1000);
			}
			if (!mini->checkConnected()){
				state=0;
				clrDone();
				clrFailure();
				clrWorking();
				timer->start(100);
			}
			return;
		case 4:
			mini->Close();
			exit(0);
			return;
	}
}
#include "aircablemini_tester.moc"
