### E-Link Application Documentation

#### Description

This Flutter app includes the following features:
- **BLE scanning**: The app scans for nearby BLE devices and displays them in a list.
- **Device filtering**: The user can filter devices by their MAC address using a search bar.
- **Device connection**: The user can tap on a device to initiate a connection. The connection status is displayed in real-time.
- **Permission handling**: The app requests the necessary permissions for BLE functionality.

---

#### Features

1. **BLE Scanning**:
   - The app starts scanning for BLE devices when the user clicks the "Scan for Devices" button.
   - Devices found during scanning are added to a list and displayed to the user.

2. **Device Filtering**:
 - A search bar allows users to filter devices by their MAC address.

3. **Device Connection**:
   - When the user taps on a device in the list, the app attempts to connect to it.
   - The connection status is updated in real-time, and a loading spinner is shown while connecting.

4. **Connection States**:
   - The app handles four connection states: `connecting`, `connected`, `disconnecting`, and `disconnected`.
   - The user is informed of the current connection state through a status message and icons.

---

#### How to Use

1. **Scan for Devices**:
   - Press the "Scan for Devices" button to begin scanning for BLE devices.

2. **Filter Devices**:
   - Enter a part of a device's MAC address into the search bar to filter the list of found devices.

3. **Connect to a Device**:
   - Tap on a device to connect. The app will display connection progress and update the connection status once established.

4. **Monitor Connection Status**:
   - The app will notify you if the device is connected, disconnected, or if the connection fails.

---

#### Dependencies

- `flutter_reactive_ble`: Provides BLE scanning and connection functionality.
- `permission_handler`: Manages necessary permissions (location, Bluetooth) for BLE functionality.