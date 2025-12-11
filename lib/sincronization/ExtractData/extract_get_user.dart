import 'dart:convert';
import 'package:intl/intl.dart';

List<Map<String, dynamic>> extractGetUser(dynamic responseData) {
  Map<String, dynamic> parsedResponse = jsonDecode(responseData);

  print('Data Response en extract get user $parsedResponse');

  if (parsedResponse['WindowTabData']['@NumRows'] == 0) {
    return [];
  }

  List<dynamic> dataRows =
      parsedResponse['WindowTabData']['DataSet']['DataRow'] is Map
          ? [parsedResponse['WindowTabData']['DataSet']['DataRow']]
          : parsedResponse['WindowTabData']['DataSet']['DataRow'];

  List<Map<String, dynamic>> datas = [];

  print('Esto es la respuesta del extractLocation $dataRows');

          try {
            for (var row in dataRows) {
              // 🔥 Función robusta para extraer valores
              dynamic getVal(String columnName, {dynamic defaultValue = ''}) {
          final field = row['field'].firstWhere(
            (f) => f['@column'] == columnName,
            orElse: () => null,
          );

          // Si no existe el campo → vacío
          if (field == null) return defaultValue;

          // Si no tiene 'val' → vacío
          if (!field.containsKey('val')) return defaultValue;

          final val = field['val'];

          // Si val es un Map y contiene @nil → vacío
          if (val is Map && val.containsKey('@nil') &&
              (val['@nil'] == true || val['@nil'] == 'true')) {
            return defaultValue;
          }

          return val;
        }

      Map<String, dynamic> data = {
        'name': getVal('Name'),
        'ad_user_id': getVal('AD_User_ID'),
        'password': getVal('Description'),
        'email': getVal('EMail'),
        'phone': getVal('Phone'),
        'description': getVal('Description'),
      };

      datas.add(data);
    }

    print("data mapeadaDataExtraida $datas");
  } catch (e) {
    print("ESTE ES EL ERROR ExtractProductSelection $e");
  }

  return datas;
}
