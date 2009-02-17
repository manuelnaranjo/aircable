/*
 *  AIRcableSPP, a little SPP server using BlueZ. Based in RfComm utility from 
 *  BlueZ, with some xml handling and file uploading to the web.
 *
 *  Copyright (C) 2007	Naranjo,manuel <manuel@aircable.net>
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
 */

#ifndef AIRPOST_H_
#define AIRPOST_H_

#include <stdlib.h>
#include <malloc.h>
#include <string.h>

#include <curl/curl.h>
#include <curl/types.h>
#include <curl/easy.h>

#include <mxml.h>
#include <mxml_file.h>

#define DEBUG_POST

#include "utils.h"

MXML_DOCUMENT *sendRequest(char * function, char * nodeId, char * value, 
		double temp, MXML_DOCUMENT *initial);
MXML_DOCUMENT *sendInitial(char * nodeId, double temp);

#define URL 
#endif
