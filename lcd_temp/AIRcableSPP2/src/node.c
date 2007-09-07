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

#include "node.h"

RESULTS* results_new(){
	return (RESULTS*) malloc(sizeof(RESULTS));
}

void results_destroy(RESULTS* node){
	if (!node)
		return;
	
	if (node->val)
		mxml_node_destroy(node->val);
	
	if (node->next)
		results_destroy(node->next);
	
	free(node);
}

node * node_new(){
	node * out;
	
	out = (node*) malloc (sizeof(node));
	
	out->function = 0;
	out->lastReply = 0;
	out->nodeId = 0;
	out->socket = 0;
	out->value = 0;
	out->temperature=0.0f;
	
	return out;
}

void node_destroy(node * node){
	if (!node)
		return;
	
	if (node->function)
		free(node->function);
	
	if (node->lastReply)
		mxml_document_destroy(node->lastReply);
	
	if (node->nodeId)
		free(node->nodeId);
	
	if (node->socket)				
		free(node->socket);
	
	if (node->value)
		free(node->value);
	
	free(node);
}

menu_entry* menu_entry_new(){
	return (menu_entry*)malloc(sizeof(menu_entry));
}

void menu_entry_destroy(menu_entry* node){
	if (!node)
		return;
	
	if (node->text)
		free(node->text);
	
	if (node->value)
		free(node->value);
	
	if (node->next)
		menu_entry_destroy(node->next);
	
	free(node);
}

int calcTemp(int val, int calib, char type, float *realValue){
	switch (type){
		case 'K':
			*realValue=(125/2566.4)*(val+calib);
			return OK;
		case 'I':
			*realValue=val/10;
			return OK;
		default:
			fprintf(stderr,"%c is not a valid type\n", type);
			return ERROR;
	}
}

int parseTemp(char * buf, float * rvalue){
	float value, calib;
	char type;
	
	//Message format: !<VAL>:<CAL>#<TYPE>
		
	if ( sscanf(buf, "!%f:%f#%1c", &value, &calib, &type) != 3 ){
		fprintf(stderr, "%s Doesn't match pattern\n", buf);
		return ERROR;
	}
	
	return calcTemp(value, calib, type, rvalue);
}

char* getReturnVars(MXML_DOCUMENT *doc){
	MXML_NODE *node;
	MXML_ITERATOR iter;
	char * options;
		
	mxml_iterator_setup( &iter, doc );
	
	node =  mxml_iterator_scan_node( &iter, "returnvars" );
	
	if (!node)
		return NULL;
	
	options = calloc (2048, sizeof (char));
	
	node = node->child;
	
	while (node){
		sprintf(options, 
				"%s<%s>%s</%s>\n",  
				options,
				node->name,
				node->data,
				node->name);
		
		node = node->next;
				
	}
	
	return options;
	
}

char * generateXML(const node * node) {
	char* out = NULL;	
	int len = 0;
	
	if (!node){
		fprintf(stderr, "Can't generate xml file out of a null node\n");
		return NULL;
	}
	
	char * format;
	char * optional = 0;
	
	format  = 	"<?xml  version='1.0' ?>\n"
				"<content>\n"
				"<function>%s</function>\n"
				"<nodeid>%s</nodeid>\n"
				"<selectedvalue>%s</selectedvalue>\n"
				"<currentTemp>%.2f</currentTemp>\n"
				"%s"
				"</content>\n";

	len = strlen ( format );
	if (node->function)
		len+=strlen(node->function);
	
	if (node->nodeId)
		len+=strlen(node->nodeId);
	
	if (node->value)
		len+=strlen(node->value);
	
	if (node->lastReply){
		optional = getReturnVars(node->lastReply);
		len+=strlen(optional);
	}
	
	len+=1;
			
	out  = (char*)calloc(2048, sizeof(char));
	
	len = sprintf(out, 
			format, 
			node->function, 
			node->nodeId, 
			(node->value ? node->value : ""), 
			node->temperature, //temp,
			(node->lastReply ? optional : "")
	);
	
	if (optional)
		free(optional);
	
	return out;
}

int sendRequest(node* node){
	MXML_DOCUMENT * doc;	
	char * xml;
	char * rep = NULL;
	int ret;
	
	xml = generateXML(node);
	
	if (!xml){
		fprintf(stderr,"Something went wrong when generating xml content\n");
		return ERROR;
	}		
	
	rep = calloc(5048, sizeof(char));
	
	ret = post(xml, rep, 5048);
	
	free(xml);
	
	if (!ret){
		perror("Coulnd't do post\n");
		return ERROR;
	}
	
	doc=mxml_buffer(rep, 0);
	
	free(rep);

	node->lastReply = doc;
	
	return OK;
} 

int initConnection(node* node){
	int bytes_read = 0;
	int counter = 0;
	float val;
	char *buf;
	
	if (!node){
		fprintf(stderr, "Node can't be null\n");
		return ERROR;
	}
	
	if (!node->socket){
		fprintf(stderr, "You need to initializate spp side first");
		return ERROR;
	}
		
	
	buf=calloc(1024, sizeof(char));
	
	while (bytes_read <= 0){
		bytes_read = sppReadLine(node->socket, buf, 1024);

		if (bytes_read <= 0 && counter == 3){
			fprintf(stderr, 
				"Connection timeout, device is not sending us the current temp\n");
			return ERROR;
		}
		usleep(100*1000);
		counter++;
	}
	
	if ( parseTemp(buf, &val) != OK )
		return ERROR;
	
	free(buf);
	
	return sendRequest(node);
}

void nodemain(int channel){
	const char addr[] = "http://www.smart-tms.com/xmlengine/transaction.cfm";	
	
	postSetURL(addr);
	
	node * node = node_new();
	
	sppSocket *socket;
	
	socket = (sppSocket*) malloc(sizeof(sppSocket));
	
	socket->channel=channel;
	
	sppRegister(socket);
	sppListen(socket);
	sppWaitConnection(socket);
	
	node->socket = socket;
	
	char *t = calloc(500, sizeof(char)); sprintf(t, "1234-1234-1234-1234");
	t[strlen(t)]=0;
	node->nodeId=t;
	t = calloc(500, sizeof(char)); sprintf(t, "authenticate");
	t[strlen(t)]=0;
	node->function=t;
	node->value = NULL;
	
	initConnection(node);
	
	sppDisconnect(node->socket);
	sppUnregister(node->socket);
	sdp_cleanup();
			
	postCleanUP();
	
	node_destroy(node);
}


