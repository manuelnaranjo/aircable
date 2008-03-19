#ifndef NODE_H_
#define NODE_H_

/*
 *  Node handler.
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

#include <mxml.h>
#include <mxml_defs.h>

#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <unistd.h>

#include "types.h"
#include "spp/sppclient.h"
#include "curl/post.h"
#include "mxml/xml.h"
#include "menu.h"

int getSelected();

void nodemain(int channel);
void simulate();

//TAGS that we might want to look for
#define TAG_MONITOR 		strdup("monitor")
#define TAG_DISPLAY_TEMP 	strdup("display")
#define TAG_RETURN_TEMP  	strdup("return")
#define TAG_COMP_TEMP		strdup("compare")
#define TAG_RETURN_VARS		strdup("returnvars")
#define TAG_SELECT_MENU		strdup("selectmenu")
#define TAG_TEXT			strdup("text")
#define TAG_VALUE			strdup("value")
#define TAG_RESP_FUNCTION	strdup("responsefunction")
#define TAG_AUTHENTICATE	strdup("authenticate")
#define TAG_ACCEPT			strdup("accept")
#define TAG_UPDATE			strdup("checkupdate")
#define TAG_NOEXIT			strdup("noexit")


//FLAGS
#define FDISPLAY_TEMP 	1
#define FRETURN_TEMP	2
#define FCOMPARE_TEMP	4


//enable debug
#define DEBUG_UTILS

#endif /*NODE_H_*/

