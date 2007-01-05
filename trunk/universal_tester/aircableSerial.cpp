#include <SerialStream.h>
#include <SerialStreamBuf.h>

#include "aircableUSB.h"
#include "aircableSerial.h"

AIRcableSerial::AIRcableSerial() : AIRcableUSB("/dev/ttyS0"){
}

AIRcableSerial::AIRcableSerial(const string port) : AIRcableUSB(port){
}

bool AIRcableSerial::checkConnected(void){
	bool ans;
	AIRcableUSB::setRTS();
	//Sleep for 300ms to give time enought to the electric signal to stabilize
	usleep(300*1000);
	ans = AIRcableUSB::getCTS();

	AIRcableUSB::clrRTS();

	return ans;
}

void AIRcableSerial::Open(void){
	SerialStream::Open(AIRcableUSB::portID);
	
	SerialStream::SetBaudRate( SerialStreamBuf::BAUD_115200 );
	SerialStream::SetCharSize( SerialStreamBuf::CHAR_SIZE_8 );
	SerialStream::SetNumOfStopBits(1);
	SerialStream::SetParity( SerialStreamBuf::PARITY_NONE );
	SerialStream::SetFlowControl( SerialStreamBuf::FLOW_CONTROL_HARD );
}
