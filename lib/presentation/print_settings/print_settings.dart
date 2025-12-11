import 'package:femovil/config/app_bar_femovil.dart';
import 'package:femovil/presentation/print_settings/device_finder.dart';
import 'package:flutter/material.dart';

class PrintSettings extends StatefulWidget {
  const PrintSettings({super.key});

  @override
  State<PrintSettings> createState() => _PrintSettingsState();
}

class _PrintSettingsState extends State<PrintSettings> {
  @override
  Widget build(BuildContext context) {
    final screenMaxWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(170),
        child: AppBars(labelText: 'Ajustes de Impresión'),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: screenMaxWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
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
                  ),
                ),
                const SizedBox(height: 5),

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
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}