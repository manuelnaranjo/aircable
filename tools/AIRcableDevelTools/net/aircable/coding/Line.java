/**
 * @autor Manuel Naranjo <naranjo.manuel@gmail.com>
 * @since 08/01/2007
 * 
 */
package net.aircable.coding;

import java.util.EmptyStackException;
import java.util.Iterator;
import java.util.Set;
import java.util.Stack;
import java.util.StringTokenizer;
import java.util.TreeMap;
import java.util.Vector;
import java.util.regex.Pattern;

/**
 *
 * @autor Manuel Naranjo <naranjo.manuel@gmail.com>
 * @since 08/01/2007
 *
 */
public class Line {
	protected int		lineNumber=-1;
	protected String 	text, original;
	protected Line		nextLine;
	protected String	comments;
	protected String	originalString;
	
	private static Stack<Line> stack;
	
	private static TreeMap<Integer,Line> lines;
	
	protected static String comment_buffer ="";
	
	protected Line(){}
	
	private String getParsedLine(){
		String k = parseLine(this.text).trim();
		if (k.endsWith(";"))
			k = k.substring(0,k.length()-1);
		return k;
	}
	
	public String getOriginalString() {
		return originalString;
	}
	
	public void updateOriginalString() {
		originalString = this.toString();
	}

	public static Line getLine(String text){
		if (lines == null){
			GenerateLineMap();			
		}
		
		int lineNumber;
		
		if (text.indexOf(" ")==-1 || text.indexOf("REM")>-1){
			comment_buffer += text;
			comment_buffer += System.getProperty("line.separator");
			return null;
		}
		
		if (text.startsWith("@")) {
			return (Line)Interrupt.getInterrupt(text);
		}
					
		try {		
			lineNumber = Integer.parseInt(text.substring(0,text.indexOf(" ")));	 
		} catch (java.lang.NumberFormatException e2) {
			return null;
		}
		
		Line t;
		
		if ((t=lines.get(new Integer(lineNumber)))!=null){
			System.err.println("There are two lines with the same number:\n"+
					text + "\n" +
					t.toString() + "\n" +
					"I can' go on");
			
			System.exit(1);
		}
		
		Line out = new Line();
		out.text = text.substring(text.indexOf(' ')).trim();
		out.lineNumber = lineNumber;
		out.comments = comment_buffer;
		out.originalString = text;
		comment_buffer = "";
		lines.put(new Integer(lineNumber), out);
		return out;
	}
	
	public static Line getLine(int line){
		return lines.get(line);
	}
	
	private static void GenerateLineMap(){
		lines = new TreeMap<Integer,Line>();
	}

	@Override
	public int hashCode() {
		final int PRIME = 31;
		int result = 1;
		result = PRIME * result + lineNumber;
		if (text != null)
			result+=text.hashCode();
		
		return result;
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
		if (lineNumber != other.lineNumber)
			return false;
		return true;
	}

	public Line getNextLine() {
		return nextLine;
	}

	public void setNextLine(Line nextLine) {
		this.nextLine = nextLine;
	}

	public String getText() {
		return text;
	}

	public void setText(String text) {
		this.text = text;
	}

	public int getLineNumber() {
		return lineNumber;
	}
	
	public String toString(){
		String out ="";
	
		out += lineNumber + " " + text;
		
		return  out;
	}
		
	public boolean isJumpStatement(){
		return text.contains("GOTO") || text.contains("GOSUB") || text.contains("THEN");
	}
	
	public void updateNextLine(){
		int nextLine;
		int index = -10;
		String text = getParsedLine();
		index = text.indexOf("GOTO") + 4;
		if (index < 4)
			index = text.indexOf("GOSUB") + 5;
				if (index < 5)
					index = text.indexOf("THEN") + 4;
					if (index < 4)
						index = -10;
				
		if (text.indexOf(";")!=-1)
			text = text.substring(0, text.length()-1);
		
		if (index != -10)
			nextLine = Integer.parseInt(text.substring(index));
		else
			nextLine = this.lineNumber+1;
		
		this.nextLine = getLine(nextLine);
	}
	
	public boolean isIfStatement(){
		return text.contains("IF");
	}
	
	public Line getTrueCase(){
		return nextLine;
	}
	
	public Line getFalseCase(){
		return getLine(this.lineNumber + 1);
	}
	
