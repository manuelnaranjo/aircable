/**
 * @autor Manuel Naranjo <naranjo.manuel@gmail.com>
 * @since 09/02/2007
 * 
 */
package net.aircable.utils;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.Properties;

import javax.swing.JButton;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.JToolBar;
import javax.swing.filechooser.FileFilter;

import static net.aircable.utils.FTPUploader.props;

/**
 *
 * @autor Manuel Naranjo <naranjo.manuel@gmail.com>
 * @since 09/02/2007
 *
 */
public class ResultPresenter extends JFrame {
	
	private static final long serialVersionUID = 1L;

	private JPanel jContentPane = null;

	private JToolBar jToolBar = null;

	private JButton pdfButton = null;

	private JButton clearLogButton = null;

	private JButton refreshButton = null;

	private JButton closeButton = null;

	private JScrollPane jScrollPane = null;

	private JTable resultTable = null;
	
	/**
	 * This is the default constructor
	 */
	public ResultPresenter() {
		super();
		initialize();
	}

	/**
	 * This method initializes this
	 * 
	 * @return void
	 */
	private void initialize() {
		this.setVisible(false);
		this.setPreferredSize(new Dimension(550, 486));
		this.setSize(700, 292);		
		this.setContentPane(getJContentPane());
		this.setTitle("Results");
		parseLOG();
		this.setVisible(true);		
	}
	
	private void parseLOG(){
		try {		    

			BufferedReader in = new BufferedReader(
					new FileReader(
							props.getProperty("log4j.appender.R.File")));
			String line;
			Device lastDevice = null;
			while ((line = in.readLine())!=null){
				String time;				
				time = line.substring(0, 23).trim();
				
				if (line.matches(".*[INFO\\s*-]\\s*([a-zA-Z0-9]{12})\\s*[-].*[-].*")){
					String temp;
					String addr;
					String name;
				
					temp = line.substring(line.indexOf("INFO"));
					temp = temp.substring(temp.indexOf("-")+1);
					addr = temp.substring(0, temp.indexOf("-"));
					addr = addr.trim();
					
					temp = temp.substring(temp.indexOf("-")+1);
					temp = temp.trim();
					name = temp.substring(0,temp.indexOf("- net.aircable.utils.Uploader")).trim();
					
					lastDevice = new Device(addr, name, Device.states.OnQue);
					lastDevice.setTimeLastAction(time);
				} else if (line.indexOf("Sending AIRcable.bas")>-1){
					lastDevice.setState(Device.states.SendingBAS);
					lastDevice.setTimeLastAction(time);
				}
				else if (line.indexOf("Sending config.txt")>-1){
					lastDevice.setState(Device.states.SendingCFG);
					lastDevice.setTimeLastAction(time);
				}
				else if (lastDevice!=null && 
						line.indexOf("DONE") > -1 &&
						line.indexOf("DONE") < line.indexOf(lastDevice.getAddr())){
							lastDevice.setState(Device.states.Done);
							lastDevice.setTimeLastAction(time);
				}
				else if (lastDevice!=null && 
						line.indexOf("FAILED") > -1 &&
						line.indexOf("FAILED") < line.indexOf(lastDevice.getAddr())){
							lastDevice.setState(Device.states.Failure);
							lastDevice.setTimeLastAction(time);					
				}	
			}
		} catch (FileNotFoundException e) {
			Uploader.log.error("There is no log file.\n", e);			
		} catch (IOException e) {
			Uploader.log.error("There has been an exception while reading the log file.\n", e);			
		}
		
		resultTable.setModel(new DeviceTableModelPrint());
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
			jContentPane.add(getJToolBar(), BorderLayout.NORTH);
			jContentPane.add(getJScrollPane(), BorderLayout.CENTER);
		}
		return jContentPane;
	}

	/**
	 * This method initializes jToolBar	
	 * 	
	 * @return javax.swing.JToolBar	
	 */
	private JToolBar getJToolBar() {
		if (jToolBar == null) {
			jToolBar = new JToolBar();
			jToolBar.add(getPdfButton());
			jToolBar.add(getRefreshButton());
			jToolBar.add(getClearLogButton());
			jToolBar.add(getCloseButton());
		}
		return jToolBar;
	}

	/**
	 * This method initializes pdfButton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getPdfButton() {
		if (pdfButton == null) {
			pdfButton = new JButton();
			pdfButton.setText("Generate PDF File");
			pdfButton.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					JFileChooser fc = new JFileChooser();
					
					fc.setFileFilter(new FileFilter(){

						public boolean accept(File f) {
							if (f.getName().endsWith(".pdf"))
								return true;
							if (f.isDirectory())
								return true;
							return false;
						}

						public String getDescription() {
							return "(*.pdf) Adobe PDF Document";							
						}						
					});
					
					fc.setFileSelectionMode(JFileChooser.FILES_ONLY);
					
					int returnVal = fc.showSaveDialog(ResultPresenter.this);
					if (returnVal == JFileChooser.APPROVE_OPTION){
						new PDFPrinter(
								fc.getSelectedFile().getAbsolutePath())
						.printToFile();						
					}
				}
			});
		}
		return pdfButton;
	}

	/**
	 * This method initializes clearLogButton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getClearLogButton() {
		if (clearLogButton == null) {
			clearLogButton = new JButton();
			clearLogButton.setText("Clear Log");
			clearLogButton.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					File a = new File(props.getProperty("log4j.appender.R.File"));
					a.deleteOnExit();
					javax.swing.JOptionPane.showMessageDialog(ResultPresenter.this, "The file will be deleted once you close the application");
				}
			});
		}
		return clearLogButton;
	}

	/**
	 * This method initializes refreshButton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getRefreshButton() {
		if (refreshButton == null) {
			refreshButton = new JButton();
			refreshButton.setText("Refresh");
			refreshButton.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					parseLOG();
				}
			});
		}
		return refreshButton;
	}

	/**
	 * This method initializes closeButton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getCloseButton() {
		if (closeButton == null) {
			closeButton = new JButton();
			closeButton.setText("Close Window");
			closeButton.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					ResultPresenter.this.dispose();
				}
			});
		}
		return closeButton;
	}

	/**
	 * This method initializes jScrollPane	
	 * 	
	 * @return javax.swing.JScrollPane	
	 */
	private JScrollPane getJScrollPane() {
		if (jScrollPane == null) {
			jScrollPane = new JScrollPane();
			jScrollPane.setViewportView(getResultTable());
		}
		return jScrollPane;
	}

	/**
	 * This method initializes resultTable	
	 * 	
	 * @return javax.swing.JTable	
	 */
	private JTable getResultTable() {
		if (resultTable == null) {
			resultTable = new JTable();
			resultTable.setModel(new DeviceTableModelPrint());
		}
		return resultTable;
	}
	
	//internal Device representer;
	

}  //  @jve:decl-index=0:visual-constraint="10,10"

