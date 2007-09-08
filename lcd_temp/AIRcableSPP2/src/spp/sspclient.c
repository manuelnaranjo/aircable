/*
 *  SPPclient, little spp client.
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

#include "sppclient.h"

static int channelNumber;

/** Constants	**/
//times
#define TIMEOUT 			120

#define SPP_DEBUG

int sppRegister(sppSocket * socket){	
	sdp_list_t *svclass_id, *apseq, *proto[2], *profiles, *root, *aproto;
	uuid_t root_uuid, sp_uuid, l2cap, rfcomm;
	sdp_profile_desc_t profile;
	uint8_t u8;
	sdp_record_t  *record;
	sdp_session_t *session;	
	sdp_data_t *channel;
	
	if (socket->channel<1){
		fprintf(stderr, "Wrong channel %i\n", socket->channel);
		return ERROR;
	}
	
	u8 = socket->channel;
	
	int ret;
	
	session = sdp_connect(BDADDR_ANY, BDADDR_LOCAL, 0);
	if (!session) {
		perror("Failed to connect to the local SDP server");
		return ERROR;
	}

	record = sdp_record_alloc();
	if (!record) {
		perror("Failed to allocate service record");
		sdp_close(session);
		return ERROR;
	}

	sdp_uuid16_create(&root_uuid, PUBLIC_BROWSE_GROUP);
	root = sdp_list_append(0, &root_uuid);
	sdp_set_browse_groups(record, root);
	sdp_list_free(root, 0);

	sdp_uuid16_create(&sp_uuid, SERIAL_PORT_SVCLASS_ID);
	svclass_id = sdp_list_append(0, &sp_uuid);
	sdp_set_service_classes(record, svclass_id);
	sdp_list_free(svclass_id, 0);

	sdp_uuid16_create(&profile.uuid, SERIAL_PORT_PROFILE_ID);
	profile.version = 0x0100;
	profiles = sdp_list_append(0, &profile);
	sdp_set_profile_descs(record, profiles);
	sdp_list_free(profiles, 0);

	sdp_uuid16_create(&l2cap, L2CAP_UUID);
	proto[0] = sdp_list_append(0, &l2cap);
	apseq = sdp_list_append(0, proto[0]);

	sdp_uuid16_create(&rfcomm, RFCOMM_UUID);
	proto[1] = sdp_list_append(0, &rfcomm);
	channel = sdp_data_alloc(SDP_UINT8, &u8);
	proto[1] = sdp_list_append(proto[1], channel);
	apseq = sdp_list_append(apseq, proto[1]);

	aproto = sdp_list_append(0, apseq);
	sdp_set_access_protos(record, aproto);

	bacpy(&socket->interface, BDADDR_ANY);

	sdp_set_info_attr(record, "Serial Port", 0, "AIRcableSPP server");

	if (sdp_device_record_register(session, &socket->interface, record, 0) < 0) {
		perror("Service Record registration failed\n");
		ret = ERROR;
		goto end;
	}

	printf("Serial Port service registered\n");
	
	socket->recHandle = record->handle;
	
	ret = OK;
	channelNumber = u8;

end:
	sdp_data_free(channel);
	sdp_list_free(proto[0], 0);
	sdp_list_free(proto[1], 0);
	sdp_list_free(apseq, 0);
	sdp_list_free(aproto, 0);
	sdp_close(session);
	sdp_record_free(record);

	return ret;

}

int sppUnregister(sppSocket * socket){
	if (!socket->recHandle){
		fprintf(stderr, "Not registered, nothing to do\n");
		return ERROR;
	}
	
	uint32_t range = 0x0000ffff;
	sdp_list_t *attr;
	sdp_session_t *sess;
	sdp_record_t *rec;

	sess = sdp_connect(&socket->interface, BDADDR_LOCAL, SDP_RETRY_IF_BUSY);
	if (!sess) {
		printf("No local SDP server!\n");
		return ERROR;
	}

	attr = sdp_list_append(0, &range);
	rec = sdp_service_attr_req(sess, socket->recHandle, SDP_ATTR_REQ_RANGE, attr);
	sdp_list_free(attr, 0);

	if (!rec) {
		printf("Service Record not found.\n");
		sdp_close(sess);
		return ERROR;
	}

	if (sdp_device_record_unregister(sess, &socket->interface, rec)) {
		printf("Failed to unregister service record: %s\n", strerror(errno));
		sdp_close(sess);
		return ERROR;
	}

	printf("Service Record deleted.\n");	
	sdp_close(sess);	
	return OK;
}

