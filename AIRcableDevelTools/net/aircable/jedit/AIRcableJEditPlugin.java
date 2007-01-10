/**
 * AIRcable's JEdit Plugin - Main file
 * @autor Manuel Naranjo <manuel@aircable.net>
 * @since 19/12/2006
 * 
 */
package net.aircable.jedit;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.Iterator;
import java.util.Set;
import java.util.Vector;

import org.gjt.sp.jedit.EditPlugin;

public class AIRcableJEditPlugin extends EditPlugin {
	public static final String NAME = "aircable";
	public static final String OPTION_PREFIX = "options.aircable.";
	
	public static Vector<Line> findCalls(String lineNumber, String input){				
		Line.parseFile(input);
		
		return Line.getLine(Integer.parseInt(lineNumber)).findCalls();
	}
	
	public static String moveLine(String input, Integer firstLine, Integer lastLine, Integer newStart){
		StringBuffer out = new StringBuffer();
		
		Line.parseFile(input);
		
		for (int i = firstLine.intValue() ; i < lastLine.intValue() ; i++){
			Line original		= Line.getLine(i);
			if (original != null){
				int index = i + newStart.intValue() - firstLine.intValue();
				Vector<Line> calls 	= original.findCalls();
				
				Interrupt.moveInterrupt(i, index);
				
				original.moveLine(index);
				
				for (int k = 0 ; k < calls.size() ; k++){
					calls.get(k).updateCall(i, index);
				}
			}
		}
		
		Interrupt t;
		
		t = Interrupt.findInterrupt("ERASE");
		if (t!= null){
			out.append(t);
			out.append(System.getProperty("line.separator"));
		}
		t = Interrupt.findInterrupt("UNPAIR");
		if (t!= null){
			out.append(t);
			out.append(System.getProperty("line.separator"));
		}
		
		Iterator<String> interrupts  = Interrupt.getInterrupts().iterator();
		while (interrupts.hasNext()){
			String key = interrupts.next();
			if (!key.equals("ERASE") || !key.equals("UNPAIR")){
				out.append(Interrupt.getInterrupt(key));
				out.append(System.getProperty("line.separator"));
			}
		}
		Iterator<Integer> temp = Line.getKeySet().iterator();
		while (temp.hasNext()){
			out.append(Line.getLine(temp.next().intValue()));
			out.append(System.getProperty("line.separator"));
		}
		
		out.append(System.getProperty("line.separator"));
		return out.toString();
	}
	
	public static Vector<Integer> findEmptyLines(String input){
		Vector<Integer> out = new Vector<Integer>();
		Line temp;
		Line.parseFile(input);
		
		for (int i = 1 ; i < 1024 ; i++){
			temp = Line.getLine(i);
			if (temp == null)
				out.add(new Integer(i));
		}
			
		return out;
		
	}
	
