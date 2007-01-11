/***************************************************************************
 *   Copyright (C) 2006 by Manuel Naranjo   *
 *   manuel@aircable.net   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Library General Public License as       *
 *   published by the Free Software Foundation; either version 2 of the    *
 *   License, or (at your option) any later version.                       *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU Library General Public     *
 *   License along with this program; if not, write to the                 *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 *																		   *
 *																		   *
 *   This class	is a C++ warper of a Bluetooth RFcomm Socket			   *
 ***************************************************************************/

#include "rfcomm.h"

#include <string>
#include <iostream>
#include <sys/param.h>
#include <sys/socket.h>
#include <sys/ioctl.h>

#include <bluetooth/bluetooth.h>
#include <bluetooth/rfcomm.h>
#include <bluetooth/hci.h>
#include <bluetooth/hci_lib.h>

RfComm::RfComm(void){
	rfcommSocket = -1;
	bt_addr = "00:00:00:00:00:00";
}

RfComm::RfComm(string addr){
	rfcommSocket = -1;
	bt_addr = addr;
}

RfComm::~RfComm(void){
	Close();
}

void RfComm::Close(void){        
//	if (rfcommSocket != -1)
//		close(rfcommSocket);

    bdaddr_t t_bdaddr;
    
    int dd, dev_id;
    struct hci_conn_info_req *cr;

    str2ba(bt_addr.c_str(), &t_bdaddr);    
    
    dev_id = hci_for_each_dev(HCI_UP, find_conn, (long) &t_bdaddr);
    
    if (dev_id < 0) {
	std::cerr << "Not Connected, nothing to do." << endl;
        return;
    }

    dd = hci_open_dev(dev_id);
    if (dd < 0) {
	std::cerr<< "Couldn't open the Bluetooth Adapter, Might it be working badly?"<<endl;
	return;
    }

    cr = (hci_conn_info_req*)malloc(sizeof(*cr) + sizeof(struct hci_conn_info));
    if (!cr) {
	std::cerr<<"Can't allocate memory"<<endl;
	std::cerr<<"I will not be able to close the connection"<<endl;
	std::cerr<<"Aborting!!!!"<<endl;
	exit(-1);
    }
			
    bacpy(&cr->bdaddr, &t_bdaddr);
    cr->type = ACL_LINK;
    
    if (ioctl(dd, HCIGETCONNINFO, (unsigned long) cr) < 0) {
	std::cerr<<"Get connection info failed";
	std::cerr<<"I will not be able to close the connection"<<endl;
	std::cerr<<"Aborting!!!!"<<endl;
	exit(-1);
    }
							
    if (hci_disconnect(dd, htobs(cr->conn_info->handle),
		    HCI_OE_USER_ENDED_CONNECTION, 10000) < 0){
	std::cerr<<"Get connection info failed";
	std::cerr<<"I will not be able to close the connection"<<endl;
	std::cerr<<"Aborting!!!!"<<endl;
	exit(-1);
    }

    free(cr);

    hci_close_dev(dd);

}

void RfComm::Open(void){
    bdaddr_t t_bdaddr;

    uint16_t handle;
    uint8_t role;
    unsigned int ptype;
    int dd, opt, dev_id;
    
    role = 0x01;
    ptype = HCI_DM1 | HCI_DM3 | HCI_DM5 | HCI_DH1 | HCI_DH3 | HCI_DH5;

    str2ba(bt_addr.c_str(), &t_bdaddr);
    
    dev_id = hci_get_route(&t_bdaddr);
    
    if (dev_id < 0) {
	std::cerr << "There is no Bluetooth Adapter found, please check there is a generic dongle connected." << endl;
        return;
    }
					    
    dd = hci_open_dev(dev_id);
    if (dd < 0) {
	std::cerr<< "Couldn't open the Bluetooth Adapter, Might it be working badly?"<<endl;
	return;
    }

										
    if (hci_create_connection(dd, &t_bdaddr, htobs(ptype),
	    htobs(0x0000), role, &handle, 25000) < 0)
	std::cerr<<"Couldn't open a connection to the device sorry."<<endl;
														    
    hci_close_dev(dd);
}

void RfComm::setAddress(string new_addr){
	Close();
	bt_addr = new_addr;
}

int RfComm::Write(string message){
	int result = -1;
	if (rfcommSocket==-1){
		std::cerr << "Not a valid socket, aborting"<<endl;
		return result;
	}

	result = send(rfcommSocket, (void *)message.c_str(), message.size(), 0);

	if (result < 0)
		std::cerr << "There was an error when trying to write"<<endl;	

	return result;
}

string RfComm::Read(void){
	char response[64];
	string out = "";
	if (recv(rfcommSocket, response, 64, 0) < 0) {
		std::cerr << "There was an error while trying to read"<<endl;
		return NULL;
  	}
	
	out+=response;
	return out;
}

