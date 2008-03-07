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
 */
package net.aircable.utils;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Properties;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JPanel;
import javax.swing.JProgressBar;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.JTextField;
import javax.swing.SwingUtilities;
import javax.swing.Timer;

import org.apache.log4j.PropertyConfigurator;
import org.jdesktop.swingx.JXStatusBar;

/**
 *
 * @autor Manuel Naranjo <naranjo.manuel@gmail.com>
 * @since 08/02/2007
 *
 */
public class FTPUploader {
	
	private final class Start implements java.awt.event.ActionListener {
		public void actionPerformed(java.awt.event.ActionEvent e) {
			String filter = getFilterTextField().getText();
			String path = getFolderTextField().getText();
			
			startDisabled();
			
			worker = new FTPWorker(path,filter);
			
			worker.start();
		}
	}
	
	public static Properties props = new Properties();  //  @jve:decl-index=0:

	private FTPWorker worker;
	
	private static FTPUploader ftpUploader;

	private JFrame jFrame = null;  //  @jve:decl-index=0:visual-constraint="10,10"

	private JPanel jContentPane = null;

	private JMenuBar jJMenuBar = null;

	private JMenu fileMenu = null;

	private JMenuItem exitMenuItem = null;

	private JScrollPane statusScrollPane = null;

	private JTable statusTable = null;

	private JXStatusBar statusBar = null;

	private JProgressBar progressBar = null;

	private JLabel stateLabel = null;

	private JPanel jPanel = null;

	private JLabel jLabel = null;

	private JTextField filterTextField = null;

	private JPanel jPanel1 = null;

	private JButton startButton = null;

	private JButton stopButton = null;

	private JLabel jLabel1 = null;

	private JTextField folderTextField = null;
	
	private Timer timer = null;

	private JButton reportButton = null;

	private FTPUploader(){
		ftpUploader = this;
	}
	
	public static FTPUploader getForm(){
		return ftpUploader;
	}

	/**
	 * This method initializes statusScrollPane	
	 * 	
	 * @return javax.swing.JScrollPane	
	 */
	private JScrollPane getStatusScrollPane() {
		if (statusScrollPane == null) {
			statusScrollPane = new JScrollPane();
			statusScrollPane.setViewportView(getStatusTable());
		}
		return statusScrollPane;
	}

	/**
	 * This method initializes statusTable	
	 * 	
	 * @return javax.swing.JTable	
	 */
	private JTable getStatusTable() {
		if (statusTable == null) {
			statusTable = new JTable();
			statusTable.setModel(new DeviceTableModel());
			
		}
		return statusTable;
	}

	/**
	 * This method initializes statusBar	
	 * 	
	 * @return org.jdesktop.swingx.statusBar	
	 */
	private JXStatusBar getStatusBar() {
		if (statusBar == null) {
			stateLabel = new JLabel();
			stateLabel.setText("");
			statusBar = new JXStatusBar();
			statusBar.add(getProgressBar(), null);
			statusBar.add(stateLabel, null);
		}
		return statusBar;
	}

	/**
	 * This method initializes progressBar	
	 * 	
	 * @return javax.swing.JProgressBar	
	 */
	private JProgressBar getProgressBar() {
		if (progressBar == null) {
			progressBar = new JProgressBar();
			progressBar.setMinimum(0);
			progressBar.setMaximum(100);			
		}
		return progressBar;
	}
	
	public void startProgressBar(){
		progressBar.setIndeterminate(true);
	}
	
	public void stopProgressBar(){
		progressBar.setIndeterminate(false);
	}
	
	public void startEnabled(){
		startButton.setEnabled(true);	
		stopButton.setEnabled(false);
		filterTextField.setEnabled(true);
		folderTextField.setEnabled(true);
	}
	
	public void startDisabled(){
		startButton.setEnabled(false);
		stopButton.setEnabled(true);
		filterTextField.setEnabled(false);
		folderTextField.setEnabled(false);
	}
	
	public void setStatusMessage(String text){
		stateLabel.setText(text);
	}
	
	public void updateStatusTable(){
		
		statusTable.setModel(new DeviceTableModel());
	}
	
	public void triggerAlarm(){
		if (timer == null)
			timer = new Timer(2*60*1000, new Start());
		
		timer.setRepeats(false);
		timer.start();
	}
	
