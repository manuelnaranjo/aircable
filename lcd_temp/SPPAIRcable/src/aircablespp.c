/*
 *  AIRcableSPP, a little SPP server using BlueZ. Based in RfComm utility from 
 *  BlueZ, with some xml handling and file uploading to the web.
 *
 *  Copyright (C) 2007	Naranjo,manuel <manuel@aircable.net>
 *  Copyright (C) 2002-2007  Marcel Holtmann <marcel@holtmann.org> 
 *  					(BlueZ utils)
 *  Copyright (C) 2005-2006 Albert Huang <albert@csail.mit.edu>
 * 						(Wrote this incredible guide [1])
 *
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
 * [1] http://people.csail.mit.edu/albert/bluez-intro/index.html
 *
 */

#include "aircablespp.h"

 //
 //
 // NLUS2<->LCD Messages format
 // 	Temperature:
 //				!<VALUE>:<CALIBRATION>#<TYPE>
 // 
 //		Sensor Type <TYPE>:
 //				K: Thermocouple type K.
 //				I: Infrared Sensor.
 //
 //		LCD Menu:
 //				%<AMOUNT>	(amount of messages that will be sended from the 
 //										server)
 //				<ID><TEXT> 	(2 hex chars are assigned to index)
 //				&<ID>		(Received message, ready for next)
 //				$<ID>		(Last message received)
 //				@<ID>		(Accepted value, meassured temperature must be sent
 //										 after the ID)
 //				^C(char 03) (Close connection, the LCD wants to close the connection)
 //				
 //    				
 //
 //
 //


/* Delete local service */
int deregisterSPP() {
	if (!recHandle){
		fprintf(stderr, "Not registered, nothing to do\n");
		return ERROR;
	}
	
	uint32_t range = 0x0000ffff;
	sdp_list_t *attr;
	sdp_session_t *sess;
	sdp_record_t *rec;

	sess = sdp_connect(&interface, BDADDR_LOCAL, SDP_RETRY_IF_BUSY);
	if (!sess) {
		printf("No local SDP server!\n");
		return ERROR;
	}

	attr = sdp_list_append(0, &range);
	rec = sdp_service_attr_req(sess, recHandle, SDP_ATTR_REQ_RANGE, attr);
	sdp_list_free(attr, 0);

	if (!rec) {
		printf("Service Record not found.\n");
		sdp_close(sess);
		return ERROR;
	}

	if (sdp_device_record_unregister(sess, &interface, rec)) {
		printf("Failed to unregister service record: %s\n", strerror(errno));
		sdp_close(sess);
		return ERROR;
	}

	printf("Service Record deleted.\n");
	sdp_close(sess);	
	return OK;
}