	public static void main(String[] args) throws IOException{
		if (args.length==0){
			System.out.println(
					"Usage:\n" +
					"AIRcableJEditPlugin command arguments\n" +
					"\n" +
					"Commands:\n" +
					"\tf find calls in file\n" +
					"\ti print full interrupt code\n" +
					"\te find empty lines\n" +
					"\tm move lines\n" +
					"\ts supres spaces");
		}
		
		if (args[0].equals("f")){
			if (args.length!=3){
				System.out.println(
						"Usage:\n" +
						"\tf Line_Number File");
				System.exit(0);
			}
			
			Vector<Line> calls;
			
			calls = findCalls(args[1],readFile(args[2]));
			
			for (int i = 0 ; i < calls.size() ; i++)
				System.out.println(calls.get(i));			
		} else if (args[0].equals("i")){
			if (args.length!=3){
				System.out.println(
						"Usage:\n" +
						"\ti INQUIRY_NAME File");
				System.exit(0);
			}
			
			Line.parseFile(readFile(args[2]));
			
			Interrupt t = Interrupt.getInterrupt(args[1]);
			
			if (t!=null){
				Tree k = t.fillTree();
				Tree node = k;
				
				System.out.println(k);
				
				while ((node = node.right)!=null){
					System.out.println(node);
				}
				
				
			}
		} else if (args[0].equals("e")){
			if (args.length!=2){
				System.out.println(
						"Usage:\n" +
						"\ti File");
				System.exit(0);
			}
			
			Vector<Integer> temp2 = findEmptyLines(readFile(args[1]));
			Iterator<Integer> temp = temp2.iterator();
		
			System.out.println(temp2.size() + " lines of 1024 available are empty");
			while (temp.hasNext())
				System.out.println(temp.next() + " is empty");
			
		} else if (args[0].equals("m")){
			if (args.length!=5){
				System.out.println(
						"Usage:\n" +
						"\tm File Start_Index End_Index New_Index");
				System.exit(0);
			}
			
			System.out.println(
					moveLine(readFile(args[1]), 
							new Integer(args[2]), 
							new Integer(args[3])
							,new Integer(args[4])));
			
			
		} else if (args[0].equals("s")){
			if (args.length!=4){
				System.out.println(
						"Usage:\n" +
						"\ts File Start_Index End_Index");
				System.exit(0);
			}
			
			System.out.println(
					SupressSpaces(readFile(args[1]), 
							Integer.parseInt(args[2]), 
							Integer.parseInt(args[3])));
			
		}
		else 
			System.out.println("Command is not valid");
	}
	
	public static String SupressSpaces(String input, int startIndex, int endIndex){
		Line.parseFile(input);
		
		int i = startIndex;
		int index = startIndex;
		Line line;
		
		while (i < endIndex){
			while (((line = Line.getLine(i))==null || line.text.isEmpty())&& i < endIndex){
				i++;
			}
			
			if (line == null)
				break;
			
			Vector<Line> calls 	= line.findCalls();
			
			Interrupt.moveInterrupt(i, index);
			
			line.moveLine(index);
			
			for (int k = 0 ; k < calls.size() ; k++){
				calls.get(k).updateCall(i, index);
			}			
						
			line = null;			
			index++;
			i++;
		}
		
		StringBuffer out = new StringBuffer();
		
		Interrupt t = Interrupt.findInterrupt("ERASE");
		if (t!= null){
			out.append(t);
			out.append(System.getProperty("line.separator"));
		}
		t = Interrupt.findInterrupt("UNPAIR");
		if (t!= null){
			out.append(t);
			out.append(System.getProperty("line.separator"));
		}
		
		Iterator<String> interrupts  = Interrupt.getInterrupts().iterator();
		while (interrupts.hasNext()){
			String key = interrupts.next();
			if (!key.equals("ERASE") || !key.equals("UNPAIR")){
				out.append(Interrupt.getInterrupt(key));
				out.append(System.getProperty("line.separator"));
			}
		}
		Iterator<Integer> temp = Line.getKeySet().iterator();
		while (temp.hasNext()){
			out.append(Line.getLine(temp.next().intValue()));
			out.append(System.getProperty("line.separator"));
		}
		
		out.append(System.getProperty("line.separator"));
		
		return out.toString();
	}
	
	protected static String parseLine(String in){
		String out = "";
		boolean a = false;
		boolean b = false;
		
		for (int i = 0 ; i < in.length(); i++)
			if (!a && in.charAt(i)!=' ')
				out+=in.charAt(i);
			else if (in.charAt(i)=='"')
				b = true;
			else if (b || in.charAt(i)!=' ')
				out+=in.charAt(i);				
		
		
		return out;
	}
	
	private static String readFile(String route) throws IOException{
		String line;
		StringBuffer content = new StringBuffer();		
		
		BufferedReader in = new BufferedReader(new FileReader(route));	
		
		while (( line = in.readLine()) != null){
			content.append(line);
			content.append(System.getProperty("line.separator"));
		}

		return content.toString();
	}

}
