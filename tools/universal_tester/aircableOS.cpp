#include <string.h>
#include <iostream>
#include <SerialStream.h>
#include <SerialPort.h>
#include <time.h>

#include <termios.h>
#include <fcntl.h>
#include <cerrno>

#include <sys/ioctl.h>

#include "aircableOS.h"

//using namespace LibSerial;
using namespace std;

#define debug				3

AIRcableOS::AIRcableOS() : SerialStream(){
	portID = "/dev/ttyS0";
	buffer = "";
}

AIRcableOS::AIRcableOS(const string port) : SerialStream(){
	portID = port;
	buffer = "";
}

AIRcableOS::~AIRcableOS(){
	if (SerialStream::IsOpen())
		SerialStream::Close();
}


void AIRcableOS::Open(){
	SerialStream::
	//first we ask serial stream to open the port
	SerialStream::Open(portID);
	SerialStream::SetBaudRate( SerialStreamBuf::BAUD_115200 ) ;
	SerialStream::SetCharSize( SerialStreamBuf::CHAR_SIZE_8 ) ;
	SerialStream::SetNumOfStopBits(1);
	SerialStream::SetParity( SerialStreamBuf::PARITY_NONE ) ;
	SerialStream::SetFlowControl( SerialStreamBuf::FLOW_CONTROL_HARD ) ;

	SerialStream::clrRTS();
	SerialStream::clrCTS();
}

void AIRcableOS::sendCommand(string command){
	SerialStream::flush();
	SerialStream::write(command.c_str(),command.size());
}

string AIRcableOS::getBTAddress(string input){
	string out = "";
	string temp = "BT Address: 112233445566";
	string header = "BT Address: ";
	unsigned int index;
	if (input.size() >= temp.size()){
		index = input.find("BT Address: ",0);
		if (index != string::npos){
			temp="112233445566";
			input = input.substr(index + header.size() , temp.size());
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

string AIRcableOS::readBuffer(void){
	string temp = "";
	
	/*if (debug > 0)
		std::cerr<<"READ:"<<endl;*/
	
	while( SerialStream::rdbuf()->in_avail() > 0) {
		char next_byte;
		SerialStream::get(next_byte);
		temp+=next_byte;
		if (debug > 0)
			std::cerr << next_byte;	
	}
	
	/*if (debug > 0)
		std::cerr<<endl;*/

//	buffer+=temp;

	return temp;
}

bool AIRcableOS::checkConnected(void){
	bool ans;
	AIRcableOS::setRTS();
	//Sleep for 300ms to give time enought to the electric signal to stabilize
	usleep(300*1000);
	ans = AIRcableOS::getCTS();

	AIRcableOS::clrRTS();

	return ans;
}

void AIRcableOS::emptyBuffer(void){
	buffer = "";
}
