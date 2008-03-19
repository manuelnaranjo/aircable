/*
 *
 *  SPPclient, little spp client.
 *
 *  Copyright (C) 2007 Naranjo,manuel <manuel@aircable.net>
 *  Copyright (C) 2007 Wireless Cables Inc <http://www.aircable.net>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 * 
 */

#ifndef SPPCLIENT_H_
#define SPPCLIENT_H_

#include <stdio.h>
#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>
#include <time.h>
#include <poll.h>

#include <sys/ioctl.h>
#include <sys/socket.h>

#include <fcntl.h>

#include <bluetooth/bluetooth.h>
#include <bluetooth/hci.h>
#include <bluetooth/hci_lib.h>
#include <bluetooth/rfcomm.h>
#include <bluetooth/sdp.h>
#include <bluetooth/sdp_lib.h>

#include "../types.h"
#include "../errorcodes.h"

//Public functions
/** Register SPP service **/
int sppRegister(sppSocket * socket);
/** Unregister SPP service **/
int sppUnregister(sppSocket * socket);
/** Read a line from the spp socket **/
int sppReadLine(const sppSocket *socket, char * buf, int MAXLEN);
/** Write a line to the spp socket **/
int sppWriteLine(const sppSocket *socket, const char * buf);
/** Register socket for listening **/
int sppListen(sppSocket *socket);
/** Wait for connections, this method will block **/
int sppWaitConnection(sppSocket *socket);
/** Disconnect SPP socket **/
int sppDisconnect(sppSocket *socket);

int sppmain(int channel);

#endif /*SPPCLIENT_H_*/