	public static Tree generateTree(){
		Tree out = new Tree();
		
		out.content = getLine(1);
		
		out.right = out.content.fillTree();
		
		return out;
	}
	
	public Tree fillTree(){
		stack = new Stack<Line>();
		return fillTree(0);
	}
	
	private static void addToStack(Line lin){
		if (stack.size() == 8)
			throw new RuntimeException("Stack overflow at line: " + lin);
		
		stack.push(lin);
	}
	
	private static Line getFromStack() {
		Line t = null;
		try{
			t = stack.pop();
		} catch(EmptyStackException e ){
			throw new RuntimeException("Stack is empty, there is an extra return");
		}
		return t;
	}
	
	private Tree fillTree(int ident){
		Tree out = new Tree();
		
		out.content = this;		
		
		if (this instanceof Interrupt && nextLine == null)
			nextLine = getLine(this.lineNumber);
		
		if (nextLine == null)
			this.updateNextLine();
		
		if (nextLine !=null)			
			if (this.text.indexOf("RETURN")==-1 || (this.text.indexOf("RETURN")!=-1 && ident > 0)){
				if (this.text.indexOf("GOSUB")!=-1){
					stack.push(getFalseCase());
					ident++;
				}
				else if (this.text.indexOf("RETURN")!=-1 && !stack.empty()) {
					ident--;
					out.right = stack.pop().fillTree(ident);
					return out;
				}
						
				out.right = getTrueCase().fillTree(ident);
				
			}
			else return null;
		
		if (isIfStatement())
			out.left = getFalseCase().fillTree(ident);

		return out;
	}
	
	/**
	 * This method will find all the other lines that call this line
	 * @return
	 */
	public Vector<Line> findCalls() {
		Vector<Line> out = new Vector<Line>();
		
		Iterator<Line> lin  = lines.values().iterator();
		
		while (lin.hasNext()){
			Line line = lin.next();		
			if (!line.equals(this)){
				String temp = line.getParsedLine();
				if (temp.endsWith(";"))
					temp = temp.substring(0, temp.length()-1);
				
				if (temp.endsWith("GOTO" + lineNumber) 
						|| temp.endsWith("GOSUB" + lineNumber)
						|| temp.endsWith("THEN" + lineNumber)
						|| temp.endsWith("$" + lineNumber)
						|| temp.contains("$" + lineNumber + "[")
						|| temp.contains("$" + lineNumber+ "="))
					out.add(line);
			}	
		}

		return out;
	}
	
	public static void parseFile(String input){
		lines = new TreeMap<Integer, Line>();
		StringTokenizer in = new StringTokenizer(input,System.getProperty("line.separator"));
				
		while (in.hasMoreElements()){
			Line k = Line.getLine(in.nextToken());
			if (k != null)
				if (k.isJumpStatement())
					k.updateNextLine();				
			
		}		
	}
	
	public void moveLine(int newIndex){
		lines.remove(new Integer(lineNumber));
		lineNumber = newIndex;		
		lines.put(new Integer(lineNumber), this);
	}
	
	public static Set<Integer> getKeySet(){		
		return lines.keySet();		
	}
	
	public void updateCall(int oldIndex, int newIndex){
		
		if (Pattern.compile("(?!GOTO\\D)" + oldIndex +"(?=\\D|$)").matcher(this.text).find())
			text = Pattern.compile("(?!GOTO\\D)" + oldIndex +"(?=\\D|$)").matcher(this.text).replaceFirst(""+newIndex);		
		if (Pattern.compile("(?!GOSUB\\D)" + oldIndex +"(?=\\D|$)").matcher(this.text).find())
			text = Pattern.compile("(?!GOSUB\\D)" + oldIndex +"(?=\\D|$)").matcher(this.text).replaceFirst(""+newIndex);
		if (Pattern.compile("(?!THEN\\D)" + oldIndex +"(?=\\D|$)").matcher(this.text).find())
			text = Pattern.compile("(?!THEN\\D)" + oldIndex +"(?=\\D|$)").matcher(this.text).replaceFirst(""+newIndex);
		if (Pattern.compile("(\\$)" + oldIndex +"(?=\\D|$)").matcher(this.text).find())
			text = Pattern.compile("(\\$)" + oldIndex +"(?=\\D|$)").matcher(this.text).replaceFirst("\\$" + newIndex);				
			
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
	
}
