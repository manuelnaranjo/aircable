/****************************************************************************
** ui.h extension file, included from the uic-generated form implementation.
**
** If you want to add, delete, or rename functions or slots, use
** Qt Designer to update this file, preserving your code.
**
** You should not define a constructor or destructor in this file.
** Instead, write your code in functions called init() and destroy().
** These will automatically be called by the form's constructor and
** destructor.
*****************************************************************************/

#include <qcolor.h>
#include <qpicture.h>
#include <qtimer.h>
#include <qfile.h>
#include <qsettings.h>
#include <qapplication.h>
#include <qfiledialog.h>
#include <qprocess.h>
#include <qmessagebox.h>

#include <string>

#include <iostream>

#include <time.h>

#include <kled.h>

//Log4cxx stuff
#include <log4cxx/logger.h>
#include <log4cxx/propertyconfigurator.h>
#include <log4cxx/helpers/exception.h>

#include "aircableOS.h"
#include "aircableUSB.h"
#include "aircableSerial.h"
#include "rfcomm.h"
#include "qtabout.h"


QTimer* 	timer;
AIRcableOS*	aircableOS;
AIRcableUSB*	aircableUSB;
AIRcableSerial* aircableSerial;
RfComm*		rfcomm;
QFile*		file;
QString		scriptOS, scriptUSB, scriptSerial;
QSettings*	settings;
int		state_usb;
int		addr_count;
int 		start_count;

QString		loggerFile;

using namespace log4cxx;
using namespace log4cxx::helpers;

// Define a static logger variable so that it references the
// Logger instance named "universal_tester".
LoggerPtr logger(Logger::getLogger("universal_tester"));

/**
 * States descriptor.
 */
enum STATE {

	START,

	USB_DETECTING,
	USB_FOUND,
	USB_TESTING,
	USB_TESTING_DONE,
	USB_TESTING_FAILURE,
	USB_SCRIPT_RUN,
	USB_SCRIPT_DONE,
	USB_SCRIPT_FAILURE,

	OS_DETECTING,
	OS_FOUND,
	OS_BT_ADDR,
	OS_SCRIPT_RUN,
	OS_SCRIPT_DONE,
	OS_SCRIPT_FAILURE,

	SERIAL_DETECTING,
	SERIAL_FOUND,
	SERIAL_TESTING,
	SERIAL_TESTING_DONE,
	SERIAL_TESTING_FAILURE,
	SERIAL_SCRIPT_RUN,
	SERIAL_SCRIPT_DONE,
	SERIAL_SCRIPT_FAILURE,

	STOP
};

STATE state;

void qtAIRcableMainForm::clrWorking()
{
	LOG4CXX_DEBUG(logger, "clrWorking()");
	Working->setColor(QColor(125,125,0));
}

void qtAIRcableMainForm::setWorking()
{
	LOG4CXX_DEBUG(logger, "setWorking()");
	Working->setColor(QColor(255,255,0));
}

void qtAIRcableMainForm::setDone()
{
	LOG4CXX_DEBUG(logger, "setDone()");
	Done->setColor(QColor(0,255,0));
}

void qtAIRcableMainForm::clrFailure()
{
	LOG4CXX_DEBUG(logger, "clrFailure()");
	Failure->setColor(QColor(125,0,0));
}


void qtAIRcableMainForm::setFailure()
{
	LOG4CXX_DEBUG(logger, "setFailure()");
	Failure->setColor(QColor(255,0,0));
}


