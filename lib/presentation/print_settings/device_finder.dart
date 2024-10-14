import 'package:femovil/config/app_bar_femovil.dart';
import 'package:bluetooth_print/bluetooth_print.dart'; 
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';

class DeviceFinder extends StatefulWidget {
  const DeviceFinder({ super.key });

  @override
  State<DeviceFinder> createState() => _DeviceFinderState();
}

class _DeviceFinderState extends State<DeviceFinder> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  BluetoothDevice? _device;
  bool _connected = false;
  String _message = 'No hay dispositivos disponibles';
   
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => searchDevices());
  }

  void searchDevices() {
    bluetoothPrint.startScan(timeout: Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    final screenMaxWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(170), 
        child: AppBars(labelText: 'Dispositivos')
      ),
      body: Align(
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Estatus: ', style: TextStyle(fontFamily: 'Poppins Semibold')),
                  Flexible(child: Text(_connected ? 'Conectado' : 'Desconectado', style: TextStyle(fontFamily: 'Poppins Regular')))
                ],
              ),
              const SizedBox(height: 20),

              StreamBuilder<List<BluetoothDevice>>(
                stream: bluetoothPrint.scanResults,
                initialData: const [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!.map((d) => ListTile(
                    title: Text(d.name ?? '', style: TextStyle(fontFamily: 'Poppins Semibold')),
                    subtitle: Text(d.address ?? '', style: TextStyle(fontFamily: 'Poppins Regular')),
                    onTap: () async {
                      await bluetoothPrint.connect(d);

                      bool isConnected = await bluetoothPrint.isConnected ?? false;

                      if (isConnected) {
                        setState(() {
                          _connected  = true;
                          _message    = 'Se conecto exitosamente';
                          _device     = d;
                        });
                      }
                    },
                    trailing: _device!=null && _device!.address == d.address ? Icon(Icons.check, color: Colors.green) : null,
                  )).toList(),
                ),
              ),
            ]
          )
        ),
      ),
    );
  }
}