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
 
#ifndef UTILS_H_
#define UTILS_H_

#include <stdlib.h>
#include <stdio.h>

#include <mxml.h>
#include <mxml_file.h>
#include <mxml_defs.h>

#include <string.h>
#include <malloc.h>

typedef struct RESULTS RESULTS;

struct RESULTS  {
   MXML_NODE * val;
   RESULTS * next;	
};

typedef struct menu_entry menu_entry;

struct menu_entry{
	char * text;
	char * value;
	int index;
	menu_entry * next;
} ;

MXML_DOCUMENT *mxml_buffer( char* buf, int style );
RESULTS* getOptions(MXML_DOCUMENT *doc);
int parseEntries(RESULTS *input, menu_entry *head);
MXML_NODE* getResponseFunction(MXML_DOCUMENT *doc);
char* getReturnVars(MXML_DOCUMENT *doc);

#define DEBUG_UTILS 1

#endif /*UTILS_H_*/
