import 'dart:io';
import 'dart:convert';
import 'package:femovil/config/get_users.dart';
import 'package:femovil/database/insert_database.dart';
import 'package:femovil/sincronization/ExtractData/extract_get_user.dart';
import 'package:path_provider/path_provider.dart';


class AuthenticationService {
  bool isAuthenticated = false; // Inicialmente, el usuario no está autenticado.

  Future login({required String username, required String password}) async {
    dynamic response;
    dynamic result;
    try {
      final info = await getApplicationSupportDirectory();
      final String filePath = '${info.path}/.login.json';
      final File configFile = File(filePath);
      print('Esto es temporal $info');

    
      result = await getUsersNew(username, password);

      response = result["response"];
      final responseBody = result["responseBody"];
      final parsedJson = result["json"];
      final dataLogin = result["dataLogin"];


      if (response.statusCode == 200) {

           final windowTabData = parsedJson['WindowTabData'];
        print('esto es el windowTabData $windowTabData');

        // String windowTabData = responseBody;

        if (windowTabData['@NumRows'] == 1 &&
            windowTabData['Success'] == true) {
          isAuthenticated = true; // Usuario autenticado.

          final Map<String, dynamic> jsonData = {
            "user": username,
            "password": password,
            "auth": true,
            "userId": windowTabData['DataSet']['DataRow']['field'][0]['val'],
          };
          print('este es el json data $jsonData');
          final String newContent = json.encode(jsonData);
          await configFile.writeAsString(newContent);
          //El Endpoint es  'getUser'
          dynamic dataExtractUser =  extractGetUser(responseBody);

          print('Data ExtractUser $dataExtractUser');
          print('Data Login $dataLogin');

          Map<String, dynamic> user = {
            "name": dataLogin["Username"],
            "password": dataLogin["Password"],
            "ad_user_id": dataExtractUser[0]['ad_user_id'],
            "email": dataExtractUser[0]['email'],
            "phone": dataExtractUser[0]['phone'],
            "client_id": dataLogin["ClientID"],
            "org_id": dataLogin["OrgID"],
            "role_id": dataLogin["RoleID"],
            "warehouse_id": dataLogin["WarehouseID"],
            "languaje": dataLogin["Language"].toString(),
            "username": dataLogin["Username"],
            "description": dataExtractUser[0]['description'],

          };
          print('esto es el user a insertar $user');

          await insertUser(user);
        print('Exitosomente insertado en la base de datos local.');

          return true; // Inicio de sesión exitoso.
        } else {
          isAuthenticated = false;
          final Map<String, dynamic> jsonData = {
            "user": username,
            "password": password,
            "auth": false,
          }; // Usuario o contraseña incorrectos.

          final String newContent = json.encode(jsonData);
          await configFile.writeAsString(newContent);

          return false;
        }
      } else {
        // La solicitud falló con un código de estado diferente de 200.
        print('Error en la solicitud: ${response.statusCode}');

        return "No se encontro datos de registros de usuario";
      }
    } catch (e) {
      print("este es el error de login $e");
      print('esto es el user $username && password $password');
      //response = await getUserByLogin(username, password);

      print('Esto es la respuesta del user $response');
      if (response is! Map<String, dynamic>) {
        // No se pudo obtener una respuesta válida ni de la red ni de la base de datos local
        return "hay problemas con el internet";
      }

      if (response['name'] == username && response['password'] == password) {
        // Usuario autenticado
        final info = await getApplicationSupportDirectory();
        final String filePath = '${info.path}/.login.json';
        final File configFile = File(filePath);
        final Map<String, dynamic> jsonData = {
          "user": username,
          "password": password,
          "auth": true,
          "userId": response['ad_user_id'],
        }; // Usuario o contraseña incorrectos.

        final String newContent = json.encode(jsonData);
        await configFile.writeAsString(newContent);
        isAuthenticated = true;

        // Resto del código...
        return true;
      }

      print(
          'Error en la solicitud: ${e.toString().contains("Cannot open file")}');
      if (e.toString().contains('SocketException') ||
          e.toString().contains("No host specified")) {
        return "hay problemas con el internet";
      } else if (e.toString().contains("Cannot open file")) {
        return "No se encontro datos de registros de usuario";
      } else {
        print("Este es el error al loguearse: $e");
      }
    }
  }

  void logout() async {
    try {
      final info = await getApplicationSupportDirectory();
      final String filePath = '${info.path}/.login.json';
      final File configFile = File(filePath);

      // Lee el contenido actual del archivo JSON
      String contenidoActual = await configFile.readAsString();

      // Convierte el contenido JSON a un mapa
      Map<String, dynamic> jsonData = jsonDecode(contenidoActual);

      // Realiza las modificaciones necesarias en los datos
      jsonData["user"] = '';
      jsonData["password"] = '';
      jsonData["auth"] = false;

      // Convierte el mapa actualizado a formato JSON
      String newContent = jsonEncode(jsonData);

      // Vuelve a escribir el contenido actualizado en el archivo JSON
      await configFile.writeAsString(newContent);

      // Resto del código...
      isAuthenticated = false;

      // ... (otros cambios necesarios)
    } catch (error) {
      print('Error en la función logout: $error');
      // Manejo de errores...
    }
  }
}