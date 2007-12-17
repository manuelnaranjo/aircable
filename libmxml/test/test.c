#include <stdlib.h>
#include <stdio.h>
#include <mxml.h>
#include <string.h>
#include <mxml_file.h>
#include <mxml_defs.h>

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
   
    refil = mxml_refil_new(NULL, buf, len, len);

    mxml_node_read( refil, doc->root, doc, style );

    mxml_refil_destroy( refil );   
   
    return doc;
}

int main(int argc, char *argv[]) {
    fprintf(stdout, "%i, %s\n\r", argc, argv[1] );
    MXML_DOCUMENT *doc = mxml_buffer(argv[1], 1);
    
    if (!doc)
	return;
    
    fprintf(stdout, "BEGING\n");
    
    mxml_write_file(doc, stdout, MXML_STYLE_INDENT | MXML_STYLE_THREESPACES );
    
    mxml_document_destroy(doc);
}
