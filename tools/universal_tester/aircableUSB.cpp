/***************************************************************************
 *   Copyright (C) 2006 by Manuel Naranjo   *
 *   manuel@aircable.net   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Library General Public License as       *
 *   published by the Free Software Foundation; either version 2 of the    *
 *   License, or (at your option) any later version.                       *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU Library General Public     *
 *   License along with this program; if not, write to the                 *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#include "aircableUSB.h"
#include <string.h>
#include <iostream>
#include <SerialStream.h>

#include <qfile.h>
#include <qstring.h>
#include <qstringlist.h>
#include <qtextstream.h>

#include <usbpp.h>

using namespace LibSerial;
using namespace std;
using namespace USB;


AIRcableUSB::AIRcableUSB() : SerialStream(){
	portID = "/dev/ttyUSB0";
}

AIRcableUSB::AIRcableUSB(const string port) : SerialStream(){
	portID = port;
}

AIRcableUSB::~AIRcableUSB(){
}


void AIRcableUSB::Open(){
	if (!checkConnected()){
		std::cerr << "There is no dongle connected, aborting" << endl;
		exit(1);
	}

	//first we ask serial stream to open the port
	SerialStream::Open(portID);
	
	//now we set the settings that we need
	SerialStream::SetBaudRate( SerialStreamBuf::BAUD_115200 );
	SerialStream::SetCharSize( SerialStreamBuf::CHAR_SIZE_8 );
	SerialStream::SetNumOfStopBits(1);
	SerialStream::SetParity( SerialStreamBuf::PARITY_NONE );
	SerialStream::SetFlowControl( SerialStreamBuf::FLOW_CONTROL_HARD );
}

void AIRcableUSB::sendCommand(string command){
	int BUFFER_SIZE = command.size() + 2;
	char output_buffer[BUFFER_SIZE] ;
	readBuffer();

	std::cerr<<"SEND: " << command << std::endl;
	
	output_buffer[0] = 0x1;
	for (unsigned int i = 0 ; i < command.size() ; i++)
		output_buffer[1 + i] = command[i];
	output_buffer[BUFFER_SIZE-1] = 0xd;
	
	SerialStream::write(output_buffer , BUFFER_SIZE);
}

string AIRcableUSB::getBTAddress(string input){
	string out;
	string temp = "ADDR: 112233445566";
	unsigned int index;
	if (input.size() >= temp.size()){
		out = "";
		index = input.find("ADDR: ",0);
		if (index != string::npos){
			temp="112233445566";
			input = input.substr(index + 6 , temp.size());
			for (unsigned int i = 0 ; i < 6 ; i++){
				out+=input[i*2];
				out+=input[i*2+1];
				if (i < 5)
					out+=':';
			}
		}
	}
	return out;
}

bool AIRcableUSB::checkConnected(void){
	QFile file("/proc/bus/usb/devices");
	QStringList lines;
	bool resp = false;
	if ( file.open( IO_ReadOnly ) ) {
		QTextStream stream( &file );
		QString line;
        	while ( !stream.atEnd() ) {
			line = stream.readLine();
			if (line.startsWith("P:  ")) {
				int prod, vendor;
				line = line.upper();
				prod = line.find("1502");
				vendor = line.find("16CA");
				if ( (vendor > -1) && (prod > -1) && (prod > vendor) )
					resp=true;
			}
		}
		file.close();
	}
	return resp;
	
}

string AIRcableUSB::readBuffer(){
	string temp = "";
	
	if (DEBUG > 0)
		std::cerr<<"READ:"<<endl;
	
	while( SerialStream::rdbuf()->in_avail() > 0) {
		char next_byte;
		SerialStream::get(next_byte);
		temp+=next_byte;	
	}
	
	if (DEBUG > 0)
		std::cerr << temp <<endl;
	return temp;
}
