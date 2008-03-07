/*
 *   Copyright 2008 Wireless Cables Inc. < aircable dot net >
 *   Copyright 2008 Naranjo Manuel Francisco < manuel at aircable dot net >
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 *   
 */
package net.aircable.uploader;

import java.io.IOException;
import java.util.Vector;

import javax.bluetooth.DeviceClass;
import javax.bluetooth.DiscoveryAgent;
import javax.bluetooth.DiscoveryListener;
import javax.bluetooth.LocalDevice;
import javax.bluetooth.RemoteDevice;
import javax.bluetooth.ServiceRecord;

public class Scanner {

	
	private static final Object inquiryCompletedEvent = new Object();
	
	public Scanner(){}
		
	public Vector<RemoteDevice> scan() {
		Vector<RemoteDevice> discovered = new Vector<RemoteDevice>();
		
		try {
			synchronized(inquiryCompletedEvent) {
				boolean started = LocalDevice.getLocalDevice().
					getDiscoveryAgent(). startInquiry(
						DiscoveryAgent.GIAC, new myDiscoveryListener
							(discovered)
						);
				if (started) {
					System.out.println("wait for device inquiry to " +
						"complete...");
					inquiryCompletedEvent.wait();
					System.out.println(discovered.size() +  " " +
						"device(s) found");
				}
			}
		} catch (Exception e) {
			System.err.println("Oops, I have to go, here's what " +
				"happened:");
			e.printStackTrace();
			System.exit(-1);
		}
		
		return discovered;
	}
	
	class myDiscoveryListener implements DiscoveryListener {
		Vector<RemoteDevice> discovered;
		
		public myDiscoveryListener(Vector<RemoteDevice> disc){
			discovered = disc;
		}

		public void deviceDiscovered(RemoteDevice btDevice, DeviceClass cod) {
            System.out.println("Device " + btDevice.getBluetoothAddress() + " found");
            discovered.addElement(btDevice);
            try {
                System.out.println("     name " + btDevice.getFriendlyName(true));
            } catch (IOException cantGetDeviceName) {
            }
        }

        public void inquiryCompleted(int discType) {
            System.out.println("Device Inquiry completed!");
            synchronized(inquiryCompletedEvent){
                inquiryCompletedEvent.notifyAll();
            }
        }

        public void serviceSearchCompleted(int transID, int respCode) {
        }

        public void servicesDiscovered(int transID, ServiceRecord[] servRecord) {
        }
		
	}
	
}
