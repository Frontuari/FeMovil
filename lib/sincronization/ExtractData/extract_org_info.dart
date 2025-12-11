import 'dart:convert';

import 'package:intl/intl.dart';

List<Map<String, dynamic>> extractORGInfo(String responseData) {
  Map<String, dynamic> parsedResponse = jsonDecode(responseData);

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
      dynamic getVal(String columnName, {dynamic defaultValue}) {
        final field = row['field'].firstWhere(
          (f) => f['@column'] == columnName,
          orElse: () => null,
        );

        if (field == null ||
            (field.containsKey('@nil') && field['@nil'] == 'true')) {
          return defaultValue;
        }
        return field['val'];
      }

      Map<String, dynamic> data = {
        'ad_org_id': getVal('AD_Org_ID', defaultValue: ''),
        'name': getVal('Name', defaultValue: ''),
        'address': getVal('org_address', defaultValue: ''),
        'ruc': getVal('TaxID', defaultValue: ''),



      };

      datas.add(data);
    }

    print("data mapeada $datas");
  } catch (e) {
    print("ESTE ES EL ERROR ExtractProductSelection $e");
  }

  return datas;
}
