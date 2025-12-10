import 'dart:convert';
import 'dart:io';

// import 'package:sales_force/config/url.dart';
// import 'package:sales_force/presentation/perfil/perfil_http.dart';

import 'package:femovil/config/url.dart';
import 'package:femovil/presentation/perfil/perfil_http.dart';
import 'package:femovil/sincronization/ExtractData/extract_org_info.dart';
import 'package:femovil/sincronization/sincronizar.dart';
import 'package:path_provider/path_provider.dart';


Future<dynamic> sincronizationOrgInfo() async {
  try {
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    var map = await getRuta();
    var variablesLogin = await getLogin();
    final uri = Uri.parse(
        '${map['URL']}ADInterface/services/rest/model_adservice/query_data');
    final request = await httpClient.postUrl(uri);

    final info = await getApplicationSupportDirectory();
    print("esta es la ruta ${info.path}");

    final String filePathEnv = '${info.path}/.env';
    final File archivo = File(filePathEnv);
    String contenidoActual = await archivo.readAsString();
    print('Contenido actual del archivo:\n$contenidoActual');
    Map<String, dynamic> jsonData = jsonDecode(contenidoActual);

    var role = jsonData["RoleID"];
    var orgId = jsonData["OrgID"];
    var clientId = jsonData["ClientID"];
    var wareHouseId = jsonData["WarehouseID"];
    var language = jsonData["Language"];

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
          "user": variablesLogin['user'],
          "pass": variablesLogin['password'],
          "lang": language,
          "ClientID": clientId,
          "RoleID": role,
          "OrgID": orgId,
          "WarehouseID": wareHouseId,
          "stage": 9
        },
      }
    };

    final jsonBody = jsonEncode(requestBody);
    request.headers.set('Content-Type', 'application/json; charset=utf-8');
    request.headers.set('Accept', 'application/json');
    request.write(jsonBody);

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    final parsedResponse = jsonDecode(responseBody);

    print('Productos Sugeridos $parsedResponse');

    // await handleApiResponse(
    //   parsedResponse,
    //   responseBody,
    //   requestBody,
    //   logFile: "get_suggeste_products.dart",
    // );

    dynamic dataExtract = extractORGInfo(responseBody);

    print('Productos Sugeridos Extraidos$dataExtract');

      await syncOrgInfo(dataExtract);

    // Verifica que bankAccount no esté vacío o nulo

    return dataExtract;
  } catch (e, stackTrace) {
    print('❌ Error en fetchBanksCas: $e');
    print('📍 StackTrace: $stackTrace');
    return false;
  }
}
