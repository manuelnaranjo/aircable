/**
 * @autor Manuel Naranjo <naranjo.manuel@gmail.com>
 * @since 08/01/2007
 * 
 */
package net.aircable.coding;

/**
 *
 * @autor Manuel Naranjo <naranjo.manuel@gmail.com>
 * @since 08/01/2007
 *
 */
public class Tree {
	public Tree right, left;
	public Line content;
	
	public String toString(){
		return content.toString();
	}
}
