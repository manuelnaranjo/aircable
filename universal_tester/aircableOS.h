#ifndef __AIRcableOS_h__
#define __AIRcableOS_h__

#include <string>
#include <SerialPort.h>
#include <SerialStream.h>

#include <termios.h>


#define CMD_SEQUENCE		"+++\n"
#define LIST				"l"
#define	MODE				"a"
#define MODE_CABLE_SLAVE	"3"
#define EXIT				"e"

using namespace LibSerial;
using namespace std;

extern "C++" {
	class AIRcableOS : public SerialStream{
		private:
			string			portID;
			string			buffer;
			//int				portFile;
			//struct termios termios_p;

		public:

		//constructor
		AIRcableOS(void);

		AIRcableOS(const string port);

		//Destructor
		~AIRcableOS(void);

		//Open the tty layer
		void Open(void);

		//Send and AIRcable OS
		void sendCommand(string command);

		void emptyBuffer();

		string readBuffer(void);

		//Parses the bt address of the device,
		string getBTAddress(string input);

		//Check if there is at least one AIRcable OS connected to the pc
		bool checkConnected(void);
	};
}//extern "C++"


#endif //__AIRcableOS_h__
