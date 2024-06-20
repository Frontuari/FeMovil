import 'dart:convert';


List<Map<String, dynamic>> extractCiiuActivitiesData(String responseData) {

  Map<String, dynamic> parsedResponse = jsonDecode(responseData);

  List<dynamic> dataRows = parsedResponse['WindowTabData']['DataSet']['DataRow'];

  List<Map<String, dynamic>> ciiuActivitiesData = [];

  print('Esto es la respuesta de los ciiu activities $dataRows');


try {

  
  
  for (var row in dataRows) {

      print('Estos son los rows $row');

    Map<String, dynamic> ciiuActivityData = {
      'cod_ciiu': row['field'].firstWhere((field) => field['@column'] == 'Value')['val'],
      'lco_isic_id': row['field'].firstWhere((field) => field['@column'] == 'LCO_ISIC_ID')['val'],
      'name': row['field'].firstWhere((field) => field['@column'] == 'Name')['val'],
   


    };

    ciiuActivitiesData.add(ciiuActivityData);
  }
} catch (e) {

  print("ESTE ES EL ERROR $e");
  
}

  print("Estos son las actividades comerciales del proveedor disponibles desde idempiere $ciiuActivitiesData");

  return ciiuActivitiesData;
}