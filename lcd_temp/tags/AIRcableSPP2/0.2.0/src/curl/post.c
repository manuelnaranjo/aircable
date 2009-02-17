/*
 *  Simple www post application.
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

 //
 //
 // NLUS2<->LCD Messages format
 // 	Temperature:
 //				!<VALUE>:<CALIBRATION>#<TYPE>
 // 
 //		Sensor Type <TYPE>:
 //				K: Thermocouple type K.
 //				I: Infrared Sensor.
 //
 //		LCD Menu:
 //				%<AMOUNT>	(amount of messages that will be sended from the 
 //										server)
 //				<ID><TEXT> 	(2 hex chars are assigned to index)
 //				&<ID>		(Received message, ready for next)
 //				$<ID>		(Last message received)
 //				@<ID>		(Accepted value, meassured temperature must be sent
 //										 after the ID)
 //				^C(char 03) (Close connection, the LCD wants to close the connection)
 //				
 //    				
 //
 //
 //

#include "post.h"

char * TARGET_URL = NULL;

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

int post(const char * content, char* out, const int maxlen){
	FILE *fpipe;
	char const *commandFormat = "curl -d \"xml=%s\" '%s' -s -S"; 
	char *commandBuffer;
	char line[256];
	int count = 0;
	int bufLen = 0, len = 0;
	
	if (!TARGET_URL){
		fprintf(stderr, "You need to setup URL before calling post\n");
		return ERROR;
	}	
	
	if (!content){
		fprintf(stderr, "Can't send a null content\n");
		return ERROR;
	}
	
	printf("Sending: \n%s\n", content);
	
	bufLen  = strlen(commandFormat);
	bufLen += strlen(TARGET_URL);
	bufLen += strlen(content);	
	commandBuffer = malloc(bufLen + 5);
	
	sprintf(commandBuffer, commandFormat, content, TARGET_URL);

	if ( !(fpipe = (FILE*)popen(commandBuffer,"r")) )
	{
		perror("Couldn't start curl\n");
		free(commandBuffer);
		return ERROR;
	}

	while ( fgets( line, sizeof line, fpipe))
	{
		if (!out)
			printf("%s", line);
		else if (line[0]!=0){
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

int postmain(void){
	
	postSetURL(addr);
	
	char * res = NULL;
	int ret = 0;
	res = calloc(5048,sizeof(char));
	if (!res){
		postCleanUP();
		return -1;
	}
		
	
	ret = post(	
		"<?xml  version='1.0' ?>"
		"<content>"
			"<function>authenticate</function>"
			"<nodeid>1234-1234-1234-1234</nodeid>"
			"<selectedvalue></selectedvalue>"
			"<currentTemp>99</currentTemp>"
		"</content>",
		res,
		5048);
	
	if (ret > 0)
		printf("%s\n", res);	
	free(res);	
	
	postCleanUP();
	
	return 0;
}
