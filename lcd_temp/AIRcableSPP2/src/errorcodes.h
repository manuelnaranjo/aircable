#ifndef SPP_ERR_CODES
#define SPP_ERR_CODES

/*
 *  AIRcableSPP common error codes.
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

//no problems
#define OK					0
#define CONNECTION_CLOSE 	1

#define TAG_FOUND			2

//errors
//TODO: Extend errors list
#define ERROR				-1

//errors related to lcd<->nslu2 protocol
#define WRONG_REPLY			-100
#define FAILED_SEND_MENU	-101

#define NOT_ACCEPTED		-200

#define TAG_NOT_PRESENT		-300
#define TAG_MONITOR_EMPTY	-301


#endif