void qtAIRcableMainForm::init()
{
	settings = new QSettings();	
	
	loggerFile = settings->readEntry( "/AIRcableUniversalTester/ logger", "/usr/share/aircable/logger");
	
	PropertyConfigurator::configure( string( loggerFile.ascii() ));
	
	LOG4CXX_DEBUG(logger, "init()");

      	clrDone();
	clrWorking();
	clrFailure();
	
	Progress->clear();
	AddProgress("Please select the kind of device");
	AddProgress("Change the script file if you want");
	AddProgress("Then Press Start to Begin");

	scriptOS = settings->readEntry( "/AIRcableUniversalTester/ scriptOS", "/usr/share/aircable/script/os" );
	scriptUSB = settings->readEntry( "/AIRcableUniversalTester/ scriptUSB" ,"/usr/share/aircable/script/usb");
	scriptSerial = settings->readEntry( "/AIRcableUniversalTester/ scriptSerial" ,"/usr/share/aircable/script/serial");
	
	updateImage();
	
	LOG4CXX_DEBUG(logger, "Ready to go.");
}


void qtAIRcableMainForm::updateImage()
{
	LOG4CXX_DEBUG(logger, "updateImage()");
	int k = Device->currentItem();
	switch (k){
		case 0:
			LOG4CXX_DEBUG(logger, "USB Selected");
			//Selected USB	
			Image->setPixmap( QPixmap::fromMimeSource( "usb.jpg" ) );
			if (scriptUSB == NULL)
				scriptUSB = "/usr/share/aircable/script/usb";
			Script->setText( scriptUSB );
			return;
		case 1:
			LOG4CXX_DEBUG(logger, "Serial OS Selected");
			//Selected Serial OS
			Image->setPixmap( QPixmap::fromMimeSource( "serial-os.jpg" ) );
			if (scriptOS == NULL)
				scriptOS = "/usr/share/aircable/script/os";
			Script->setText( scriptOS );
			return;
		case 2: 
			LOG4CXX_DEBUG(logger, "Serial Selected");
			//Seleceted Serial
			Image->setPixmap( QPixmap::fromMimeSource( "serial.jpg" ) );
			if (scriptSerial == NULL)
				scriptSerial = "/usr/share/aircable/script/serial";
			Script->setText( scriptSerial );
			return;
		default:
			return;
	}
}


void qtAIRcableMainForm::clrDone()
{
	LOG4CXX_DEBUG(logger, "clrDone()");
	Done->setColor(QColor(0,125,0));
}

void qtAIRcableMainForm::deviceChanged( int )
{
	LOG4CXX_DEBUG(logger, "deviceChanged()");
	updateImage();
}

void qtAIRcableMainForm::Browse_clicked()
{
	LOG4CXX_DEBUG(logger, "Browse_clicked()");
	QString new_script = QFileDialog::getOpenFileName(
	    "/usr/share/aircable/script",
	    "Script Files (*)",
	    this,
	    "script chooser",
	    "Choose a file" );
	    
	if (new_script!=NULL && !new_script.isNull() && !new_script.isEmpty()){
	    LOG4CXX_DEBUG(logger, "New Script: " + new_script);	    
	    Script->setText(new_script);
	} else LOG4CXX_DEBUG(logger, "New Script: NULL");
}

void qtAIRcableMainForm::Start_clicked()
{
	LOG4CXX_DEBUG(logger, "Start_clicked()");
	AddProgress("Starting....");
	timer = new QTimer(this);
	connect( timer, SIGNAL(timeout()), this, SLOT(TimerEvent()) );
	timer->start( 100, TRUE ); 
	state = START;
}

void qtAIRcableMainForm::Stop_clicked()
{
	LOG4CXX_DEBUG(logger, "Stop_clicked()");
	AddProgress("Stop...");
	state = STOP;
	timer->start(100,TRUE);
}

void qtAIRcableMainForm::AddProgress( QString arg)
{
	LOG4CXX_DEBUG(logger, "AddProgress( " + arg + " )");
	if (Progress->count() > 200)
		Progress->clear();	
	Progress->insertItem(arg);
	Progress->setBottomItem(Progress->count()-1);
}

