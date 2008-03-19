#include "types.h"
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

#include <mxml.h>
#include <stdlib.h>

NODE * node_new(){
	NODE * out;
	
	out = (NODE*) malloc (sizeof(NODE));
	
	out->function = 0;
	out->lastReply = 0;
	out->nodeId = 0;
	out->socket = 0;
	out->value = 0;
	out->temperature=0.0f;
	out->type=0;
	out->tag=0;
	
	return out;
}

void node_destroy(NODE * node){
	if (!node)
		return;
	
	//if (node->function)
	//	free(node->function);
	
	if (node->tag)
			mxml_node_destroy(node->tag);
	
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
	menu_entry * out = (menu_entry*)malloc(sizeof(menu_entry));
	out->next=NULL;
	out->text=0;
	out->value=0;
	return out;
}

void menu_entry_destroy(menu_entry* node){
	if (!node)
		return;
	
	if (node->next)
		menu_entry_destroy(node->next);
	
	free(node);
}

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


/*RESULTS* results_new(){
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
}*/