int sppListen(sppSocket * Socket){
	// Mayus needd for Socket to avoid conflicts with function socket
	struct sockaddr_rc loc_addr = { 0 };
	
	if (Socket->channel < 1){
		fprintf(stderr, "Channel Number can't be 0 or negative\n");
		fprintf(stderr, "You need to call sppRegister() first\n");
		return ERROR;
	}
		
	
    // allocate socket
	Socket->SPPsocket = socket(AF_BLUETOOTH, SOCK_STREAM, BTPROTO_RFCOMM);
    if (Socket->SPPsocket < 0) {
		perror("Can't create RFCOMM socket");
		Socket->SPPsocket = 0;
		return ERROR;
	}

    // bind socket to port 1 of the first available 
    // local bluetooth adapter
    loc_addr.rc_family = AF_BLUETOOTH;
    loc_addr.rc_bdaddr = *BDADDR_ANY;
    loc_addr.rc_channel = (uint8_t) (channelNumber);
    if (bind(Socket->SPPsocket, (struct sockaddr *)&loc_addr, sizeof(loc_addr)) < 0) {
		perror("Can't bind RFCOMM socket");
		close(Socket->SPPsocket);
		Socket->SPPsocket = 0;
		return ERROR;
	}    

    // put socket into listening mode
    listen(Socket->SPPsocket, 1);
    
    printf("Listening in channel %i\n", Socket->channel);
    
    return OK;
}
    
int sppWaitConnection(sppSocket * socket){
	struct sockaddr_rc peer_addr = { 0 };
    char addr[17] = { 0 };
    int unsigned opt = sizeof(peer_addr);
    struct timeval t;
	int result; 
	int unsigned ol = sizeof(struct timeval);
	
	printf("Waiting for connection in Channel: %i\n", socket->channel);
    
	if (!socket->SPPsocket){
		fprintf(stderr, "You need to call sspListen first\n");
		return ERROR;
	}
	
    // accept one connection
    socket->SPPclient = accept(socket->SPPsocket, (struct sockaddr *)&peer_addr, &opt);

    ba2str( &peer_addr.rc_bdaddr, addr );
    bacpy( &socket->SPPpeer, &peer_addr.rc_bdaddr);
    printf("accepted connection from %s\n", addr);
        
    result = getsockopt(socket->SPPclient, SOL_SOCKET, SO_RCVTIMEO, &t, &ol); 
	
	if (result < 0){
		perror("Couldn't set timeout");
		return OK;
	}

	t.tv_sec = TIMEOUT;
	t.tv_usec = 0;
	result = setsockopt(socket->SPPclient, SOL_SOCKET, SO_RCVTIMEO,  &t, ol);	
	if (result < 0){
		perror("Couldn't set timeout");
		return OK;
	}

	result = getsockopt(socket->SPPclient, SOL_SOCKET, SO_RCVTIMEO, &t, &ol); 
	if (result < 0)
		perror("Couldn't set timeout");
	
      
    return OK;
}

