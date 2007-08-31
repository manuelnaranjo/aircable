/*
 *
 *  SPPclient, little spp client.
 *
 *  Copyright (C) 2007 Naranjo,manuel <manuel@aircable.net>
 *  Copyright (C) 2007 Wireless Cables Inc  <aircable.net>
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

#define _GNU_SOURCE

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

#include "errorcodes.h"

//Public functions
/** Register SPP service **/
int sppRegister(int channel);
/** Unregister SPP service **/
int sppUnregister();
/** Read a line from the spp socket **/
int sppReadLine(char * buf, int MAXLEN);
/** Write a line to the spp socket **/
int sppWriteLine(const char * buf);
/** Register socket for listening **/
int sppListen();
/** Wait for connections, this method will block **/
int sppWaitConnection();
/** Disconnect SPP socket **/
int sppDisconnect();

#endif /*SPPCLIENT_H_*/
