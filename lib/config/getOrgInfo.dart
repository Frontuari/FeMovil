import 'dart:convert';
import 'dart:io';
import 'package:femovil/config/url.dart';
import 'package:femovil/presentation/perfil/perfil_http.dart';
import 'package:path_provider/path_provider.dart';

class Organization {
  String name;
  String ruc;

  Organization({
    required this.name, 
    required this.ruc
  });
}

getOrgInfo() async {
  HttpClient httpClient = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) {
      return true;
    };
  var map = await getRuta();

  final uri = Uri.parse('${map['URL']}ADInterface/services/rest/model_adservice/query_data');
  
  final request = await httpClient.postUrl(uri);
  final info = await getApplicationSupportDirectory();
    
  final String filePathEnv = '${info.path}/.env';
  final File archivo = File(filePathEnv);

  String contenidoActual = await archivo.readAsString();

  // Convierte el contenido JSON a un mapa
  Map<String, dynamic> jsonData = jsonDecode(contenidoActual);

  var role        = jsonData["RoleID"];
  var orgId       = jsonData["OrgID"];
  var clientId    = jsonData["ClientID"];
  var wareHouseId = jsonData["WarehouseID"];
  var language    = jsonData["Language"]; 

  Map<String, dynamic> userInfo = await getLogin();

  // Configurar el cuerpo de la solicitud en formato JSON
  final requestBody = {
    "ModelCRUDRequest": {
      "ModelCRUD": {
        "serviceType": "getOrgInfo",
        "DataRow": {
          "field": [
            {"@column": "AD_Org_ID", "val": orgId} 
          ]
        }
      },
      "ADLoginRequest": {
        "user": userInfo["user"],
        "pass": userInfo["password"],
        "lang": language,
        "ClientID": clientId,
        "RoleID": role,
        "OrgID": orgId,
        "WarehouseID": wareHouseId,
        "stage": 9
      }
    }
  };

  // Convertir el cuerpo a JSON
  final jsonBody = jsonEncode(requestBody);

  // Establecer las cabeceras de la solicitud
  request.headers.set('Content-Type', 'application/json');
  request.headers.set('Accept', 'application/json');

  // Escribir el cuerpo en la solicitud
  request.write(jsonBody);

  final response = await request.close();

  Map<String, dynamic> result = {};
  if (response.statusCode == 200) {
    dynamic responseBody  = await response.transform(utf8.decoder).join();
    Map parsedJson = jsonDecode(responseBody);

    // print('parsed json: ${parsedJson}');

    if (parsedJson['WindowTabData']['@NumRows'] > 0)
    {
      result = {
        'name'   : parsedJson['WindowTabData']['DataSet']['DataRow']['field'][0]['val'].toString(), 
        'ruc'    : parsedJson['WindowTabData']['DataSet']['DataRow']['field'][1]['val'].toString(),
        'address': parsedJson['WindowTabData']['DataSet']['DataRow']['field'][2]['val'].toString(),
      };
    } 
  }

  print('Data org info: $result');

  return result;
}