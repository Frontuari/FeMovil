import 'package:femovil/config/app_bar_femovil.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:femovil/presentation/print_settings/device_finder.dart';
import 'package:flutter/material.dart';

class PrintSettings extends StatefulWidget {
  const PrintSettings({ super.key });

  @override
  State<PrintSettings> createState() => _PrintSettingsState();
}

class _PrintSettingsState extends State<PrintSettings> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  bool _connected = false;
  String tips = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  } 

  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 4));

    bool isConnected=await bluetoothPrint.isConnected??false;

    bluetoothPrint.state.listen((state) {
      print('******************* cur device status: $state');

      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'connect success';
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'disconnect success';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if(isConnected) {
      setState(() {
        _connected=true;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final screenMaxWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(170), 
        child: AppBars(labelText: 'Ajustes de Impresión')
      ),
      body: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: screenMaxWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                /// const SizedBox(height: 20),
                const Text('Bluetooth', style: TextStyle(fontFamily: 'Poppins Semibold')),
                const SizedBox(height: 10),

                SizedBox(
                  width: screenMaxWidth,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff7531FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const DeviceFinder()));
                    },
                    child: const Text('Buscar Dispositivos', style: TextStyle(fontFamily: 'Poppins SemiBold')),
                  )
                ),
                SizedBox(height: 5),

                SizedBox(
                  width: screenMaxWidth,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff7531FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Probar Impresora', style: TextStyle(fontFamily: 'Poppins SemiBold')),
                  )
                ),
                SizedBox(height: 5),
              ],
            )
          ),
        ),
      ),
    );
  }
}