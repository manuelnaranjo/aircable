/*
    Reads an xml file from the stdin, and then prints the values from the
    fields to stdout.

    Author: Naranjo Manuel <manuel@aircable.net>
    Author: Giancarlo Niccolai <gian@niccolai.ws>

    $Id: mxml_test.c,v 1.2 2003/06/30 18:20:49 jonnymind Exp $
*/

#include <stdlib.h>
#include <mxml.h>
#include <mxml_file.h>

int main( int argc, char *argv[] )
{
    MXML_DOCUMENT *doc = mxml_document_new();
    MXML_ITERATOR iter;
    MXML_NODE *node;
    FILE *fp;

    fp = stdin;
   
    mxml_read_file( fp, doc, 0 );

    if ( doc->status == MXML_STATUS_ERROR ) {
	fprintf( stderr,  "ERROR while reading the document: (%d) %s\n",
	    doc->error, mxml_error_desc( doc->error ) 
	);
	
	exit (-1);
    }
   
   
    if ( doc->status == MXML_STATUS_MALFORMED ) {
	fprintf( stderr, "Invalid XML document. Line %d: (%d) %s\n",
	    doc->iLine, doc->error, mxml_error_desc( doc->error ) );
	    
	exit(-1);
    }

    //print keys and values
    mxml_iterator_setup( &iter, doc );
    while ( ( node = mxml_iterator_next( &iter ) ) != NULL ) {
	
	if ( node -> data )
	    printf("%s: %s\n", node->name, node->data);
	else
	    printf("%s \n", node->name);
	
    }

    if (doc)
	mxml_document_destroy(doc);
	
   return 0;
}