void qtAIRcableMainForm::TimerEvent()
{
	LOG4CXX_DEBUG(logger, "TimerEvent()");
	int new_time = 100;
	int k;
	timer->stop();
	switch (state){
		case  START:{
			LOG4CXX_DEBUG(logger, "case: START");
			QString path;
			path = Script->text();
	
			if (! (path != NULL && !path.isNull() && !path.isEmpty())) {
				LOG4CXX_DEBUG(logger, "Script = NULL, can't go");
				AddProgress("Script path can't be empty");
				AddProgress("I can't continue");
				state = STOP;
				break;				
			}
	
			file = new QFile(path);
	
			if (!file->exists()){
				LOG4CXX_DEBUG(logger, "Script file doesn't exit, can't go on.");
				AddProgress("The script file doesn't exist.");
				AddProgress("I can't continue");
				state = STOP;
				break;
			}

			if (!file->open( IO_ReadOnly )) {
				LOG4CXX_DEBUG(logger, "Script file couldn't be opened for reading.");
				AddProgress("I wasn't able to open the script for Read");
				AddProgress("Check Permissions");
				AddProgress("I can't continue");
				state = STOP;
				break;
			}

			k = Device->currentItem();
	
			if (k== 0){
				LOG4CXX_INFO(logger, "Waiting for AIRcableUSB");
				state = USB_DETECTING;
				aircableUSB = new AIRcableUSB("/dev/ttyUSB0");
				AddProgress("Waiting for an AIRcableUSB");
			}
			else if (k==1){
				LOG4CXX_INFO(logger, "Waiting for SerialOS");
				state = OS_DETECTING;
				aircableOS = new AIRcableOS("/dev/ttyS0");
				aircableOS->Open();
				AddProgress("Detecting AIRcableOS device...");
			}
			else if (k==2){
				LOG4CXX_INFO(logger, "Waiting for Serial");
				state = SERIAL_DETECTING;
				aircableSerial = new AIRcableSerial("/dev/ttyS0");
				aircableSerial->Open();
				AddProgress("Detecting AIRcable Serial device...");
			}

			Start->setDisabled(true);
			Stop->setEnabled(true);
			Browse->setDisabled(true);
			Script->setDisabled(true);
			Device->setDisabled(true);
	
			break;

		}

		case USB_DETECTING:{
			LOG4CXX_DEBUG(logger, "case: USB_DETECTING");
			if (aircableUSB->checkConnected()){
				AddProgress("Found an AIRcableUSB");
				AddProgress("Starting test");
				LOG4CXX_INFO(logger, "Found a AIRcableUSB");
				state = USB_FOUND;				
				new_time=500;
			}
			
			break;
		}

		case USB_FOUND:{
			LOG4CXX_DEBUG(logger, "case: USB_FOUND");
			setWorking();
			aircableUSB->Open();
			new_time=2000;				
			state = USB_TESTING;
			AddProgress("Sending testing settings");
			state_usb = 0;
			break;
		}

		case USB_TESTING:{
			switch (state_usb){
				case 0: {					
					AddProgress("Send: ^A A0");	
					aircableUSB->sendCommand("A0");
					new_time = 4000;
					state_usb=1;
					addr_count = 0;
					break;
				}

				case 1: {
					AddProgress("Send: ^A P1234");
					aircableUSB->sendCommand("P1234");
					new_time=500;
					state_usb=2;					
					break;
				}

				case 2:{
					AddProgress("Send: ^A B");
					aircableUSB->sendCommand("B");
					new_time=500;
					state_usb=3;
					break;
				}

				case 3: {
					
					AddProgress("Opening SPP");
					QString tmp;
					tmp = aircableUSB->getBTAddress(aircableUSB->readBuffer());
					
					if (tmp == NULL || tmp.isNull() || tmp.isEmpty()) {
					    if (addr_count > 3) {
						LOG4CXX_INFO(logger, "USB didn't replied BT ADDR");
						state = USB_SCRIPT_FAILURE;
						clrDone();
						clrWorking();
						setFailure();
						AddProgress("Couldn't Get Bluetooth Address");
						AddProgress("Testing was not passed");
					    } else {
						addr_count++;
						state_usb = 2;
						new_time=500;
					    }					    
					    break;					    
					}
					LOG4CXX_INFO(logger, "BT ADDR: " + tmp);
					AddProgress("ADDR: " + tmp);
					rfcomm = new RfComm();
					rfcomm->setAddress(tmp);
					aircableUSB->sendCommand("S11");
					new_time = 1000;
					state_usb = 4;
					break;
				}
				
				case 4: {					
					AddProgress("Connecting");
					rfcomm->Open();
					new_time=1000;
					state_usb = 5;
					break;
				}

				case 5: {
					int8_t irssi = 0;
					int resp = rfcomm->getRSSI(&irssi);
					if (resp >=0) {
						QString rssi;
						rssi = rssi.setNum(irssi);
						LOG4CXX_INFO(logger, "RSSI: " + rssi);
						LOG4CXX_INFO(logger, "DONE");
						AddProgress("RSSI: " + rssi);
						AddProgress("Testing OK");
						setWorking();
						setDone();
						clrFailure();
						state = USB_TESTING_DONE;
					}
					else{
						LOG4CXX_INFO(logger, "RSSI FAILED, FAILED TESTING");
						clrWorking();
						clrDone();
						setFailure();
						AddProgress("Couldn't Measure RSSI");
						AddProgress("Testing Failed");
						state = USB_TESTING_FAILURE;
					}
					rfcomm->Close();
					sleep(1);
					aircableUSB->sendCommand("Y");
					sleep(1);
					delete(rfcomm);
				}
			}
			
			break;
		}

		case USB_TESTING_DONE:{
			LOG4CXX_DEBUG(logger, "case: USB_TESTING_DONE");
			file->reset();
			state = USB_SCRIPT_RUN;
			break;
		}

		case USB_SCRIPT_RUN:{
			LOG4CXX_DEBUG(logger, "case: USB_SCRIPT_RUN");
			aircableUSB->readBuffer();
			if (!file->atEnd()){
				QString line;
				if ( file->readLine(line,80) > 0){
					aircableUSB->readBuffer();
					if (line.length()>0){
						line = line.remove('\n');
						line = line.remove('\r');
						if (line.startsWith("!")){
						    line = line.remove("!");
						    new_time = line.toInt();
						    AddProgress("Sleeping for: " + line+ " ms");
						    break;
						}
						else if (!line.startsWith("#")){
							AddProgress("Sending: " + line);
							aircableUSB->sendCommand(line);
							new_time=400;
						} else 
							break;
					}
				}
			} else {
				state = USB_SCRIPT_DONE;
				setDone();
				clrWorking();
				clrFailure();
				AddProgress("Test Ended. Results were OK");
				AddProgress("Please Disconnect the device");
				AddProgress("So I can test another one");			
			}
			break;
		}

		case USB_TESTING_FAILURE:
		case USB_SCRIPT_FAILURE:
		case USB_SCRIPT_DONE: {
			LOG4CXX_DEBUG(logger, "case: USB_TESTING_FAILURE, USB_SCRIPT_FAILURE or USB_SCRIPT_DONE");
			aircableUSB->Close();
			if (!aircableUSB->checkConnected()){
				clrWorking();
				clrDone();
				clrFailure();
				state = USB_DETECTING;
				AddProgress("Waiting for an AIRcableUSB");
			}
			break;
		}

		case OS_DETECTING: {
			LOG4CXX_DEBUG(logger, "case: OS_DETECTING");
			if (aircableOS->checkConnected()){
				state = OS_FOUND;
				AddProgress("Found a device");
				LOG4CXX_INFO(logger, "New AIRcable OS Detected");
				file->reset();
				setWorking();
				clrDone();
				clrFailure();	
				aircableOS->readBuffer();
				aircableOS->emptyBuffer();			
				new_time=9000;
				start_count=0;				
			}
			break;
		}
		
		case OS_FOUND:{
			LOG4CXX_DEBUG(logger, "case: OS_FOUND");
			QString temp;
			state = OS_SCRIPT_RUN;
			
			temp = aircableOS->readBuffer();
			
			if ( temp.find("AIRcable>") == -1){
			    if (start_count > 4){
				LOG4CXX_INFO(logger, "Device Failed");
				AddProgress("Sorry this device is not working");
				clrDone();
				clrWorking();
				setFailure();								
			    }else {
				AddProgress("Sending +++");			
				aircableOS->sendCommand("+++");
				new_time=4000;
				start_count++;
			    }
			} else {
				AddProgress("Starting to send Script");
				new_time=200;
				state = OS_SCRIPT_RUN;
			}
			break;
		}
	
		case OS_SCRIPT_RUN:{
			LOG4CXX_DEBUG(logger, "OS_SCRIPT_RUN");
			if (!file->atEnd()){
				QString line;
				time_t ptime;
				QString read;
				QString compare;
				int TIME = 5;
				if ( file->readLine(line,80) > 0){
					aircableOS->emptyBuffer();
					if (line.length()>0){
						line = line.remove('\n');
						line = line.remove('\r');
						if (line.startsWith("!")){
						    line = line.remove("!");
						    new_time = line.toInt();
						    AddProgress("Sleeping for: " + line +" ms");
						    break;
						} else if (line.startsWith("+")){
							line = line.right(1);
							compare = line;
							TIME = 5;
						} else if (line.startsWith("*")){
							line +=(char)13;
							line = line.right(line.length()-1);
							compare=line.left(line.length()-1);
							TIME = 10;
						} else 
							break;
						read="";
						ptime = time(NULL);
						AddProgress("Sending: " + line);
						aircableOS->emptyBuffer();
						aircableOS->sendCommand(line);
						while (read.find(compare)<0) {
							read+=aircableOS->readBuffer();
							aircableOS->emptyBuffer();
							usleep(100*1000);
							if ( difftime ( ptime, time (NULL) ) > TIME ) {
								state = OS_SCRIPT_FAILURE;	
								AddProgress("Couldn't Send Command");
								AddProgress("Testing Failed");
								LOG4CXX_INFO(logger, "Device Failed");
								setFailure();
								clrDone();
								clrWorking();
								aircableOS->sendCommand("e");
							}
						}
					}
				}
			} else {
				state = OS_SCRIPT_DONE;
				setDone();
				clrWorking();
				clrFailure();
				aircableOS->sendCommand("e");
				LOG4CXX_INFO(logger, "Device testing sucessfull.");
				AddProgress("Test Ended. Results were OK");
				AddProgress("Please Disconnect the device");
				AddProgress("So I can test another one");
			}
			break;
		}

		case OS_SCRIPT_DONE:
		case OS_SCRIPT_FAILURE:{
	    		LOG4CXX_DEBUG(logger, "case: OS_SCRIPT_DONE|OS_SCRIPT_FAILURE");
			if (!aircableOS->checkConnected()){
				state = OS_DETECTING;
				clrDone();
				clrWorking();
				clrFailure();
				AddProgress("Detecting AIRcableOS device...");				
			}  else
			    aircableOS->readBuffer();
			
			break;
		}

		case SERIAL_DETECTING:{
			LOG4CXX_DEBUG(logger, "case: SERIAL_DETECTING");
			if (aircableSerial->checkConnected()){
				AddProgress("Found an AIRcable Serial");
				AddProgress("Starting test");
				state = SERIAL_FOUND;
			}			
			break;
		}

		case SERIAL_FOUND:{
			LOG4CXX_DEBUG(logger, "case: SERIAL_FOUND");
			setWorking();
			state = SERIAL_TESTING;
			AddProgress("Sending testing settings");
			state_usb = 0;
			break;
		}

		case SERIAL_TESTING:{
			LOG4CXX_DEBUG(logger, "case: SERIAL_TESTING");
			switch (state_usb){
				case 0: {
					AddProgress("Send: ^A A0");	
					aircableSerial->sendCommand("A0");
					new_time = 4000;
					state_usb=1;
					addr_count = 0;
					break;
				}

				case 1: {
					AddProgress("Send: ^A P1234");
					aircableSerial->sendCommand("P1234");
					new_time=500;
					state_usb=2;
					break;
				}

				case 2:{
					AddProgress("Send: ^A B");
					aircableSerial->sendCommand("B");
					new_time=500;
					state_usb=3;
					break;
				}

				case 3: {
					AddProgress("Opening SPP");
					QString tmp;
					tmp = aircableSerial->getBTAddress(aircableSerial->readBuffer());
					if (tmp == NULL || tmp.isNull() || tmp.isEmpty()) {
					    if (addr_count > 3) {
						state = USB_SCRIPT_FAILURE;
						clrDone();
						clrWorking();
						setFailure();
						LOG4CXX_INFO(logger, "Device didn't replied BT ADDR");
						AddProgress("Couldn't Get Bluetooth Address");
						AddProgress("Testing was not passed");
					    } else {
						addr_count++;
						state_usb = 2;
						new_time=500;
					    }					    
					    break;					    
					}
					LOG4CXX_INFO(logger, "BT ADDR: " + tmp);					
					rfcomm = new RfComm();
					rfcomm->setAddress(tmp);
					aircableSerial->sendCommand("S11");
					new_time = 1000;
					state_usb = 4;
					break;
				}
				
				case 4: {
					AddProgress("Connecting");
					rfcomm->Open();
					new_time=1000;
					state_usb = 5;
					break;
				}

				case 5: {
					int8_t irssi = 0;
					int resp = rfcomm->getRSSI(&irssi);
					if (resp >=0) {
						QString rssi;
						rssi = rssi.setNum(irssi);
						LOG4CXX_INFO(logger, "RSSI: " + rssi);
						LOG4CXX_INFO(logger, "testing OK");
						AddProgress("RSSI: " + rssi);
						AddProgress("Testing OK");
						setWorking();
						setDone();
						clrFailure();
						state = SERIAL_TESTING_DONE;
					}
					else{
						clrWorking();
						clrDone();
						setFailure();
						LOG4CXX_INFO(logger, "RSSI: failed");
						LOG4CXX_INFO(logger, "Device, failed");
						AddProgress("Couldn't Measure RSSI");
						AddProgress("Testing Failed");
						state = SERIAL_TESTING_FAILURE;
					}
					rfcomm->Close();
					sleep(1);
					aircableSerial->sendCommand("Y");
					sleep(1);
					delete(rfcomm);
				}
			}
			
			break;
		}

		case SERIAL_TESTING_DONE:{
			LOG4CXX_DEBUG(logger, "case: SERIAL_TESTING_DONE");
			file->reset();
			state = SERIAL_SCRIPT_RUN;
			break;
		}

		case SERIAL_SCRIPT_RUN:{
			LOG4CXX_DEBUG(logger, "case: SERIAL_SCRIPT_RUN");
			aircableSerial->readBuffer();
			if (!file->atEnd()){
				QString line;
				if ( file->readLine(line,80) > 0){
					aircableSerial->readBuffer();
					if (line.length()>0){
						line = line.remove('\n');
						line = line.remove('\r');
						if (line.startsWith("!")){
						    line = line.remove("!");
						    new_time = line.toInt();
						    AddProgress("Sleeping for: " + line +" ms");
						    break;
						} else if (!line.startsWith("#")){
							AddProgress("Sending: " + line);
							aircableSerial->sendCommand(line);
							new_time=400;
						} else 
							break;
					}
				}
			} else {
				state = SERIAL_SCRIPT_DONE;
				setDone();
				clrWorking();
				clrFailure();
				LOG4CXX_INFO(logger, "Device, configured sucesfully");
				AddProgress("Test Ended. Results were OK");
				AddProgress("Please Disconnect the device");
				AddProgress("So I can test another one");
			}
			break;
		}

		case SERIAL_TESTING_FAILURE:
		case SERIAL_SCRIPT_FAILURE:
		case SERIAL_SCRIPT_DONE:{
			LOG4CXX_DEBUG(logger, "case: SERIAL_TESTING_FAILURE|SERIAL_SCRIPT_FAILURE|SERIAL_SCRIPT_DONE");
			if (!aircableSerial->checkConnected()){
				clrWorking();
				clrDone();
				clrFailure();
				state = SERIAL_DETECTING;
				AddProgress("Waiting for an AIRcable Serial");
			}
			break;
		}


		case    STOP:{
			LOG4CXX_INFO(logger, "Stopped testing.");
			if (aircableOS != NULL){
				if (aircableOS->IsOpen())
					aircableOS->Close();
				delete(aircableOS);
			}
			
			if (aircableUSB != NULL){
				if (aircableUSB->IsOpen())
					aircableUSB->Close();
				delete(aircableUSB);
			}
			
			if (aircableSerial != NULL){
				if (aircableSerial->IsOpen())
					aircableSerial->Close();
				delete(aircableSerial);
			}
			
			delete(timer);
			
			Start->setEnabled(true);
			Stop->setDisabled(true);
			Browse->setEnabled(true);
			Script->setEnabled(true);
			Device->setEnabled(true);
			
			clrWorking();
			clrDone();
			clrFailure();
			
			return;
		}

		default:
			return;
	}
	timer->start(new_time, TRUE);
}

