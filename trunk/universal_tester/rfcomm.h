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

#ifndef __AIRcableRFCOMM_h__
#define __AIRcableRFCOMM_h__
#include <string>

#define ERROR 0xFFFF

using namespace std;

extern "C++"{	
	class RfComm{
		
		private:
			int		rfcommSocket;
			string	bt_addr;

		public:
			//constructor
			RfComm(void);

			RfComm(string bt_addr);

			~RfComm(void);

			void Open(void);

			void Close(void);

			int Write(string in);

			string Read(void);

			void setAddress(string new_addr);

			int getLinkQuality(uint8_t * lq);

			int getRSSI(int8_t * rssi);

			int getTransmitPowerLevel(int8_t * level, uint8_t * type);
	};
}; //C++

static int find_conn(int s, int dev_id, long arg);

#endif //__AIRcableRFCOMM_h__
