#ifndef XML_H_
#define XML_H_

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

#include <stdlib.h>
#include <stdio.h>

#include <mxml.h>
#include <mxml_file.h>
#include <mxml_defs.h>

#include <string.h>

MXML_DOCUMENT *mxml_buffer(const char* buf, int style );
int xmlmain(int argc, char *argv[]);

#define XML_DEBUG

#endif /*XML_H_*/
