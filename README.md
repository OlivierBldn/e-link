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

5. **Connection Error Handling**:
   - If the connection fails, the app displays an error message to the user.

6. **Permission Handling**:
   - The app requests the necessary permissions for BLE functionality if they are not already granted.
   - The user is prompted to grant location and Bluetooth permissions.

7. **Device Details**:
   - The user can view the details of a connected device, including its MAC address and services.

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

5. **Disconnect from a Device**:
   - Tap on the connected device to disconnect from it.

6. **Request Permissions**:
   - The app will request the necessary permissions for BLE functionality if they are not already granted.

7. **Refresh Device List**:
   - Press the "Scan for Devices" button again to refresh the list of found devices.

8. **View Device Details**:
   - Tap on a device to view its details, including its MAC address, connection status, and services.

9. **Reconnect to a Device**:
   - If the connection is lost, the app will attempt to reconnect to the device automatically.

10. **Monitor Connection State**:
    - The app will display the current connection state in real-time, including `connecting`, `connected`, `disconnecting`, and `disconnected`.

11. **Handle Connection Errors**:
    - The app will display an error message if the connection fails.

---

#### Dependencies

- `flutter_reactive_ble`: Provides BLE scanning and connection functionality.
- `permission_handler`: Manages necessary permissions (location, Bluetooth) for BLE functionality.
- `cupertino_icon`: This is an asset repo containing the default set of icon assets used by Flutter's
- `provider`: By using provider instead of manually writing InheritedWidget, you get: simplified allocation/disposal of resources, lazy-loading, a vastly reduced boilerplate over making a new class every time, devtool friendly – using Provider, the state of your application will be visible in the Flutter devtool, a common way to consume these InheritedWidgets (See Provider.of/Consumer/Selector), increased scalability for classes with a listening mechanism that grows exponentially in complexity (such as ChangeNotifier, which is O(N) for dispatching notifications).
- `logger`: Small, easy to use and extensible logger which prints beautiful logs.
- `flutter_svg`: Draw SVG files using Flutter.
- `shared_preferences`: Wraps platform-specific persistent storage for simple data (NSUserDefaults on iOS and macOS, SharedPreferences on Android, etc.)