/*
 *  XML parsing functions, using mxml[1]
 *
 *  Copyright (C) 2007 Naranjo,manuel <manuel@aircable.net>
 *  Copyright (C) 2007 Wireless Cables Inc <http://www.aircable.net>
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
 *  [1] http://mxml.sourceforge.net/
 * 
 */

#include "xml.h"


MXML_DOCUMENT *mxml_buffer(const char* buf, int style )
{
    MXML_DOCUMENT *doc = mxml_document_new();
    MXML_REFIL *refil;
      
    if (!buf){
	return NULL;
    }
   
    if (!doc){	
	return NULL;
    }
   
    int len = -1;
   
    len = strlen(buf);

    if ( doc->status != MXML_STATUS_OK )
	return doc;

    doc->iLine = 1;
   
    refil = mxml_refil_new(NULL, (void*)buf, len, len);

    mxml_node_read( refil, doc->root, doc, style );

    mxml_refil_destroy( refil );
    
#ifdef XML_DEBUG
    fprintf(stdout, "XML DOCUMENT: \n");
    mxml_write_file(doc, stdout, MXML_STYLE_INDENT | MXML_STYLE_THREESPACES );
    fprintf(stdout, "\nXML DOCUMENT PARSED ----\n");
#endif
    
    return doc;
}


int xmlmain(int argc, char *argv[]){	
	MXML_DOCUMENT *doc = mxml_buffer(argv[1], 1);
	
	if (!doc)
		return -1;
	
	mxml_document_destroy(doc);
	
	return 0;
}