void qtAIRcableMainForm::destroy()
{
	settings->writeEntry("/AIRcableUniversalTester/ logger", loggerFile);
	settings->writeEntry("/AIRcableUniversalTester/ scriptOS", scriptOS);
	settings->writeEntry("/AIRcableUniversalTester/ scriptUSB", scriptUSB);
	settings->writeEntry("/AIRcableUniversalTester/ scriptSerial", scriptSerial);

	delete(settings);

	if (file != NULL){
		file->close();
		delete(file);
	}	
}


void qtAIRcableMainForm::ScriptChanged( const QString & newText)
{
	LOG4CXX_DEBUG(logger, "ScriptChanged ( " + newText + " ) ");
	int k = Device->currentItem();
	switch (k){
		case 0:
			scriptUSB = newText;
			return;
		case 1:
			scriptOS = newText;
			return;
		case 2: 
			scriptSerial = newText;
		default:
			return;
	}
}

void qtAIRcableMainForm::fileExitAction_activated()
{
	LOG4CXX_DEBUG(logger, "fileExitAction_activated()");
	QApplication::exit();
}


void qtAIRcableMainForm::fileDefault_SettingsAction_activated()
{
    LOG4CXX_DEBUG(logger, "fileDefault_SettingsAction_activated()");
    scriptUSB = "/usr/share/aircable/script/usb";
    scriptOS = "/usr/share/aircable/script/os";
    scriptSerial = "/usr/share/aircable/script/serial";
    updateImage();
}