	/**
	 * This method initializes jPanel	
	 * 	
	 * @return javax.swing.JPanel	
	 */
	private JPanel getJPanel() {
		if (jPanel == null) {
			GridBagConstraints gridBagConstraints4 = new GridBagConstraints();
			gridBagConstraints4.fill = GridBagConstraints.HORIZONTAL;
			gridBagConstraints4.gridy = 1;
			gridBagConstraints4.weightx = 1.0;
			gridBagConstraints4.insets = new Insets(2, 2, 2, 2);
			gridBagConstraints4.gridx = 1;
			GridBagConstraints gridBagConstraints3 = new GridBagConstraints();
			gridBagConstraints3.gridx = 0;
			gridBagConstraints3.insets = new Insets(2, 2, 2, 2);
			gridBagConstraints3.gridy = 1;
			jLabel1 = new JLabel();
			jLabel1.setText("Folder:");
			GridBagConstraints gridBagConstraints21 = new GridBagConstraints();
			gridBagConstraints21.gridx = 0;
			gridBagConstraints21.gridwidth = 2;
			gridBagConstraints21.fill = GridBagConstraints.BOTH;
			gridBagConstraints21.gridy = 2;
			GridBagConstraints gridBagConstraints2 = new GridBagConstraints();
			gridBagConstraints2.gridx = 0;
			gridBagConstraints2.gridwidth = 6;
			gridBagConstraints2.gridy = 1;
			GridBagConstraints gridBagConstraints1 = new GridBagConstraints();
			gridBagConstraints1.gridx = 0;
			gridBagConstraints1.insets = new Insets(2, 2, 2, 0);
			gridBagConstraints1.gridy = 0;
			GridBagConstraints gridBagConstraints = new GridBagConstraints();
			gridBagConstraints.fill = GridBagConstraints.BOTH;
			gridBagConstraints.gridy = 0;
			gridBagConstraints.weightx = 1.0;
			gridBagConstraints.anchor = GridBagConstraints.WEST;
			gridBagConstraints.insets = new Insets(2, 2, 2, 2);
			gridBagConstraints.gridwidth = 2;
			gridBagConstraints.gridx = 1;
			jLabel = new JLabel();
			jLabel.setText("Filter:");
			jPanel = new JPanel();
			jPanel.setLayout(new GridBagLayout());
			jPanel.add(jLabel, gridBagConstraints1);
			jPanel.add(getFilterTextField(), gridBagConstraints);
			jPanel.add(getJPanel1(), gridBagConstraints21);
			jPanel.add(jLabel1, gridBagConstraints3);
			jPanel.add(getFolderTextField(), gridBagConstraints4);
		}
		return jPanel;
	}

	/**
	 * This method initializes filterTextField	
	 * 	
	 * @return javax.swing.JTextField	
	 */
	private JTextField getFilterTextField() {
		if (filterTextField == null) {
			filterTextField = new JTextField();
		}
		return filterTextField;
	}

	/**
	 * This method initializes jPanel1	
	 * 	
	 * @return javax.swing.JPanel	
	 */
	private JPanel getJPanel1() {
		if (jPanel1 == null) {
			FlowLayout flowLayout = new FlowLayout();
			flowLayout.setAlignment(FlowLayout.LEFT);
			jPanel1 = new JPanel();
			jPanel1.setLayout(flowLayout);
			jPanel1.add(getStartButton(), null);
			jPanel1.add(getStopButton(), null);
			jPanel1.add(getReportButton(), null);
		}
		return jPanel1;
	}

	/**
	 * This method initializes startButton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getStartButton() {
		if (startButton == null) {
			startButton = new JButton();
			startButton.setText("Start");
			startButton.addActionListener(new Start());
		}
		return startButton;
	}

	/**
	 * This method initializes stopButton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getStopButton() {
		if (stopButton == null) {
			stopButton = new JButton();
			stopButton.setText("Stop");			
			stopButton.setEnabled(false);
			stopButton.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					if (worker != null)
						worker.Stop();
					else
						startEnabled();
					
					if (timer != null)
						timer.stop();
					
					stopButton.setEnabled(false);
				}
			});
		}
		return stopButton;
	}

	/**
	 * This method initializes folderTextField	
	 * 	
	 * @return javax.swing.JTextField	
	 */
	private JTextField getFolderTextField() {
		if (folderTextField == null) {
			folderTextField = new JTextField();			
		}
		return folderTextField;
	}

