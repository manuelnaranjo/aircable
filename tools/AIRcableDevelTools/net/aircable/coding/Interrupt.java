/**
 * @autor Manuel Naranjo <naranjo.manuel@gmail.com>
 * @since 08/01/2007
 * 
 */
package net.aircable.coding;

import java.util.Iterator;
import java.util.Set;
import java.util.TreeMap;

/**
 *
 * @autor Manuel Naranjo <naranjo.manuel@gmail.com>
 * @since 08/01/2007
 *
 */
public class Interrupt extends Line {
	
	private static TreeMap<String,Interrupt> interrupts;
	
	protected Interrupt(){
		if (interrupts == null)
			interrupts = new TreeMap<String,Interrupt>();
	}

	@Override
	public void setText(String text) {}
	
	public static Interrupt getInterrupt(String text){
		if (interrupts == null)
			interrupts = new TreeMap<String, Interrupt>();
		
		Interrupt k = interrupts.get(text);
		if (k==null)
			return parseInterrupt(text);
		return k;
	}
	
	public static Interrupt parseInterrupt(String text){
		if (interrupts == null)
			interrupts = new TreeMap<String,Interrupt>();
		
		if (text.indexOf("@")==-1)
			throw new RuntimeException("Format not suitable for Interrupts");
		
		String intName;
		if (text.indexOf(' ')> -1)
			intName = text.substring(1,text.indexOf(' '));
		else
			intName = text.substring(1);
		
		Interrupt inte = new Interrupt();
		inte.text = intName;
		
		inte.comments = comment_buffer;
		comment_buffer = "";
		
		inte.originalString = text;
		
		if (text.indexOf(' ') > -1) {		
			inte.lineNumber = Integer.parseInt(text.substring(text.indexOf(' ')).trim());
			inte.nextLine = Line.getLine(inte.lineNumber);
		}
		
		interrupts.put(intName, inte);
		
		return inte;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		final Line other = (Line) obj;
		if (!this.text.equals(other.text))
			return false;
		return true;
	}
	
	public String toString(){
		String temp ="";
		
		/*if (comments != null && !comments.trim().isEmpty())
			temp+= comments;*/
		temp += "@" + this.text;
		if (this.lineNumber>-1)
			temp += " " + this.lineNumber;
		return temp;
	}
	
	public static void moveInterrupt(int oldIndex, int newIndex){
		Iterator<String> inte = interrupts.keySet().iterator();
		
		while (inte.hasNext()){
			Interrupt t = interrupts.get(inte.next());
			
			if (t.lineNumber == oldIndex)
				t.lineNumber = newIndex;
		}			
	}
	
	public static Set<String> getInterrupts(){
		return interrupts.keySet();
	}
	
	public static Interrupt findInterrupt(String k){
		if (interrupts!=null)
			return interrupts.get(k);
		
		return null;
	}
	
}
