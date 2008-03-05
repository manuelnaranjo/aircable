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

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Vector;

public class Device {
	private String name, addr, timeLastAction;
	
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
	
	private states state;
	
	private Device(){}
	
	public Device(String addr, String name, states state){
		this.addr = addr;
		this.name = name;
		this.state = state;
		
		devices.put(addr, this);
	}
	
	public states getState() {
		return state;
	}

	public void setState(states state) {
		this.state = state;
	}
		
	public static Device getDevice(String s){
		int i = 0;
		Device out = new Device();
		while (s.charAt(i)==' ' || s.charAt(i)=='\t')
			i++;
		
		out.name = "";
		out.addr = "";
		
		while (s.charAt(i)!=' ' && s.charAt(i)!='\t')
			out.addr += s.charAt(i++);
		
		while (s.charAt(i)==' ')
			i++;
		
		while (i < s.length())					
			out.name+= s.charAt(i++);
		
		out.name = out.name.trim();
		
		return out;
	}

	public String getAddr() {
		return addr;
	}

	public String getName() {
		return name;
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
		Process obexFTP = Runtime.getRuntime().exec("obexftp -b " + addr +" -B 4 -p "+ path);
		log.debug("Launched obexftp -b " + addr +" -B 4 -p "+ path);					
		
		BufferedReader stdErrObex = new BufferedReader(new InputStreamReader(
				obexFTP.getErrorStream()));

		boolean a = false;
		String s;
		while ((s=stdErrObex.readLine())!=null){
			log.debug(s);
			if (s.indexOf(path)>-1 && s.indexOf("done")>s.indexOf(path))
				a = true;						
		}
		
		
		return a;

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
		
		// run the hcitool to start the inquires
		
		log.debug("Starting Inquiry...");

		Process hci = Runtime.getRuntime().exec("hcitool scan --flush");

		BufferedReader stdInput = new BufferedReader(new InputStreamReader(
				hci.getInputStream()));

		String s;
		
		// read the output from the command
		
		while ((s = stdInput.readLine()) != null) {
			log.debug(s);
			if (s.indexOf(pattern)!=-1){
				Device dev = getDevice(s);
				if (!devices.containsKey(dev.addr)){
					dev.state = states.Discovered;
					devices.put(dev.addr, dev);
					out.add(dev);
				}				
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
