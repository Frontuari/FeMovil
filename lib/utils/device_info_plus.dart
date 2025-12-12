import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

Future<Map<String, String>> getDeviceInfo() async {
  final deviceInfoPlugin = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final androidInfo = await deviceInfoPlugin.androidInfo;
    return {
      'modelo': androidInfo.model ?? '',
      'fabricante': androidInfo.manufacturer ?? '',
      'version': androidInfo.version.release ?? '',
      'descripcion': '${androidInfo.manufacturer} ${androidInfo.model} (Android ${androidInfo.version.release})',
    };
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfoPlugin.iosInfo;
    return {
      'modelo': iosInfo.utsname.machine ?? '',
      'nombre': iosInfo.name ?? '',
      'version': iosInfo.systemVersion ?? '',
      'descripcion': '${iosInfo.name} ${iosInfo.utsname.machine} (iOS ${iosInfo.systemVersion})',
    };
  }

  return {
    'descripcion': 'Plataforma no soportada'
  };
}
