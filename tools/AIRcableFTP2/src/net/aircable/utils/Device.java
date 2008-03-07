//
//	Copyright 2007 Wireless Cables Inc.
//
//	Licensed under the Apache License, Version 2.0 (the "License"); 
//	you may not use this file except in compliance with the License. 
//	You may obtain a copy of the License at 
//			http://www.apache.org/licenses/LICENSE-2.0 
//
//	Unless required by applicable law or agreed to in writing, 
//	software distributed under the License is distributed on an
//	"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
//	either express or implied. See the License for the specific 
//	language governing permissions and limitations under the License.
//


/**
 * @autor Manuel Naranjo <manuel@aircable.net>
 * @since 08/02/2007
 * 
 */
package net.aircable.utils;

import static net.aircable.utils.Uploader.log;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Vector;

import javax.bluetooth.RemoteDevice;
import javax.microedition.io.Connector;
import javax.obex.ClientSession;
import javax.obex.HeaderSet;
import javax.obex.Operation;
import javax.obex.ResponseCodes;

public class Device {
	private RemoteDevice dev;
	private String timeLastAction;
	
	public static String urlFormat = "btgoep://%s:%d;authenticate=false;encrypt=false;master=false";
	
	public static int channel = 3;
	
	public static HashMap<String,Device> devices = new HashMap<String,Device>();

	public enum states {
		Discovered("Just Discovered"),
		OnQue("On Que"),
		SendingBAS("Sending AIRcable.bas"),
		SendingCFG("Sending config.txt"),
		Done("Done"),
		Failure("Failure");
		
		private String desc;
		
		states(String des){
			desc = des;
		}
		
		public String toString() {
			return desc;
		}
	}
	

	class DeviceR extends RemoteDevice{
		String addr, name, lastTimeAction;
		Device.states state;

		public DeviceR(String addr, String name){
			super(addr);
			this.name = name;
		}

		public String getFriendlyName(boolean alwaysAsk) throws IOException{
			return name;
		}

	}

	
	private states state;
	
	private Device(){}
	
	public Device(String addr, String name, states state){
		this.dev = new DeviceR(addr, name);
		this.state = state;
		devices.put(dev.getBluetoothAddress(), this);
	}
	
	public Device(RemoteDevice dev, states state){
		this.dev = dev;
		this.state = state;
		
		devices.put(dev.getBluetoothAddress(), this);
	}
	
	public states getState() {
		return state;
	}

	public void setState(states state) {
		this.state = state;
	}

	public String getAddr() {
		return dev.getBluetoothAddress();
	}

	public String getName() {
		try {
			return dev.getFriendlyName(false);
		} catch (IOException e) {
			e.printStackTrace();
			return "IOException when requesting name";
		}
	}
	
	public boolean sendBAS(String path) throws IOException {		
		boolean a = sendFile(path+"/AIRcable.bas");
		if (a) state = states.SendingCFG;
		else state = states.Failure;		
		return a;
	}
	
	public boolean sendCFG(String path) throws IOException {
		boolean a = sendFile(path+"/config.txt");
		if (a) state = states.Done;
		else state = states.Failure;		
		return a;
	}
	
	private boolean sendFile(String path) throws IOException{
		String url;
		url = String.format(urlFormat, dev.getBluetoothAddress(), channel).toString();
		System.out.println(url);
        ClientSession clientSession = (ClientSession) Connector.open( url );
        
        HeaderSet hs = clientSession.createHeaderSet();
        
        byte[] FBUiid = {(byte)0xF9,(byte)0xEC,(byte)0x7B,(byte)0xC4,(byte)0x95,(byte)0x3C,(byte)0x11,(byte)0xD2,
        	    (byte)0x98,(byte)0x4E,(byte)0x52,(byte)0x54,(byte)0x00,(byte)0xDC,(byte)0x9E,(byte)0x09}; 
            
        hs.setHeader(HeaderSet.TARGET, FBUiid);
        HeaderSet hsConnectReply = clientSession.connect(hs);
       
        if (hsConnectReply.getResponseCode() != ResponseCodes.OBEX_HTTP_OK) {
            System.out.println("Failed to connect");
            return false;
        }
        
        //move to /
        hs = clientSession.createHeaderSet();
        hs.setHeader(HeaderSet.NAME, "/" );
        clientSession.setPath(hs, false, false);
        
        if (hsConnectReply.getResponseCode() != ResponseCodes.OBEX_HTTP_OK) {
            System.out.println("Failed to set path");
            return false;
        }
        
        
        //tell which file we are going to push
        File sendFile = new File (path);
        hs = clientSession.createHeaderSet();
        hs.setHeader(HeaderSet.NAME, sendFile.getName());

        Operation op = clientSession.put(hs);
        
        OutputStream os = op.openOutputStream();
        InputStream is = new FileInputStream (sendFile);
        byte[] b = new byte[400];
        int r;
        while ((r = is.read(b)) > 0) {
            os.write(b, 0, r);
        }
        is.close();
        os.close();
        op.getResponseCode();
        
        if (op.getResponseCode() != ResponseCodes.OBEX_HTTP_OK) {
        	op.close();
            System.out.println("Failed to connect");
            return false;
        }
        
        op.close();

        clientSession.disconnect(null);

        clientSession.close();

		return true;

	}
	
	public static Vector<Device> inquiry(String pattern) throws IOException{
		Iterator<String> keys = devices.keySet().iterator();
		Vector<Device> out = new Vector<Device>();
		while (keys.hasNext()){
			Device dev = devices.get(keys.next());
			if (dev.state==states.Discovered || dev.state == states.Failure){
				dev.state = states.OnQue;
				out.add(dev);
			}
		}	
		
		// now we use bluecove :D		
		log.debug("Starting Inquiry...");

		Vector<RemoteDevice> found =  new net.aircable.uploader.Scanner().scan();
		
		for (RemoteDevice device : found) {
			String addr = device.getBluetoothAddress();
			if (!devices.containsKey(addr) && device.
					getFriendlyName(true).startsWith(pattern)){
				Device dev = new Device(device, states.Discovered);
				out.add(dev);
			}
		}
		 		
		return out;
	}

	public String getTimeLastAction() {
		return timeLastAction;
	}

	public void setTimeLastAction(String timeLastAction) {
		this.timeLastAction = timeLastAction;
	}
}