void qtAIRcableMainForm::helpAboutAction_activated()
{
    LOG4CXX_DEBUG(logger, "helpAboutAction_activated()");
    qtAbout* form;
    form = new qtAbout();    
    form->exec();   
}


void qtAIRcableMainForm::Edit_clicked()
{
    LOG4CXX_DEBUG(logger, "Edit_clicked()");
    QProcess* kwrite;
    kwrite = new QProcess(this);
    kwrite->addArgument( "kwrite" );
    kwrite->addArgument( Script->text() );
    kwrite->start();
    delete(kwrite);
}


void qtAIRcableMainForm::slaveLog_clicked()
{
    QString target = QFileDialog::getSaveFileName(
        NULL,
        "Script Files (*)",
	this,
	"Save Log",
	"Save As" );
    
    if (target != NULL){
        QProcess* mv;
	mv = new QProcess(this);
        mv->addArgument( "mv" );
	mv->addArgument( "universal_tester.log"  );
	mv->addArgument( target );
	mv->addArgument( "-f"  );
        mv->start();
	
	while (mv->isRunning())
	    usleep(100*1000);
	
	QMessageBox :: information ( this , "Log saved sucessfully", 
		    "Log Saved Sucessfully.\nI have to exit",
		    QMessageBox::Ok);
	
	QApplication::exit();
    }
}
