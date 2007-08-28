/*
 *
 *  AIRcableSPP, a little SPP server using BlueZ. Based in RfComm utility from 
 *  BlueZ, with some xml handling and file uploading to the web.
 *
 *  Copyright (C) 2007	Naranjo,manuel <manuel@aircable.net>
 *  Copyright (C) 2002-2007  Marcel Holtmann <marcel@holtmann.org> 
 *  					(BlueZ utils)
 *  Copyright (C) 2005-2006 Albert Huang <albert@csail.mit.edu>
 * 						(Wrote this incredible guide [1])
 *
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
 * [1] http://people.csail.mit.edu/albert/bluez-intro/index.html
 *
 */

#ifndef AIRCABLESPP_H_
#define AIRCABLESPP_H_

#define _GNU_SOURCE

#include <math.h>
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

#include <bluetooth/bluetooth.h>
#include <bluetooth/hci.h>
#include <bluetooth/hci_lib.h>
#include <bluetooth/rfcomm.h>
#include <bluetooth/sdp.h>
#include <bluetooth/sdp_lib.h>

#include <curl/curl.h>
#include <curl/types.h>
#include <curl/easy.h>

#include "post.h"

/* RFcomm socket */
static int SPPsocket;
/* Listening socket, opened once we get connected. */
static int SPPclient;
/* Bluetooth address of our peer */
static bdaddr_t slave;

/* Bluetooth interface used to register the SDP record */
static bdaddr_t interface;

/* SPP record handle number*/
static uint32_t recHandle;

/** Constants	**/
//times
#define TIMEOUT 			120

//no problems
#define OK					0
#define CONNECTION_CLOSE 	1

//errors
//TODO: Extend errors list
#define ERROR				-1


#define SPP_DEBUG

//Public functions
static int readline(int socket, char * buf, int amountChars);

#endif /*AIRCABLESPP_H_*/
