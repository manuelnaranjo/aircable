#ifndef DEFS_H_
#define DEFS_H_
/*
 *  AIRcableSPP data types. This structures are shared all over the project
 * 	We have included functions to allocate and to destroy this structures too.
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


#include <mxml_defs.h>
#include <bluetooth/bluetooth.h>


struct sppSocket{
	/* RFcomm socket */
	uint32_t SPPsocket;
	/* Listening socket, opened once we get connected. */
	uint32_t SPPclient;
	/* Bluetooth address of our peer */
	bdaddr_t SPPpeer;

	/* Bluetooth interface used to register the SDP record */
	bdaddr_t interface;

	/* SPP record handle number*/
	uint32_t recHandle;
	
	/* channel beeing used */
	int channel;
};

typedef struct sppSocket sppSocket;

/*typedef struct RESULTS RESULTS;

struct RESULTS  {
   MXML_NODE * val;
   RESULTS * next;	
};*/

typedef struct menu_entry menu_entry;

struct menu_entry{
	char * text;
	char * value;
	int index;
	menu_entry * next;
};

struct node {	
	char 		  * function;
	char 		  * nodeId; 
	char 		  * value;
	char 		  type;
	double 		   temperature;
	MXML_DOCUMENT *lastReply;
	sppSocket 	  *socket;
	MXML_NODE	  *tag;
	char		  monitorProbe; //probe used for the monitor result 
};

typedef struct node NODE;

NODE * node_new();
void node_destroy(NODE * node);

//RESULTS* results_new();
//void results_destroy(RESULTS* node);

menu_entry* menu_entry_new();
void menu_entry_destroy(menu_entry* node);

menu_entry *sort(menu_entry* list, int n);

#endif /*DEFS_H_*/
