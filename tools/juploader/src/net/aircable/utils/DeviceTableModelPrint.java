/**
 * @autor Manuel Naranjo <naranjo.manuel@gmail.com>
 * @since 09/02/2007
 * 
 */
package net.aircable.utils;

import static net.aircable.utils.Device.devices;

/**
 *
 * @autor Manuel Naranjo <naranjo.manuel@gmail.com>
 * @since 09/02/2007
 *
 */
public class DeviceTableModelPrint extends DeviceTableModel {
	private static final long serialVersionUID = -8185079264608929907L;
	
	public int getColumnCount() {		
		return 4;
	}
	
	public String getColumnName(int columnIndex) {
		if (columnIndex == 3)
			return "Time Last Action";
		
		return super.getColumnName(columnIndex);
	}
	
	public Object getValueAt(int rowIndex, int columnIndex) {
		if (columnIndex != 3)
			return super.getValueAt(rowIndex, columnIndex);
		
		Device dev = devices.get(devices.keySet().toArray()[rowIndex]);
		
		return dev.getTimeLastAction();
	}

}
