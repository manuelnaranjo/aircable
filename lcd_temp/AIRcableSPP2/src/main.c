/*
 *  AIRcableSPP main app
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

#include <stdio.h>
#include <string.h>

#include "mxml/xml.h"
#include "curl/post.h"
#include "spp/sppclient.h"
#include "node.h"

int main(int argc, char *argv[]) {

	if (argc > 1){
		argv++;
		
		while (argv[0]!=NULL){
			if (!strcmp("--testxml", argv[0])){
				if (!argv[1]){
					fprintf(stderr, "Wrong syntaxis, run help\n");
					return -1;
				}
				
				argv++;
				xmlmain(argc, argv);								
			}else 
			if(!strcmp("--testpost", argv[0])){
				postmain();
			}else
			if (!strcmp("--testspp", argv[0])){
				int channel = 1;
				if (argv[1]!=NULL){
					channel = atoi(argv[1]);
					argv++;
				}				
				sppmain(channel);
			}
			else 
			if (!strcmp("--testnode", argv[0])){
				int channel = 1;
				if (argv[1]!=NULL){
					channel = atoi(argv[1]);
					argv++;
				}				
				nodemain(channel);
			}
			
			else 
			if (!strcmp("--simulate", argv[0])){
				simulate();								
			}
			

			
			else 
			if (!strcmp("--help", argv[0])){
				fprintf(stderr, "Usage: \n");
				fprintf(stderr, "\t\t--testxml Content\n");
				fprintf(stderr, "\t\t--testpost\n");
				fprintf(stderr, "\t\t--testspp [channel]\n");
				fprintf(stderr, "\t\t--testnode [channel]\n");
				fprintf(stderr, "\t\t--help\n");
				return 0;
			}
			
			argv++;
		}
	} else {
	    fprintf(stdout, "Using channel 1");
	    nodemain(1);
	}
	
	return 0;
}
