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
 * @since 11/12/2006
 */

package net.aircable.utils;

import java.io.IOException;
import java.util.Vector;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;

public class Uploader {
	
	public static Logger log = Logger.getLogger(Uploader.class);

	
	public static void main(String[] args) {		
		String pattern = "AIRcable";		

		if (args.length == 0){
			System.out.println(
					"Syntaxis:\nAIRcableFTP FOLDER\nWhere FOLDER [Name Pattern]" +
					"is the folder where AIRcable.bas and " +
					"config.txt are stored and the log will be stored");
			
			System.exit(0);
		}

		PropertyConfigurator.configure(java.lang.System.getenv("HOME")+"/.aircableftp");
		
		if (args.length == 2){
			pattern = args[1];
		}
		
		try {
			
			log.info("Scaning");

			Vector<Device> devices = Device.inquiry(pattern);
			
			log.info(String.format("FOUND %d targets%n", devices.size()));
					
			for (int i = 0 ; i < devices.size() ; i++){				
				log.info(String.format("Working on target %d of %d.%n", i , devices.size()));
				
				Device dev = devices.get(i);
				
				log.info(String.format("%s - %s.%n", dev.getAddr(), dev.getName()));
				
				log.info("Seding AIRcable.bas");
				
				boolean a = dev.sendBAS(args[0]);
								
				if (a)
					log.info("AIRcable.bas Sended Sucessfully");
				else {
					log.info("AIRcable.bas Sending Failed, skipping config.txt");
					dev.setState(Device.states.Failure);
					log.info(String.format("FAILED %s%n", dev.getName()));					
					break;
				}
				
				log.info("Sending config.txt");
			
				a = dev.sendCFG(args[0]);
				
				if (a)
					log.info("config.txt Sended Sucessfully");
				else{
					log.info("config.txt Sending Failed");
					log.info(String.format("FAILED %s%n", dev.getName()));
					dev.setState(Device.states.Failure);
					break;
				}
				
				dev.setState(Device.states.Done);
				log.info(String.format("DONE %s%n", dev.getAddr()));
			}				

			System.exit(0);
		} catch (IOException e) {
			log.error("exception happened - here's what I know: ", e);			
			System.exit(-1);
		}

	}
}
