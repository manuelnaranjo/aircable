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

#ifndef __AIRcableUSB_h__
#define __AIRcableUSB_h__
#include <string>
#include <SerialStream.h>
#include <usbpp.h>

using namespace LibSerial;
using namespace std;
using namespace USB;

#define AIRCABLE_VID		0x16CA	/* Vendor Id */
#define AIRCABLE_USB_PID	0x1502	/* Product Id */

#define DEBUG				1


extern "C++" {
	class AIRcableUSB : public SerialStream{
		protected:
			string portID;
			
		public:

		//constructor
		AIRcableUSB(void);

		AIRcableUSB(const string port);

		//Destructor
		~AIRcableUSB(void);

		//Open the tty layer
		void Open(void);

		//Send and AIRcable USB command with the ^A + Command + 0xd stuff
		void sendCommand(string command);

		//Parses the bt address of the device,
		string getBTAddress(string input);

		//Check if there is at least one AIRcable USB connected to the pc
		bool checkConnected(void);

		string readBuffer();
	};
} //extern "C++"

#endif //__AIRcableUSB_h__

