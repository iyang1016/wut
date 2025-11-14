import 'package:flutter/material.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:io';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> devices = [];
  bool isScanning = false;

  void _scanNetwork() async {
    setState(() {
      isScanning = true;
      devices = [];
    });

    final scanner = LanScanner();
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();

    if (wifiIP != null) {
      final subnet = wifiIP.substring(0, wifiIP.lastIndexOf('.'));
      final stream = scanner.icmpScan(
        subnet,
        progressCallback: (progress) {
          // You can update the UI with the progress if you want
        },
      );

      stream.listen((Host host) {
        setState(() {
          devices.add(host.internetAddress.address);
        });
      });
    }

    setState(() {
      isScanning = false;
    });
  }

  void _disconnectDevice(String ip) async {
    await Process.run('./NetWarden/NetWarden.Tui/bin/Release/net8.0/linux-x64/publish/NetWarden.Tui', ['kill', ip]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NetShaper'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _scanNetwork,
              child: const Text('Scan Network'),
            ),
          ),
          if (isScanning)
            const Center(
              child: CircularProgressIndicator(),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(devices[index]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.signal_wifi_off),
                          onPressed: () {
                            _disconnectDevice(devices[index]);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.network_check),
                          onPressed: () {
                            // Bandwidth limit functionality
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.speed),
                          onPressed: () {
                            // Speed limit functionality
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
