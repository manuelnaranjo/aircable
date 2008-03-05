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
 * @since 09/02/2007
 * 
 */
package net.aircable.utils;

import static net.aircable.utils.Uploader.log;

import java.io.IOException;
import java.util.Vector;

import javax.swing.SwingUtilities;

public class FTPWorker extends Thread {
	
	private enum Worker {
		message,
		updateStatusBoard,
		start,
		stop,
		stopForced
		;
	}
	
	private enum Work {
		inquiry,
		sendBASIC,
		sendConfig,
		stopForced,
		stop;	
	}
	
	private Work work;	

	private String path, filter;
	
	private int Index;
	
	private Vector<Device> devices;
	private Device dev;
	
	public FTPWorker(String path, String filter){
		this.path = path;
		this.filter = filter;
		work = Work.inquiry;
	}
	
	private class worker implements Runnable {
		String arg;
		Worker work;
				
		public worker (Worker wor,String ar){		
			arg = ar;
			work = wor;
		}
		
		public worker (Worker wor){
			work = wor;
		}
		
		public void run() {
			switch (work){
				case message:
					FTPUploader.getForm().setStatusMessage(arg);
					break;
				case updateStatusBoard:
					FTPUploader.getForm().updateStatusTable();
					break;
				case start:
					FTPUploader.getForm().startProgressBar();
					break;
				case stopForced:
					FTPUploader.getForm().startEnabled();
					FTPUploader.getForm().setStatusMessage("");
					FTPUploader.getForm().stopProgressBar();
					break;
				case stop:
					FTPUploader.getForm().stopProgressBar();
					FTPUploader.getForm().triggerAlarm();
					break;	
			}
		}
		
	}
	
	public void Stop(){		
		if (work == Work.stop)
			SwingUtilities.invokeLater(new worker(Worker.stopForced));
		work = Work.stopForced;
	}
	
	public void logInfo(String arg){
		log.info(arg);
		
		SwingUtilities.invokeLater(new worker(Worker.message,arg));
	}
	
	public void run(){
		try {			
			while (work != Work.stopForced){		
				switch (work) {
					case inquiry: {				
							logInfo("Scaning");
							
							SwingUtilities.invokeLater(new worker(Worker.start));
		
							devices = Device.inquiry(filter);
							
							logInfo(String.format("FOUND %d targets", devices.size()));
							
							SwingUtilities.invokeLater(new worker(Worker.updateStatusBoard));
							
							if (work != Work.stopForced)
								if (devices.size() != 0)										
									work = Work.sendBASIC;
								else
									work = Work.stop;
																					
							Index = 0;					
						} 
						break;
					case sendBASIC: {				
						logInfo(String.format("Working on target %d of %d.", Index +1 , devices.size()));
						
						dev = devices.get(Index);
						
						logInfo(String.format("%s - %s", dev.getAddr(), dev.getName()));
						
						logInfo("Sending AIRcable.bas");
						
						dev.setState(Device.states.SendingBAS);
						
						SwingUtilities.invokeLater(new worker(Worker.updateStatusBoard));
						
						boolean a = dev.sendBAS(path);
						
						SwingUtilities.invokeLater(new worker(Worker.updateStatusBoard));
										
						if (a) {
							logInfo("AIRcable.bas Sended Sucessfully");							
						}
						else {
							logInfo("AIRcable.bas Sending Failed, skipping config.txt");				
							logInfo(String.format("FAILED %s", dev.getAddr()));
							updateIndex();						
							break;
						}
						
						if (work != Work.stopForced)
							work = Work.sendConfig;
						break;
					}
					case sendConfig: {
						logInfo("Sending config.txt");
						
						SwingUtilities.invokeLater(new worker(Worker.updateStatusBoard));
						
						Boolean a = dev.sendCFG(path);
						
						SwingUtilities.invokeLater(new worker(Worker.updateStatusBoard));
						
						if (a)
							logInfo("config.txt Sended Sucessfully");
						else{
							logInfo("config.txt Sending Failed");
							logInfo(String.format("FAILED %s", dev.getAddr()));
							updateIndex();
							break;
						}				
						
						if (work!= Work.stopForced)
							work = Work.sendBASIC;
						
						updateIndex();
						SwingUtilities.invokeLater(new worker(Worker.updateStatusBoard));
						logInfo(String.format("DONE %s", dev.getAddr()));
						
						break;
					}
					
					case stop: {
						logInfo("No more devices on que, going to sleep for 2 minutes");			
						SwingUtilities.invokeLater(new worker(Worker.stop));
						return;
					}
				}
				try {
					Thread.sleep(100);
				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}			
			
			SwingUtilities.invokeLater(new worker(Worker.stopForced,""));
			
			return;
		} catch (IOException e) {
			log.error("exception happened - here's what I know: ", e);			
			System.exit(-1);
		}
	}
	
	private void updateIndex(){
		Index++;
		
		if (Index == devices.size())			
			work = Work.stop;
		
		SwingUtilities.invokeLater(new worker(Worker.updateStatusBoard));
	}
}
