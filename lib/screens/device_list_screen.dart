import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:async';

void main() {
  runApp(DeviceListScreen());
}

class DeviceListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BLEConnectionScreen(),
    );
  }
}

class BLEConnectionScreen extends StatefulWidget {
  @override
  _BLEConnectionScreenState createState() => _BLEConnectionScreenState();
}

class _BLEConnectionScreenState extends State<BLEConnectionScreen> {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  late StreamSubscription<DiscoveredDevice> _scanSubscription;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  final Set<DiscoveredDevice> _devices = {};
  DiscoveredDevice? _connectedDevice;
  bool _isScanning = false;

  @override
  void dispose() {
    _scanSubscription.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }
  // Fonction pour démarrer le scan
  void _startScan() {
    setState(() {
      _devices.clear();
      _isScanning = true;
    });

    // Commencer à scanner les appareils
    _scanSubscription = _ble.scanForDevices(withServices: []).listen((device) {
      // Ici, vous pouvez accéder aux données du fabricant
      final manufacturerData = device.manufacturerData;

      // Vérifiez si des données du fabricant sont présentes
      if (manufacturerData.isNotEmpty) {
        if(manufacturerData.length >= 10) {
          print("Appareil trouvé: $device, Batterie data: ${device.manufacturerData[6]}");
        }
      }
      // Ajouter l'appareil à la liste
      setState(() {
        _devices.add(device);
      });
    }, onError: (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur pendant le scan: $error')),
      );
    });

    // Arrêter le scan après 10 secondes
    Future.delayed(Duration(seconds: 10), () {
      _stopScan();
      if (_devices.isEmpty) { // S'il n'y a auncun appareil trouvé alors afficher un message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aucun résultat trouvé')),
        );
      } else {
        _showDeviceModal(context); // Afficher les appareils trouvés dans une modal
      }
    });
  }

  // Fonction pour arrêter le scan
  void _stopScan() {
    _scanSubscription.cancel();
    setState(() {
      _isScanning = false;
    });
  }

  // Fonction pour se connecter à un appareil
  void _connectToDevice(DiscoveredDevice device) {
    _connectionSubscription?.cancel();
    _connectionSubscription = _ble.connectToDevice(id: device.id).listen(
      (connectionState) {
        if (connectionState.connectionState == DeviceConnectionState.connected) {
          setState(() {
            _connectedDevice = device;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${device.name} est maintenant connecté")),
          );
        } else if (connectionState.connectionState == DeviceConnectionState.disconnected) {
          setState(() {
            _connectedDevice = null;
          });
          ScaffoldMessenger.of(context).showSnackBar( // Afficher un message si l'appareil est déconnecté
            SnackBar(content: Text("${device.name} a été déconnecté")),
          );
        }
      },
      onError: (error) { // Afficher un message d'erreur si la connexion échoue
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de connexion: $error')),
        );
      },
    );
  }

  // Fonction pour afficher les appareils trouvés dans une modal
  void _showDeviceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: _devices.length,
          itemBuilder: (context, index) {
            final device = _devices.elementAt(index);
            return ListTile(
              title: Text(device.name.isEmpty ? "Appareil inconnu" : device.name),
              subtitle: Text(device.id),
              onTap: () => _connectToDevice(device),
            );
          },
        );
      },
    );
  }

  // Fonction pour afficher les informations de l'appareil dans une modal
  // à revoir pas fonctionnel pour le moment
  void _showDeviceInfoModal(BuildContext context, List<Map<String, String>> characteristicValues) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Informations sur l\'appareil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: characteristicValues.map((entry) {
                return Text("${entry['name']}: ${entry['value']}");
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la modal
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  // Fonstrion pour construire l'interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connexion BLE'),
      ),
      body: Center( // Afficher les boutons pour scanner et afficher les appareils
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isScanning ? null : _startScan,
              child: Text(_isScanning ? "Scan en cours..." : "Scanner les appareils BLE"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_connectedDevice != null) {
                  _showDeviceInfoModal(context, []); // Aucune info à afficher si déconnecté
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Aucun appareil connecté")),
                  );
                }
              },
              child: Text(_connectedDevice == null
                  ? "Aucun appareil connecté"
                  : "Voir les infos de: ${_connectedDevice!.name}"),
            ),
          ],
        ),
      ),
    );
  }
}