int RfComm::getLinkQuality(uint8_t * lq){
	struct hci_conn_info_req *cr;
	bdaddr_t bdaddr;

	int dd;
	int dev_id;

	str2ba(bt_addr.c_str(), &bdaddr);
	
	dev_id = hci_for_each_dev(HCI_UP, find_conn, (long) &bdaddr);
	if (dev_id < 0) {
		std::cerr <<"Not connected, can't read Link Quality" << endl;
		return -1;
	}	

	dd = hci_open_dev(dev_id);
	if (dd < 0) {
		std::cerr << "HCI device open failed, are you sure there is a generic bluetooth dongle";
		return -1;
	}

	cr = (hci_conn_info_req*)malloc(sizeof(*cr) + sizeof(struct hci_conn_info));
	if (!cr) {
		std::cerr << "Can't allocate memory";
		return -1;
	}

	bacpy(&cr->bdaddr, &bdaddr);
	cr->type = ACL_LINK;
	if (ioctl(dd, HCIGETCONNINFO, (unsigned long) cr) < 0) {
		std::cerr << "Get connection info failed";
		return -1;
	}

	if (hci_read_link_quality(dd, htobs(cr->conn_info->handle), lq, 1000) < 0) {
		std::cerr << "HCI read_link_quality request failed";
		return -1;
	}

	close(dd);
	free(cr);
	return 0;
}

int RfComm::getRSSI(int8_t * rssi){
	struct hci_conn_info_req *cr;
	bdaddr_t bdaddr;	
	int dd, dev_id;
	int8_t temp;
	str2ba(bt_addr.c_str(), &bdaddr);

	dev_id = hci_for_each_dev(HCI_UP, find_conn, (long) &bdaddr);
	if (dev_id < 0) {
	    std::cerr << "Can't find any BT generic dongle, are you sure there is one connected." << endl;
	    return -1;
	}
	
	dd = hci_open_dev(dev_id);
	if (dd < 0) {
		std::cerr << "Couldn't open the device, maybe the BT generic dongle is not working well" << endl;
		return -1;
	}

	cr = (hci_conn_info_req*)malloc(sizeof(*cr) + sizeof(struct hci_conn_info));
	if (!cr) {
		std::cerr << "Can't allocate memory" << endl;
		return -1;
	}

	bacpy(&cr->bdaddr, &bdaddr);
	cr->type = ACL_LINK;
	if (ioctl(dd, HCIGETCONNINFO, (unsigned long) cr) < 0) {
		std::cerr << "Get connection info failed" << endl;
		return -1;
	}

	if (hci_read_rssi(dd, htobs(cr->conn_info->handle), &temp, 1000) < 0) {
		std::cerr << "Read RSSI failed, is there a connection?" << endl;
		return -1;
	}

	*rssi = temp;
	
	close(dd);
	free(cr);
	return 0;
}

int RfComm::getTransmitPowerLevel(int8_t * level, uint8_t * type){
	struct hci_conn_info_req *cr;
	bdaddr_t bdaddr;
	uint8_t temp;
	int dd, dev_id;
	
	str2ba(bt_addr.c_str(), &bdaddr);
	
	if (dev_id < 0) {
		dev_id = hci_for_each_dev(HCI_UP, find_conn, (long) &bdaddr);
		if (dev_id < 0) {
			std::cerr << "Not connected. Can't read Transmit Power Level." << endl;
			return -1;
		}
	}

	dd = hci_open_dev(dev_id);
	if (dd < 0) {
		std::cerr << "HCI device open failed" << endl;
		return -1;
	}

	cr = (hci_conn_info_req*)malloc(sizeof(*cr) + sizeof(struct hci_conn_info));
	if (!cr) {
		std::cerr << "Can't allocate memory" << endl;
		return -1;
	}

	bacpy(&cr->bdaddr, &bdaddr);
	cr->type = ACL_LINK;
	if (ioctl(dd, HCIGETCONNINFO, (unsigned long) cr) < 0) {
		std::cerr << "Get connection info failed" << endl;
		return -1;
	}

	if (hci_read_transmit_power_level(dd, htobs(cr->conn_info->handle), temp, level, 1000) < 0) {
		std::cerr << "HCI read transmit power level request failed" << endl;
		return -1;
	}

	*type =temp;

	close(dd);
	free(cr);
	
	return 0;
}

static int find_conn(int s, int dev_id, long arg)
{
	struct hci_conn_list_req *cl;
	struct hci_conn_info *ci;
	int i;

	if (!(cl = (hci_conn_list_req*)malloc(10 * sizeof(*ci) + sizeof(*cl)))) {
		std::cerr << "Can't allocate memory";
		exit(1);
	}
	cl->dev_id = dev_id;
	cl->conn_num = 10;
	ci = cl->conn_info;

	if (ioctl(s, HCIGETCONNLIST, (void *) cl)) {
		std::cerr <<"Can't get connection list";
		exit(1);
	}

	for (i = 0; i < cl->conn_num; i++, ci++)
		if (!bacmp((bdaddr_t *) arg, &ci->bdaddr))
			return 1;

	return 0;
}