	/**
	 * This method initializes reportButton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getReportButton() {
		if (reportButton == null) {
			reportButton = new JButton();
			reportButton.setText("Reports...");
			reportButton.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					(new ResultPresenter()).setVisible(true);
				}
			});
		}
		return reportButton;
	}

	/**
	 * @param args
	 * @throws IOException 
	 */
	public static void main(String[] args) throws IOException {
		
		if (!(new java.io.File(
				java.lang.System.getenv("HOME")+"/.aircableftp")
				).exists() ){
			
			FileWriter out = new FileWriter(java.lang.System.getenv("HOME")+"/.aircableftp");
			
			out.write(
					"log4j.rootLogger=info, stdout, R\n"+
					"\n"+
					"log4j.appender.stdout=org.apache.log4j.ConsoleAppender\n"+
					"log4j.appender.stdout.layout=org.apache.log4j.PatternLayout\n"+
					"\n"+
					"# Pattern to output the caller's file name and line number.\n"+
					"log4j.appender.stdout.layout.ConversionPattern=%d %-5p - %-55m - %-25c (%13F:%L) %n"+
					"\n"+
					"log4j.appender.R=org.apache.log4j.RollingFileAppender\n"+
					"log4j.appender.R.File="+ java.lang.System.getenv("HOME") +"/aircableftp.log\n"+
					"\n"+
					"log4j.appender.R.MaxFileSize=100KB\n"+
					"# Keep one backup file\n"+
					"log4j.appender.R.MaxBackupIndex=1\n"+
					"\n"+
					"log4j.appender.R.layout=org.apache.log4j.PatternLayout\n"+
					"log4j.appender.R.layout.ConversionPattern=%d %-5p - %-55m - %-25c (%13F:%L) %n\n"
					);
			
			out.close();
			
		}
		
		PropertyConfigurator.configure(java.lang.System.getenv("HOME")+"/.aircableftp");
	
	    try {
			FileInputStream istream = new FileInputStream(java.lang.System.getenv("HOME")+"/.aircableftp");
			props.load(istream);
			istream.close();
	    }
	    catch (IOException e) {
	    	System.err.println("Could not read configuration file ["+java.lang.System.getenv("HOME")+"/.aircableftp"+"].");
	    	System.err.println("Ignoring configuration file [" + java.lang.System.getenv("HOME")+"/.aircableftp"+"].");
	    	return;
	    }
		
		
		SwingUtilities.invokeLater(new Runnable() {
			public void run() {
				FTPUploader application = new FTPUploader();
				application.getJFrame().setVisible(true);
			}
		});
	}

	/**
	 * This method initializes jFrame
	 * 
	 * @return javax.swing.JFrame
	 */
	private JFrame getJFrame() {
		if (jFrame == null) {
			jFrame = new JFrame();
			jFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
			jFrame.setJMenuBar(getJJMenuBar());
			jFrame.setSize(543, 469);
			jFrame.setContentPane(getJContentPane());
			jFrame.setTitle("AIRcable FTP Automatic Uploader");
			jFrame.addWindowListener(new java.awt.event.WindowAdapter() {
				public void windowClosing(java.awt.event.WindowEvent e) {
					try {
						props.store(new FileOutputStream(
								java.lang.System.getenv("HOME")+"/.aircableftp")
						, "AIRcable FTP Uploader Settings");
					} catch (FileNotFoundException e1) {
						e1.printStackTrace();
					} catch (IOException e1) {
						e1.printStackTrace();
					}
				}
			});
		}
		return jFrame;
	}

	/**
	 * This method initializes jContentPane
	 * 
	 * @return javax.swing.JPanel
	 */
	private JPanel getJContentPane() {
		if (jContentPane == null) {
			jContentPane = new JPanel();
			jContentPane.setLayout(new BorderLayout());
			jContentPane.add(getStatusScrollPane(), BorderLayout.CENTER);
			jContentPane.add(getStatusBar(), BorderLayout.SOUTH);
			jContentPane.add(getJPanel(), BorderLayout.NORTH);
			
			if (props.get("net.aircable.utils.FTPUloader.path")==null)
				props.put("net.aircable.utils.FTPUloader.path", System.getenv("HOME")+"/basic");
			this.getFolderTextField().setText(props.get("net.aircable.utils.FTPUloader.path").toString());

				
			if (props.get("net.aircable.utils.FTPUloader.filter")==null)
				props.put("net.aircable.utils.FTPUloader.filter", "AC");				
			this.getFilterTextField().setText(props.get("net.aircable.utils.FTPUloader.filter").toString());
			
			
		}
		return jContentPane;
	}

	/**
	 * This method initializes jJMenuBar	
	 * 	
	 * @return javax.swing.JMenuBar	
	 */
	private JMenuBar getJJMenuBar() {
		if (jJMenuBar == null) {
			jJMenuBar = new JMenuBar();
			jJMenuBar.add(getFileMenu());
		}
		return jJMenuBar;
	}

	/**
	 * This method initializes jMenu	
	 * 	
	 * @return javax.swing.JMenu	
	 */
	private JMenu getFileMenu() {
		if (fileMenu == null) {
			fileMenu = new JMenu();
			fileMenu.setText("File");
			fileMenu.add(getExitMenuItem());
		}
		return fileMenu;
	}

	/**
	 * This method initializes jMenuItem	
	 * 	
	 * @return javax.swing.JMenuItem	
	 */
	private JMenuItem getExitMenuItem() {
		if (exitMenuItem == null) {
			exitMenuItem = new JMenuItem();
			exitMenuItem.setText("Exit");
			exitMenuItem.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent e) {
					System.exit(0);
				}
			});
		}
		return exitMenuItem;
	}

}
