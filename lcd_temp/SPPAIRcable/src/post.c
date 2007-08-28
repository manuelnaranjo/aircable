/*
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
 * 
 * [1] http://people.csail.mit.edu/albert/bluez-intro/index.html
 *
 */

#include "post.h"

//Private functions
// string structure handlers
#define SIZE 1024
static char * buffer;
static int length;
static int size;

static void append(char *add);
static void extend(int len);
static char* allocate();
//end of private functions declarations

//
//  libcurl write callback function
//
static int writer(char *data, size_t size, size_t nmemb, char *writerData) {
  if (!writerData) return 0;
  
  append(data);
  return size * nmemb;
}

/*
 * This function 
 */
char * doPost(char * content){
	char *out, *postData;
	CURL *curl = NULL;	
	CURLcode res;
		
	buffer = allocate();
	
	//init curl.
	curl = curl_easy_init();		
	if(!curl){
		perror("Couldn't create curl object");
		return NULL;
	}				
	
	postData = calloc(strlen(content) +10, sizeof(char));
	
	//generate post content.	
	sprintf( postData, "xml=%s", content );
	
	//res=curl_easy_setopt(curl, CURLOPT_VERBOSE, 1);
	
	//set up curl stuff
	res = curl_easy_setopt(curl, CURLOPT_URL, URL);
	if (res != CURLE_OK) {
    	fprintf(stderr, "Failed to set URL [%d]\n", res);
		return NULL;
	}
	
	res = curl_easy_setopt(curl, CURLOPT_POSTFIELDS, postData);
	if (res != CURLE_OK) {
    	fprintf(stderr, "Failed to set POSTFIELDS [%d]\n", res);
		return NULL;
	}
	
  	res = curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writer);
  	if (res != CURLE_OK) {
    	fprintf(stderr, "Failed to set WRITEFUNCTION [%d]\n", res);
		return NULL;
	}
	
    res = curl_easy_setopt(curl, CURLOPT_WRITEDATA, &buffer);
    if (res != CURLE_OK) {
    	fprintf(stderr, "Failed to set WRITEDATA [%d]\n", res);
		return NULL;
	}
  	
	//commit
	res = curl_easy_perform(curl);
	if (res != CURLE_OK) {
		fprintf(stderr, "Failed to perform put action [%d]\n", res);
		return NULL;
	}
	
	out = calloc(length, sizeof(char));
	
	strcpy(out, buffer);
	
	if (buffer) 
		free(buffer);
	
	length=0;
	size=0;
		
	curl_easy_cleanup(curl);

	return out;
}

/*
 * This function generates the xml that we will send to the server when ever we
 * want to reply or start a transaction.
 * 
 * The format for the xml file is:
 * <?xml  version='1.0' ?>
 * <content>
 * <function> [VALUE] </function>
 * <nodeid> [VALUE] </nodeid>
 * <selectedvalue> [VALUE] </selectedvalue>
 * <currentTemp> [VALUE] </currentTemp>
 * <OPTIONAL KEYS>
 * </content> 
 */ 
char * generateXML(char * function, char * nodeId, char * value, double temp, 
		char *optionalKeys){
	char* out;
	int len;
	
	char * format;
	
	if (optionalKeys == NULL){
		format  = 	"<?xml  version='1.0' ?>\n"
					"<content>\n"
					"<function>%s</function>\n"
					"<nodeid>%s</nodeid>\n"
					"<selectedvalue>%s</selectedvalue>\n"
					"<currentTemp>%.2f</currentTemp>\n"
					"</content>";

		len = strlen ( format );
			
		len+=strlen(function);
		len+=strlen(nodeId);
		if (value)
			len+=strlen(value);
		len+=16;
			
		out  = calloc(len, sizeof(char));
		
		sprintf(out, format , function,
				 nodeId, (value ? value : ""), temp);

	} else {
		format  = 	"<?xml  version='1.0' ?>\n"
					"<content>\n"
					"<function>%s</function>\n"
					"<nodeid>%s</nodeid>\n"
					"<selectedvalue>%s</selectedvalue>\n"
					"<currentTemp>%.2f</currentTemp>\n"
					"%s"
					"</content>";
		
		len = strlen ( format );
			
		len+=strlen(function);
		len+=strlen(nodeId);
		if (value)
			len+=strlen(value);
		len+=16;
			
		out  = calloc(len, sizeof(char));
		
		sprintf(out, format , function,
				 nodeId, (value ? value : ""), temp, optionalKeys);
	}
		
#ifdef DEBUG_POST
	printf("Sending:\n%s\n", out);
#endif	
	return out;
}



/**
 * Send a generic request.
 */
MXML_DOCUMENT *sendRequest(char * function, char * nodeId, 
		char * value, double temp, MXML_DOCUMENT *initial){
	MXML_DOCUMENT * doc;	
	char * xml;
	char * rep;
	char * optional = NULL;	
	
	if (initial != NULL)
		optional = getReturnVars(initial);		
	
		
	
	xml = generateXML(function, nodeId, value, temp, optional);
	rep = doPost(xml);
	doc=mxml_buffer(rep, 0);
	
#ifdef DEBUG_POST
	printf("Got from Server:\n");
	mxml_write_file( doc, stdout, MXML_STYLE_INDENT | MXML_STYLE_THREESPACES );
#endif

	return doc;
} 

/**
 * Initiate communications with main server.
 */
MXML_DOCUMENT  *sendInitial(char * nodeId, double temp){			
	return sendRequest("authenticate", nodeId, NULL, temp, NULL);
}

// appends to the end of the string
static void append(char *add){
	int len;
	len = strlen(add);
	
	if (len > size - length)
		extend(len);
	
	strcat(buffer, add);
	
	length+=len;	
}


// extend the buffer in SIZE bytes
static void extend(int len){
	int newsize;
	newsize = (((size + len) / SIZE)) * SIZE + SIZE;
	
	buffer = (char*)realloc(buffer, newsize);
	
	size=newsize;	
}

static char * allocate(){
	char * out;
	out = (char *)calloc(SIZE, sizeof(char));
	return out;
}
