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

---

# BLEDeviceProvider Documentation

## Overview

The `BLEDeviceProvider` class is responsible for managing BLE device connections. It provides methods to connect to and disconnect from BLE devices, handling the low-level BLE operations required for device communication.

## Key Features

- **Device Connection Management**: Handles connecting to and disconnecting from BLE devices.
- **Device State Monitoring**: Provides methods for tracking and managing the connection state of the BLE device.

---

## Class: `BLEDeviceProvider`

### Constructor

```dart
BLEDeviceProvider();
```

The constructor initializes the provider that will manage the BLE device connections.

### Methods

#### `void connectToDevice(String deviceId)`

This method connects to the specified BLE device by its device ID.

- **Input**:
  - `String deviceId`: The unique identifier for the BLE device.
  
- **Output**:
  - Establishes a connection to the BLE device.

#### `void disconnectFromDevice()`

This method disconnects from the currently connected BLE device.

- **Output**:
  - Terminates the BLE connection.

---

## Usage Example

```dart
final BLEDeviceProvider bleDeviceProvider = BLEDeviceProvider();

// Connecting to a BLE device
bleDeviceProvider.connectToDevice('device-identifier');

// Disconnecting from the BLE device
bleDeviceProvider.disconnectFromDevice();
```

---

An image service has also been coded but isn't workin for yet. The code is available on other branch.

---

# ImageService Documentation

## Overview

The `ImageService` class is responsible for handling image processing and sending images via Bluetooth Low Energy (BLE). This service includes functionalities for converting images, compressing them, and sending them in chunks to a connected device using the BLE protocol.

## Key Features

- **Convert Images to Black and White**: The service provides functionality to convert any image into a 1-bit black-and-white format.
- **Image Compression**: Before sending, the images are compressed to optimize transmission over BLE.
- **Chunked Data Transfer**: Images are sent in chunks to accommodate the limited size of the BLE packet payload.
- **Progress Tracking**: The service updates the progress as chunks are sent to ensure smooth monitoring of the transfer.

---

## Class: `ImageService`

### Constructor

```dart
ImageService(this.progressService);
```

The constructor takes a `ProgressService` instance, which is used to track the progress of the image transfer.

### Fields

- **flutterReactiveBle**: Instance of `FlutterReactiveBle` used to manage BLE connections and communication.
- **progressService**: An instance of `ProgressService` to monitor and broadcast transfer progress.
- **compressionProvider**: Provides the functionality to compress the image data before transmission.

### Methods

#### `Future<Uint8List> convertImageToBWR(File imageFile)`

This method converts an input image to a 1-bit black/white/red format and returns the byte array of the resulting image.

- **Input**: 
  - `File imageFile`: The image file to be converted.
- **Output**:
  - Returns `Uint8List` representing the black/white/red image in a 1-bit format.

**Steps**:
1. Reads the image from the file.
2. Resizes the image to the required display resolution (400x300 in the current example).
3. Converts the image to grayscale.
4. Converts the grayscale image into a 1-bit black/white/red image by comparing the pixel luminance to a threshold (128).

#### `Future<void> sendImage(File? rawImage, int mtu, String deviceId)`

This method handles the process of sending an image via BLE, breaking it into chunks to fit the BLE MTU size.

- **Inputs**:
  - `File? rawImage`: The image file to be sent.
  - `int mtu`: The maximum transmission unit size for BLE communication.
  - `String deviceId`: The unique identifier for the target BLE device.
  
- **Output**:
  - Sends the image in chunks to the BLE device and updates progress.

**Steps**:
1. Clears the display on the connected BLE device.
2. Reads the image file and optionally converts it to black/white/red.
3. Compresses the image using the `compressionProvider`.
4. Splits the compressed image into chunks based on the BLE MTU.
5. Sends the chunks sequentially to the BLE device.
6. Sends start and end commands to indicate the transfer initiation and completion.
7. Refreshes the screen on the BLE device to display the transferred image.

#### `Future<void> sendRedImage(String deviceId)`

This method is used to send a predefined set of image data (currently hardcoded) representing a "red image" to the BLE device.

- **Input**:
  - `String deviceId`: The identifier of the BLE device.
  
- **Output**:
  - Sends the predefined image data in chunks and updates progress.

**Steps**:
1. Sends the start command.
2. Sends predefined chunks of image data (`data`, `data2`, etc.) to the BLE device.
3. Sends the end command.
4. Refreshes the BLE device’s display.

#### `Future<void> _clearDisplay(String deviceId)`

This method sends a command to clear the display on the BLE device.

- **Input**:
  - `String deviceId`: The BLE device identifier.

#### `Future<void> _sendCommand(List<int> command, String deviceId)`

Sends a specific command to the BLE device without waiting for a response.

- **Inputs**:
  - `List<int> command`: The byte command to be sent.
  - `String deviceId`: The BLE device identifier.

#### `Future<void> _sendChunk(List<int> chunk, String deviceId)`

Sends a chunk of data to the BLE device without waiting for a response.

- **Inputs**:
  - `List<int> chunk`: The data to be sent.
  - `String deviceId`: The BLE device identifier.

