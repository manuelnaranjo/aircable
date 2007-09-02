/*
 *  Simple www post application.
 *
 *  Copyright (C) 2007 Naranjo,manuel <manuel@aircable.net>
 *  Copyright (C) 2007 Wireless Cables Inc  <aircable.net>
 * 
 *  Part of the work is based on: 
 * 			http://curl.haxx.se/lxr/source/docs/examples/getinmemory.c
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

#include "post.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <curl/curl.h>
#include <curl/types.h>
#include <curl/easy.h>

char * TARGET_URL = NULL;

struct MemoryStruct {
	char *memory;
	size_t size;
};

void postSetURL(const char* newURL){
	int len = strlen(newURL);
	if (TARGET_URL)
		free(TARGET_URL);

	TARGET_URL = malloc(len+1);
	strncpy(TARGET_URL, newURL, len);
	TARGET_URL[len]=0;
}

int postGetURL(char * url){
	int len = strlen(TARGET_URL);
	strncpy(url, TARGET_URL, len);
	return len;
}

void postCleanUP(){
	if (TARGET_URL)
		free(TARGET_URL);
}

void *myrealloc(void *ptr, size_t size)
{
	if(ptr)
		return realloc(ptr, size);
	else
		return malloc(size);
}

size_t
appendBuffer(void *ptr, size_t size, size_t nmemb, const void *data)
{
	size_t realsize = size * nmemb;
	struct MemoryStruct *mem = (struct MemoryStruct *)data;

	mem->memory = (char *)myrealloc(mem->memory, mem->size + realsize + 1);
	if (mem->memory) {
		memcpy(&(mem->memory[mem->size]), ptr, realsize);
		mem->size += realsize;
		mem->memory[mem->size] = 0;
	}
	return realsize;
}

/*
 * This function 
 */
/*char* postDoPost(const char * content){
	char *postData = NULL, *out = NULL;
	CURL *curl = NULL;	
	CURLcode res;
	
	struct MemoryStruct chunk;

	chunk.memory=NULL;
	chunk.size = 0;

	
	if (!TARGET_URL){
		fprintf(stderr, "You need to set the URL first\n");
		return NULL;
	}
	
	if (!content){
		fprintf(stderr, "Content can't be null when calling doPost()\n");
		return NULL;
	}

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
	
	res = curl_easy_setopt(curl, CURLOPT_URL, TARGET_URL);
	if (res != CURLE_OK) {
    	fprintf(stderr, "Failed to set URL [%d]\n", res);
		return NULL;
	}
	
	res = curl_easy_setopt(curl, CURLOPT_FTP_SSL, CURLFTPSSL_NONE);
	if (res != CURLE_OK) {
	   	fprintf(stderr, "Failed to set URL [%d]\n", res);
		return NULL;
	}
	
	res = curl_easy_setopt(curl, CURLOPT_POSTFIELDS, postData);
	if (res != CURLE_OK) {
    	fprintf(stderr, "Failed to set POSTFIELDS [%d]\n", res);
		return NULL;
	}
	
  	res = curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteMemoryCallback);
  	if (res != CURLE_OK) {
    	fprintf(stderr, "Failed to set WRITEFUNCTION [%d]\n", res);
		return NULL;
	}
	
    res = curl_easy_setopt(curl, CURLOPT_WRITEDATA, &chunk);
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
	
	free(postData);
	
	if (!chunk.memory){
		perror("Buffer is NULL\n");		
		return NULL;
	}
	
	if (!chunk.size){
		perror("Buffer is empty\n");
		free(chunk.memory);
		return NULL;
	}
	
	out = malloc(chunk.size);
	if (!out){
		perror("Couldn't allocate out\n");
		free(chunk.memory);
		return NULL;
	}
	
	strncpy(out, chunk.memory, chunk.size);
	
	if (chunk.memory) 
		free(chunk.memory);
	
	curl_easy_cleanup(curl);

	return out;
}*/

int post(const char * content, char* out, const int maxlen){
	FILE *fpipe;
	char const *commandFormat = "curl -d \"xml=%s\" '%s' -s -S"; 
	char *commandBuffer;
	char line[256];
	int count = 0;
	int bufLen = 0, len = 0;	
	bufLen  = strlen(commandFormat);
	bufLen += strlen(TARGET_URL);
	bufLen += strlen(content);	
	commandBuffer = malloc(bufLen + 5);
	sprintf(commandBuffer, commandFormat, content, TARGET_URL);

	if ( !(fpipe = (FILE*)popen(commandBuffer,"r")) )
	{
		perror("Couldn't fork curl\n");
		free(commandBuffer);
		return ERROR;
	}

	while ( fgets( line, sizeof line, fpipe))
	{
		if (!out)
			printf("%s", line);
		else {
			len = strlen(line);
			if (len + count < maxlen){
				strcat(out, line);
				count+=len;
				out+=len;
			}
		}
	}
	pclose(fpipe);
	
	if (out && count < maxlen)
		out=0;
		
	
	free(commandBuffer);
	
	return count;
}

int main(void){
	const char addr[] = "http://www.smart-tms.com/xmlengine/transaction.cfm";	
	
	postSetURL(addr);
	
	/*char * t = NULL; 
	t = postDoPost("hello\n");
	
	fprintf(stdout, "%s", t);
	
	free(t);*/
	
	char * res = NULL;
	
	res = malloc(5048*sizeof(char));
	if (!res){
		postCleanUP();
		return -1;
	}
		
	
	post(	
		"<?xml  version='1.0' ?>"
		"<content>"
			"<function>authenticate</function>"
			"<nodeid>1234-1234-1234-1234</nodeid>"
			"<selectedvalue></selectedvalue>"
			"<currentTemp>99</currentTemp>"
		"</content>",
		res,
		5048);
	
	if (res){
		printf("%s\n", res);	
		free(res);
	}
	
	postCleanUP();
	
	return 0;
}
