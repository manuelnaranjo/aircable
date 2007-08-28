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
 
#include "utils.h"

MXML_DOCUMENT *mxml_buffer( char* buf, int style )
{
   MXML_DOCUMENT *doc = mxml_document_new();
   MXML_REFIL *refil;
   int len = strlen(buf);

   if ( doc->status != MXML_STATUS_OK )
      return doc;

   doc->iLine = 1;
   
   refil = mxml_refil_new(NULL, buf, len, len);

   mxml_node_read( refil, doc->root, doc, style );

   mxml_refil_destroy( refil );   
   
   return doc;
}

//addapted from http://www.openasthra.com/c-tidbits/sorting-a-linked-list-with-bubble-sort/
menu_entry *sort(menu_entry* list, int n)
{
  menu_entry *lst, *tmp = list, *prev = NULL, *potentialprev = list;
  int idx, idx2;
  
  for (idx=0; idx<n-1; idx++) 
  {
    for (idx2=0,lst=list; 
         lst && lst->next && (idx2<=n-1-idx);
         idx2++)
    {
      if (!idx2)
      {
        //we are at beginning, so treat start 
        //node as prev node
        prev = lst;
      }
      
      //compare the two neighbors
      if (lst->next->index < lst->index) 
      {  
        //swap the nodes
        tmp = (lst->next?lst->next->next:0);
                
        if (!idx2 && (prev == list))
        {
          //we do not have any special sentinal nodes
          //so change beginning of the list to point 
          //to the smallest swapped node
          list = lst->next;
        }
        potentialprev = lst->next;
        prev->next = lst->next;
        lst->next->next = lst;
        lst->next = tmp;
        prev = potentialprev;
      }
      else
      {
        lst = lst->next;
        if(idx2)
        {
          //just keep track of previous node, 
          //for swapping nodes this is required
          prev = prev->next;
        }
      }     
    } 
  }
  return list;
}


int parseEntries(RESULTS *input, menu_entry *head){
	menu_entry * out;
	menu_entry * curr;
	int i = 0;
	
	out = NULL;
	
	while (input){
    	MXML_NODE *node;
    	
    	curr = (menu_entry *) malloc(sizeof(menu_entry));
    	
    	curr->next = out;
    	node = input->val->child;
    	
    	if (strcmp(node->name, "text") == 0){
    		curr->text = node->data;
    	}
    	else if (strcmp(node->name, "value") == 0){
    		curr->value = node->data;
    	}
    	curr->index = ++i;
    	
    	node = node->next;
    	
    	if (strcmp(node->name, "text") == 0){
    		curr->text = node->data;
    	}
    	else if (strcmp(node->name, "value") == 0){
    		curr->value = node->data;
    	}
   		
    	input=input->next;
    	
    	out = curr;
    }
    
    out = sort(out, i);
    
    if (out){
    	head->index = out->index;
    	head->next  = out->next;
    	head->text  = out->text;
    	head->value = out->value;
    }     
    
#ifdef DEBUG_UTILS
	curr = out;
	while (curr){
		printf("index: %i,\ttext: %s,\tvalue: %s\n", curr->index, curr->text, curr->value);
		curr = curr->next;
	}
#endif
	
	return i;
}

char* getReturnVars(MXML_DOCUMENT *doc){
	MXML_NODE *node;
	MXML_ITERATOR iter;
	char * options;
		
	mxml_iterator_setup( &iter, doc );
	
	node =  mxml_iterator_scan_node( &iter, "returnvars" );
	
	if ( node == NULL )
		return NULL;
	
	options = calloc (sizeof (char), 1024);
	
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

/**
 * This functions takes out all the options from the xml reply.
 * It fills a linked list with the content of each node as option.
 */
RESULTS* getOptions(MXML_DOCUMENT *doc){
	MXML_NODE *node;
	MXML_ITERATOR iter;
	
	RESULTS * curr, * head;
	head = NULL;

	mxml_iterator_setup( &iter, doc );
	
	while ( (node = mxml_iterator_scan_node( &iter, "option" )) != NULL){
		curr = (RESULTS *)malloc(sizeof(RESULTS));
		curr->val = mxml_node_clone_tree(node);
		curr->next = head;
		head = curr;		
		mxml_iterator_next( &iter );
	}   
	return head;
}

/**
 * This functions takes the Response function from the xml file
 */
MXML_NODE* getResponseFunction(MXML_DOCUMENT *doc){
	MXML_NODE *node;
	MXML_ITERATOR iter;
	
	mxml_iterator_setup( &iter, doc );
	
	node = mxml_node_clone_tree( 
				mxml_iterator_scan_node( &iter, "responsefunction" )
			);

	
	return node;		
}
