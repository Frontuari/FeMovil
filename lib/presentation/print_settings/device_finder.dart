import 'package:femovil/config/app_bar_femovil.dart';
import 'package:bluetooth_print_plus/bluetooth_print_plus.dart' hide Alignment; 
import 'package:flutter/material.dart';

class DeviceFinder extends StatefulWidget {
  const DeviceFinder({super.key});

  @override
  State<DeviceFinder> createState() => _DeviceFinderState();
}

class _DeviceFinderState extends State<DeviceFinder> {
  
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;
  bool _connecting = false;
  String _message = 'No hay dispositivos disponibles';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => searchDevices());
  }

  void searchDevices() async {
    setState(() {
      _connecting = true;
      _devices = []; 
    });

    print('🔍 DEBUG: Iniciando escaneo...'); // Debug inicio

    await BluetoothPrintPlus.startScan(timeout: const Duration(seconds: 4));

    if (!mounted) return;

    BluetoothPrintPlus.scanResults.listen((result) {
      if (!mounted) return;

      // --- ZONA DE DEBUG ---
      print('🔍 DEBUG: Stream recibió datos. Cantidad raw: ${result.length}');
      for (var d in result) {
         print('   👉 Dispositivo detectado: Nombre="${d.name}", Mac="${d.address}", Tipo=${d.type}');
      }
      // ---------------------

      setState(() {
        // Aquí filtramos. Si tu impresora no tiene nombre, la estamos borrando aquí.
        _devices = result.where((d) => d.name != null && d.name!.isNotEmpty).toList();
        
        print('🔍 DEBUG: Dispositivos visibles tras filtro: ${_devices.length}');
      });
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        print('🔍 DEBUG: Tiempo de escaneo finalizado.');
        setState(() {
          _connecting = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenMaxWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(170),
        child: AppBars(labelText: 'Dispositivos'),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: screenMaxWidth, 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  !_connecting
                      ? const Text('Estatus: ', style: TextStyle(fontFamily: 'Poppins Semibold'))
                      : const SizedBox(),
                  Flexible(
                    child: Text(
                      _connecting
                          ? 'Buscando dispositivos...'
                          : (_connected ? 'Conectado' : 'Desconectado'),
                      style: const TextStyle(fontFamily: 'Poppins Regular'),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),

              Expanded(
                child: _devices.isNotEmpty
                    ? ListView.builder(
                        itemCount: _devices.length,
                        itemBuilder: (BuildContext c, int i) {
                          return ListTile(
                            leading: const Icon(Icons.print),
                            title: Text(_devices[i].name ?? 'Desconocido',
                                style: const TextStyle(fontFamily: 'Poppins Semibold')),
                            subtitle: Text(_devices[i].address ?? '',
                                style: const TextStyle(fontFamily: 'Poppins Regular')),
                            trailing: _device != null && _device!.address == _devices[i].address
                                ? const Icon(Icons.check, color: Colors.green)
                                : null,
                            onTap: () async {
                              print('🔍 DEBUG: Intentando conectar a ${_devices[i].name}...');
                              
                              await BluetoothPrintPlus.stopScan(); 
                              
                              await BluetoothPrintPlus.connect(_devices[i]);
                              
                              // Verificamos conexión de forma segura
                              bool isConnected = false;
                              try {
                                isConnected = await BluetoothPrintPlus.isConnected ?? false;
                              } catch (e) {
                                print('❌ ERROR al verificar conexión: $e');
                              }

                              print('🔍 DEBUG: Resultado de conexión: $isConnected');

                              if (isConnected && mounted) {
                                setState(() {
                                  _connected = true;
                                  _message = 'Se conectó exitosamente';
                                  _device = _devices[i];
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(content: Text(_message))
                                );
                              }
                            },
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          !_connecting ? 'No se encontraron dispositivos' : '',
                          style: const TextStyle(fontFamily: 'Poppins Regular'),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}