int sppDisconnect(sppSocket * socket){
	struct hci_conn_info_req *cr;
	int dd, hcidev;
	int ret = OK;
	
	if (socket->SPPclient < 1 && socket->SPPsocket < 1){
		perror("Not Connected, can't disconnect\n");
		return ERROR;
	}
	// close connection
	if (socket->SPPsocket)
    	close(socket->SPPsocket);
	
	printf("Closed socket\n");
	   	
    if (socket->SPPclient)
    	close(socket->SPPclient);
    
    printf("Closed client\n");
    
    socket->SPPclient = 0;
    socket->SPPsocket = 0;
	
    hcidev = hci_get_route(NULL);
    
    if (hcidev < 0){
    	perror("Couldn't route to hci dev, can't close ACL link\n");
    	return ERROR;
    }
    
	dd = hci_open_dev(hcidev);
	if (dd < 0) {
		perror("HCI device open failed");
		return ERROR;
	}

	cr = malloc(sizeof(*cr) + sizeof(struct hci_conn_info));
	if (!cr) {
		perror("Can't allocate memory to disconnect");
		return ERROR;
	}

	bacpy(&cr->bdaddr, &socket->SPPpeer);
	cr->type = ACL_LINK;
	if (ioctl(dd, HCIGETCONNINFO, (unsigned long) cr) < 0) {
		perror("Get connection info failed");
		return ERROR;
	}

	if (hci_disconnect(dd, htobs(cr->conn_info->handle),
				HCI_OE_USER_ENDED_CONNECTION, 10000) < 0){
		perror("Disconnect failed");
		ret = ERROR;
	}
	
	printf("Closed hci connection\n");

	if (cr)
		free(cr);

	if (dd)
		hci_close_dev(dd);
	
	return ret;
}


int sppReadLine(const sppSocket * socket, char * out, int MAXLEN){
	struct pollfd fds;
	int ret, len=0;
	char c;	

	fds.fd = socket->SPPclient;
	fds.events = POLLIN;

	while(1) {
		ret = poll(&fds, 1, -1); //wait forever, there's no chance poll will return = 0
		if (ret < 0){
			perror("Error while reading from Rfcomm Socket (poll)");
			return ERROR;
		}
			
		ret = read(socket->SPPclient, &c, 1);
		if ( ret < 0 ) {
			perror("Error while reading from Rfcomm Socket (read)");
			return ERROR;
		}
			
		*out++=c;
		len++;
				
		#ifdef SPP_DEBUG
			if ( len > 0 && len % 70 ==0 )
				fprintf(stdout, "\n<< ");
			else if (len == 1)
				fprintf(stdout, "<< ");
				
			if ( isprint( c ) && c!='\n' && c!='\r')
				fprintf(stdout, "%c", c);
			else if (c != '\n')
				fprintf(stdout, "\\x%02X", c);
		#endif
						
		if (c == '\n' || c == '\x03' || c == '\r')
			break;
					
		if (len==MAXLEN -1 ){
			break;
		}			
	} 

	#ifdef SPP_DEBUG
		fprintf(stdout, "\n");
	#endif

		
	*out++=0; //null ending string.
	    
	return len;
	
}

int sppWriteLine(const sppSocket * socket, const char * buf){
	int ret = 0, len;
	struct pollfd fds;
	char * out = NULL;
	
	if (!socket->SPPclient){
			fprintf(stderr, "SPP socket is not opened, can't write\n");
			return ERROR;
	}
	len = strlen(buf);
	out = calloc(len+5, sizeof(char));
	
	if (!out) {
		fprintf(stderr, "Couldn't allocate buffer\n");
		return ERROR;
	}
		
		
	fds.fd = socket->SPPclient;
	fds.events = POLLOUT;
		
	ret = poll(&fds, 1, -1); //wait forever, there's no chance poll will return = 0
	if (ret < 0){
		perror("Error while writting to RFcomm Socket (poll)");
		free(out);
		return ERROR;
	}
	
	sprintf(out, "%s\n", buf);
	ret = write(socket->SPPclient,out,strlen(out));
			
	if (ret < 0) {
		perror("Error while writting to RFcomm Socket (write)");
		free(out);
		return ERROR;
	}
		
	#ifdef SPP_DEBUG
		fprintf(stdout, ">> %s\n", buf);
	#endif
		
	free(out);
	return ret;
}

int sppmain(int channel) {
	sppSocket socket;
	socket.channel=channel;
	int r = sppRegister(&socket);
	if (r != OK)
		return -1;
	
	sppListen(&socket);
	sppWaitConnection(&socket);
	
	char * line;
	line = calloc(1024, sizeof(char));
	
	sppReadLine(&socket, line, 1024);
	sppWriteLine(&socket, line);
	
	free(line);
	sppUnregister(&socket);
	
	//sdp_cleanup();
	return 0;
}