int registerSPP(int channelN)
{
	sdp_list_t *svclass_id, *apseq, *proto[2], *profiles, *root, *aproto;
	uuid_t root_uuid, sp_uuid, l2cap, rfcomm;
	sdp_profile_desc_t profile;
	uint8_t u8 = channelN ? channelN : 1;
	sdp_record_t  *record;
	sdp_session_t *session;	
	sdp_data_t *channel;
	
	int ret = OK;
	
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

	bacpy(&interface, BDADDR_ANY);

	sdp_set_info_attr(record, "Serial Port", 0, "AIRcableSPP server");

	if (sdp_device_record_register(session, &interface, record, 0) < 0) {
		perror("Service Record registration failed\n");
		ret = ERROR;
		goto end;
	}

	printf("Serial Port service registered\n");
	
	recHandle = record->handle;

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

int getSelected(menu_entry * menu, menu_entry * reply, 
				float *val, float *cal, char * type){
	char *buf;	
	unsigned short int rep;
		
	buf = calloc(16, sizeof(char));
	if (!readline(SPPclient, buf, 16)){
		perror("Couldn't read option");
		return ERROR;
	}
	
	if (strcmp( buf, "\x03") == 0){
		printf("LCD closed connection\n");
		return CONNECTION_CLOSE;
	}
		
	if ( sscanf(buf, "@%02hX!%f:%f#%s", &rep, val, cal, type) != 4 ){
		perror("Wrong content");
		return ERROR;
	}					
	
	while (menu && menu->index != rep)
		menu = menu->next;
						
	if (menu == NULL ){
		fprintf(stderr, "Wrong Option %i\n" , rep);
		return ERROR;
	}
		
	printf("Selected: index:%02hX\ttext:%s\tvalue:%s\n", rep, menu->text, menu->value);
	
	reply = menu;
	
	return OK;
		
}

int mywrite(int socket, char * buf){
	int ret = 0;
	struct pollfd fds;
	
	fds.fd = socket;
	fds.events = POLLOUT;
	
	ret = poll(&fds, 1, -1); //wait forever, there's no chance poll will return = 0
	if (ret < 0){
		perror("Error while writting to RFcomm Socket (poll)");
		return ERROR;
	}
		
	ret = write(socket,buf,strlen(buf));
		
	if (ret < 0) {
		perror("Error while writting to RFcomm Socket (write)");
		return ERROR;
	}
	
#ifdef SPP_DEBUG
	fprintf(stdout, ">> %s\n", buf);
#endif

	return ret;
	
}

int sendMenu(menu_entry * menu, int length){
	char * buf, * rec;
	int j = 0;	
	
	if (!SPPclient) {
		fprintf(stderr,"Not connected, can't go on\n");
		return ERROR;
	}

	buf = calloc(1024, sizeof(char));
	rec = calloc(1024, sizeof(char));
		
	sprintf(buf, "%%%i\n\r", length);
	
	j = mywrite(SPPclient,buf);

	if (j < 0){
		fprintf(stderr, "failed to send amount of options\n");
		return ERROR;
	}
	
	//by now give time to the lcd to settle up
	while (menu){
		sprintf(buf,"%02hX%s\n\r", menu->index, menu->text);
		j = mywrite(SPPclient,buf);

		if ( j < 0 ){
			fprintf(stderr, "There has been an error while writting to the socket (while)\n");
			return ERROR;
		}
		
		j = readline(SPPclient,rec, 1024);
		if ( j < 0 ) {
			fprintf(stderr, "There has been a problem while waiting ACK reply (menu)\n");
			return ERROR;
		}			
		
		if (menu->next)
			sprintf(buf,"&%02hX", menu->index);
		else
			sprintf(buf,"$%02hX", menu->index);
		
		if ( strncmp(buf, rec,3) == 0){
			menu = menu->next;
			printf("LCD got menu option\n");
		}
		else {
			fprintf(stderr, "Wrong reply from the LCD\n");
			sleep(5);
		}
	}
	
	printf( "LCD got menu\n");
	return OK;
}

static int readline(int socket, char *out, int MAXLEN){
	struct pollfd fds;
	int ret, len=0;
	char c;	

	fds.fd = socket;
	fds.events = POLLIN;

	while(1) {
		ret = poll(&fds, 1, -1); //wait forever, there's no chance poll will return = 0
		if (ret < 0){
			perror("Error while reading from Rfcomm Socket (poll)");
			return ERROR;
		}
		
		ret = read(socket, &c, 1);
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
				
		if (c == '\n' || c == '\x03')
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


static int calcTemp(int val, int calib, char type, float *realValue){
	switch (type){
		case 'K':
			*realValue=(125/2566.4)*(val+calib);
			return OK;
		case 'I':
			*realValue=val/10;
			return OK;
		default:
			fprintf(stderr,"%c is not a valid type\n", type);
			return ERROR;
	}
}

static int parseTemp(char * buf, float * rvalue){
	float value, calib;
	char type;
	
	//Message format: !<VAL>:<CAL>#<TYPE>
		
	if ( sscanf(buf, "!%f:%f#%1c", &value, &calib, &type) != 3 ){
		fprintf(stderr, "%s Doesn't match pattern\n", buf);
		return ERROR;
	}
	
	return calcTemp(value, calib, type, rvalue);
}

static MXML_DOCUMENT * initConnection(){
	int  bytes_read = 0;
	int counter = 0;
	float val;
	char *buf;
	MXML_DOCUMENT * doc;
	
	buf=calloc(1024, sizeof(char));
	
	while (bytes_read <= 0){
		bytes_read = readline(SPPclient, buf, 1024);

		if (bytes_read <= 0 && counter == 3){
			fprintf(stderr, 
				"Connection timeout, device is not sending us the current temp\n");
			return NULL;
		}
		usleep(100*1000);
		counter++;
	}
	
	if ( parseTemp(buf, &val) != OK )
		return NULL;
	
	doc = sendInitial("1234-1234-1234-1234", val );
	         
	return doc;
}

//static Options *

static int listenSPP(int channel){
	struct sockaddr_rc loc_addr = { 0 }, rem_addr = { 0 };    
    int s, client;
    char addr[17] = { 0 };
    int unsigned opt = sizeof(rem_addr);
    struct timeval t;
	int result; 
	int unsigned ol = sizeof(struct timeval);

    // allocate socket
    s = socket(AF_BLUETOOTH, SOCK_STREAM, BTPROTO_RFCOMM);
    if (s < 0) {
		perror("Can't create RFCOMM socket");
		return ERROR;
	}

    // bind socket to port 1 of the first available 
    // local bluetooth adapter
    loc_addr.rc_family = AF_BLUETOOTH;
    loc_addr.rc_bdaddr = *BDADDR_ANY;
    loc_addr.rc_channel = (uint8_t) (channel>0?channel:1);
    if (bind(s, (struct sockaddr *)&loc_addr, sizeof(loc_addr)) < 0) {
		perror("Can't bind RFCOMM socket");
		close(s);
		return ERROR;
	}    

    // put socket into listening mode
    listen(s, 1);
    
    registerSPP(channel);
    	
    // accept one connection
    client = accept(s, (struct sockaddr *)&rem_addr, &opt);

    ba2str( &rem_addr.rc_bdaddr, addr );
    bacpy( &slave, &rem_addr.rc_bdaddr);
    printf("accepted connection from %s\n", addr);
        
    result = getsockopt(client, SOL_SOCKET, SO_RCVTIMEO, &t, &ol); 
	
	if (result < 0)
		perror("timeout");

	t.tv_sec = TIMEOUT;
	t.tv_usec = 0;
	result = setsockopt(client, SOL_SOCKET, SO_RCVTIMEO,  &t, ol);	
	if (result < 0)
		perror("timeout");

	result = getsockopt(client, SOL_SOCKET, SO_RCVTIMEO, &t, &ol); 
	if (result < 0)
		perror("timeout");
	        
	SPPclient = client;
	SPPsocket = s;
       
    return OK;
}

static void disconnect(){
	struct hci_conn_info_req *cr;
	int dd;
	
	if (SPPclient < 1 || SPPsocket < 1){
		return;
	}
	// close connection
	if (SPPclient)
    	close(SPPclient);
    	
    if (SPPsocket)
    	close(SPPsocket);
	
	dd = hci_open_dev(hci_get_route(NULL));
	if (dd < 0) {
		perror("HCI device open failed");
		return;
	}

	cr = malloc(sizeof(*cr) + sizeof(struct hci_conn_info));
	if (!cr) {
		perror("Can't allocate memory to disconnect");
		return;
	}

	bacpy(&cr->bdaddr, &slave);
	cr->type = ACL_LINK;
	if (ioctl(dd, HCIGETCONNINFO, (unsigned long) cr) < 0) {
		perror("Get connection info failed");
		return;
	}

	if (hci_disconnect(dd, htobs(cr->conn_info->handle),
				HCI_OE_USER_ENDED_CONNECTION, 10000) < 0)
		perror("Disconnect failed");

	if (cr)
		free(cr);

	if (dd)
		hci_close_dev(dd);
}

static int workMenu(MXML_DOCUMENT* doc, menu_entry *reply, float * temp){		
	
	int t;	
	menu_entry *root, menu;
	char type;
	float val, cal;
	int ret;
	
	
	t = parseEntries(getOptions(doc), &menu);
	root = &menu;
	if ( sendMenu(&menu, t) != 0){
		perror("Failed to send menu");
		return ERROR;
	}
		
	ret	= getSelected(root, &menu, &val, &cal, &type);
	
	if ( ret != OK )
		return ret; 
	
	
	ret = calcTemp(val, cal, type, temp);
	if (ret != OK)
		return ret;
	
	reply->index = menu.index;
	reply->next  = NULL;
	reply->text  = menu.text;
	reply->value = menu.value;	
	
	return OK;
}

int testRun(){
	MXML_DOCUMENT* doc;
	MXML_NODE* function;
	menu_entry reply;
	float temp;
	int ret;
	
	doc = initConnection();
	
	ret = OK;
	
	while (ret == OK && doc){
		ret = workMenu(doc, &reply, &temp);
		if (ret != OK)
			break;
	
		function = (getResponseFunction(doc));
			
		if ( ! function )
			break;
			
		doc = sendRequest( 	function->data, 
			"1234-1234-1234-1234", 
			reply.value,
			temp, doc);						
	}
		
	return OK;
}

int normalRun(int channel){
	MXML_DOCUMENT* doc;
	MXML_NODE* function;
	menu_entry reply;
	float temp;
	int ret;
		
	ret = listenSPP(channel);
	if (ret != OK){
		return ret;
	}
		
	doc = initConnection();
	
	ret = OK;
	
	while (ret == OK && doc){
		ret = workMenu(doc, &reply, &temp);
		if (ret != OK)
			break;
	
		function = (getResponseFunction(doc));
			
		if ( ! function )
			break;
			
		doc = sendRequest( 	function->data, 
			"1234-1234-1234-1234", 
			reply.value,
			temp, doc);						
	}
		
	disconnect();
	deregisterSPP();
		
	return OK;
}


int main(int argc, char *argv[]) 
{

	int channel = 1;
	argc--;
	argv++;
	
	while (argc){
		if ( strcmp(argv[0], "--test") == 0 ){
			dup2((int)stdin, (int)stdout);
			SPPclient=(int)stdin;
			SPPclient=1;
			return testRun();
			
		}
		else if(strcmp(argv[0], "--channel") == 0){
			if (argc == 1){
				fprintf(stderr,"Missing channel\n");
				return ERROR;
			}
			
			channel = atoi(argv[1]);
			if ( channel < 1 ){
				fprintf(stderr, "Wrong Channel\n");
				return ERROR;
			}
			
			argv++;
			argc--;	
			
		} else if(strcmp(argv[0], "--help") == 0){
			fprintf(stdout, "Usage:\n");
			fprintf(stdout, "\t--test\t\t\trun test mode\n");
			fprintf(stdout, "\t--channel <Number>\tselect channel\n");
			fprintf(stdout, "\t--help\t\t\tthis menu\n");
			return OK;
			
		} else {
			fprintf(stdout, "Wrong option\n");
			return ERROR;
		}
		
		argv++;
		argc--;
	}
	
	fprintf(stdout, "Using channel: %i\n", channel);
	return normalRun(channel);
}

