#ifndef __AIRcableSerial_h__
#define __AIRcableSerial_h__

#include "aircableUSB.h"

extern "C++" {
	class AIRcableSerial : public AIRcableUSB{
		public:

		//constructor
		AIRcableSerial(void);

		AIRcableSerial(const string port);
		
		void Open(void);

		//Check if there is at least one AIRcable Serial connected to the pc
		bool checkConnected(void);
	};
}//extern "C++"


#endif //__AIRcableSerial_h__
