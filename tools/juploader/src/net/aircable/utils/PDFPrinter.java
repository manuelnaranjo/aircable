/**
 * @autor Manuel Naranjo <naranjo.manuel@gmail.com>
 * @since 10/02/2007
 * 
 */
package net.aircable.utils;

import java.awt.Color;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.util.Calendar;
import java.util.Iterator;
import java.util.TimeZone;

import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;

/**
 *
 * @autor Manuel Naranjo <naranjo.manuel@gmail.com>
 * @since 10/02/2007
 *
 */
public class PDFPrinter {
	private String path;
	
	public PDFPrinter(String pat){
		path = pat;
	}
	
	public void printToFile(){
	    try {
	    	
			Document document = new Document(PageSize.A4);
			PdfWriter.getInstance(document, new FileOutputStream(path));
			document.open();
			
			Calendar cal = Calendar.getInstance(TimeZone.getDefault());
			    
		    String DATE_FORMAT = "yyyy-MM-dd HH:mm:ss";
		    java.text.SimpleDateFormat sdf = 
		          new java.text.SimpleDateFormat(DATE_FORMAT);

		    sdf.setTimeZone(TimeZone.getDefault());        
		    		    
			document.add(new Paragraph("Wireless Cables INC Production Report." +
					"\nDate: " + sdf.format(cal.getTime()) + "\n\n"));
   
			PdfPTable table = new PdfPTable(4);
			table.setWidthPercentage(100);
			table.setWidths(new float[]{1.2f,0.9f,1.7f,0.6f});
			table.addCell("Date");
			table.addCell("BT Address");
			table.addCell("Name");
			table.addCell("State");
			
			Iterator<String> devices = Device.devices.keySet().iterator();			
			
			while ( devices.hasNext()){
				Device dev = Device.devices.get(devices.next());
				
								
				if(dev.getState()==Device.states.Failure){
					PdfPCell 
					cell = new PdfPCell(new Paragraph(dev.getTimeLastAction()));					
					cell.setBackgroundColor(new Color(0x90, 0x90, 0x90));					
					table.addCell(cell);	
					cell = new PdfPCell(new Paragraph(dev.getAddr()));					
					cell.setBackgroundColor(new Color(0x90, 0x90, 0x90));					
					table.addCell(cell);
					cell = new PdfPCell(new Paragraph(dev.getName()));					
					cell.setBackgroundColor(new Color(0x90, 0x90, 0x90));					
					table.addCell(cell);
					cell = new PdfPCell(new Paragraph(dev.getState().toString()));					
					cell.setBackgroundColor(new Color(0x90, 0x90, 0x90));					
					table.addCell(cell);
				} else {
					table.addCell(dev.getTimeLastAction());				
					table.addCell(dev.getAddr());				
					table.addCell(dev.getName());				
					table.addCell(dev.getState().toString());
				}				
			}
			
			document.add(table);			

			document.close();
			
		} catch (FileNotFoundException e) {
			Uploader.log.error("Couldn't Find File", e);
		} catch (DocumentException e) {
			Uploader.log.error("Couldn't Generate File", e);			
		}
	}
	
	public static void main(String args[]){
		new PDFPrinter("test.pdf").printToFile();
	}
}