#### `Future<void> _refreshScreen(String deviceId)`

Sends a command to refresh the display on the BLE device after an image is transferred.

- **Input**:
  - `String deviceId`: The BLE device identifier.

---

## Usage Example

```dart
final ProgressService progressService = ProgressService();
final ImageService imageService = ImageService(progressService);

// File image to be sent
File image = File('path/to/image.jpg');
int mtu = 20;
String deviceId = 'device-identifier';

await imageService.sendImage(image, mtu, deviceId);
```

### Error Handling

- If any step in the process fails (e.g., image conversion, BLE communication), the service logs the error and rethrows the exception for further handling.
- The `sendImage` method catches exceptions during the image transfer process and logs them using the logger.

---

Voici la documentation pour les autres services associés à l'`ImageService`, en anglais et en format Markdown.

---

# ProgressService Documentation

## Overview

The `ProgressService` class is responsible for tracking and broadcasting the progress of tasks, particularly image upload or transfer processes. It uses a `StreamController` to allow listeners to monitor real-time progress updates.

## Key Features

- **Progress Tracking**: Updates and broadcasts progress using a `StreamController`.
- **Customizable Progress**: The service allows for progress updates based on the current step and total steps in a process.

---

## Class: `ProgressService`

### Constructor

```dart
ProgressService();
```

The constructor initializes the `StreamController` that will be used to broadcast progress updates.

### Fields

- **StreamController<int>**: This is the main controller for broadcasting progress updates. It sends integer values representing the percentage of progress (0-100%).

### Methods

#### `void updateProgress(int currentStep, int totalSteps)`

This method calculates the progress as a percentage based on the current step and the total steps and broadcasts the update to the listeners.

- **Input**:
  - `int currentStep`: The current step in the progress process.
  - `int totalSteps`: The total number of steps for the process.
  
- **Output**:
  - Broadcasts the progress as a percentage through the `StreamController`.

**Example**:

```dart
progressService.updateProgress(2, 5); // Updates progress to 40%
```

#### `Stream<int> get progressStream`

This getter returns the stream of progress updates, allowing listeners to subscribe and receive updates in real-time.

- **Output**:
  - A `Stream<int>` representing the current progress as a percentage.

**Example**:

```dart
progressService.progressStream.listen((progress) {
  print('Progress: $progress%');
});
```

---

## Usage Example

```dart
final ProgressService progressService = ProgressService();

// Listening to progress updates
progressService.progressStream.listen((progress) {
  print('Progress: $progress%');
});

// Updating the progress
progressService.updateProgress(3, 10); // Progress at 30%
```

### Error Handling

- The service doesn’t handle specific errors but relies on correct usage of progress updates. If incorrect values (e.g., totalSteps = 0) are passed, it may lead to division by zero errors, which should be handled at the application level.

---

# CompressionProvider Documentation

## Overview

The `CompressionProvider` class is responsible for compressing image data before it is sent over BLE. Compression reduces the size of the image, making it more efficient for transmission over limited bandwidth communication channels like BLE.

## Key Features

- **Efficient Compression**: Uses `ZLib` encoding to compress the image data.
- **Flexible Compression**: Converts the image data into a list of compressed bytes, which are easier to transfer in small chunks.

---

## Class: `CompressionProvider`

### Constructor

```dart
CompressionProvider();
```

The constructor initializes the encoder that will be used for compressing image data.

### Fields

- **encoder**: An instance of the `ZLibEncoder`, which is used to compress the image data before sending it over BLE.

### Methods

#### `List<int> compressData(List<int> imageData)`

This method compresses the raw image data into a compressed byte list, reducing the overall size for transmission.

- **Input**:
  - `List<int> imageData`: The raw image data as a list of bytes.
  
- **Output**:
  - A `List<int>` representing the compressed image data.

**Example**:

```dart
List<int> compressedData = compressionProvider.compressData(rawImageBytes);
```

---

## Usage Example

```dart
final CompressionProvider compressionProvider = CompressionProvider();

// Raw image bytes (List<int>)
List<int> rawImageBytes = ...;

// Compressing the data
List<int> compressedData = compressionProvider.compressData(rawImageBytes);
```

### Error Handling

- If the compression fails, it may throw an exception. Proper error handling should be implemented when compressing large or complex image files.

---

# BLE Compression Integration

The `ImageService` integrates the `CompressionProvider` and `ProgressService` for efficient image transmission via BLE. Below is an overview of how these components work together:

1. **Compression**: The raw image bytes are compressed using the `CompressionProvider`.
2. **Chunking and Transmission**: The compressed data is broken into chunks, each of which is sent to the BLE device.
3. **Progress Updates**: For every chunk sent, the `ProgressService` updates the progress, allowing real-time tracking of the transmission.

**Example Integration**:

```dart
final CompressionProvider compressionProvider = CompressionProvider();
final ProgressService progressService = ProgressService();
final ImageService imageService = ImageService(progressService);

File image = File('path/to/image.jpg');
int mtu = 20;
String deviceId = 'device-identifier';

await imageService.sendImage(image, mtu, deviceId);
```