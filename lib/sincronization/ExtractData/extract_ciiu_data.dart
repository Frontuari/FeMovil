import 'dart:convert';

List<Map<String, dynamic>> extractCiiuActivitiesData(String responseData) {

  Map<String, dynamic> parsedResponse = jsonDecode(responseData);

  // Primero valida si tiene registros
  if(parsedResponse['WindowTabData']['@NumRows'] == 0){
    return [];
  }

  // Extrae DataSet
  var dataSet = parsedResponse['WindowTabData']['DataSet'];

  // Si DataSet es vacío → no hay nada que devolver
  if(dataSet is String || dataSet == null) {
    return [];
  }

  // Prepara DataRow para ser siempre una lista
  List<dynamic> dataRows = dataSet['DataRow'] is Map ? [dataSet['DataRow']]: dataSet['DataRow'];

  List<Map<String, dynamic>> ciiuActivitiesData = [];

  try {

    for (var row in dataRows) {
      Map<String, dynamic> ciiuActivityData = {
        'cod_ciiu': row['field']
            .firstWhere((field) => field['@column'] == 'Value')['val'],
        'lco_isic_id': row['field']
            .firstWhere((field) => field['@column'] == 'LCO_ISIC_ID')['val'],
        'name': row['field']
            .firstWhere((field) => field['@column'] == 'Name')['val'],
      };

      ciiuActivitiesData.add(ciiuActivityData);
    }

  } catch (e) {
    print("ESTE ES EL ERROR $e");
  }

  print("Esto son las actividades comerciales $ciiuActivitiesData");

  return ciiuActivitiesData;
}
