#include <qapplication.h>
#include "qtaircablemainform.h"

int main( int argc, char ** argv )
{
	QApplication a( argc, argv );
	qtAIRcableMainForm w;
	w.show();
	a.connect( &a, SIGNAL( lastWindowClosed() ), &a, SLOT( quit() ) );
	return a.exec();
}
