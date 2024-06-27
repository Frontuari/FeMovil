import 'dart:convert';

// Función para procesar la respuesta de iDempiere y extraer los datos de los productos
List<Map<String, dynamic>> extractVendorsData(String responseData) {
  // Decodifica la respuesta JSON
  Map<String, dynamic> parsedResponse = jsonDecode(responseData);

  // Extrae la lista de DataRow de la respuesta
  List<dynamic> dataRows = parsedResponse['WindowTabData']['DataSet']['DataRow'];

  // Crea una lista para almacenar los datos de los productos
  List<Map<String, dynamic>> vendorsData = [];

  print('Esto es la respuesta del erp proveedores $dataRows');

  // Itera sobre cada DataRow y extrae los datos relevantes de los productos

try {

  
  
  for (var row in dataRows) {
    Map<String, dynamic> vendorsDatas = {
      'c_bpartner_id': row['field'].firstWhere((field) => field['@column'] == 'C_BPartner_ID')['val'],
      'c_code_id': row['field'].firstWhere((field) => field['@column'] == 'Value')['val'],
      'bpname': row['field'].firstWhere((field) => field['@column'] == 'BPName')['val'],
      'email': row['field'].firstWhere((field) => field['@column'] == 'EMail')['val'],
      'c_bp_group_id': row['field'].firstWhere((field) => field['@column'] == 'C_BP_Group_ID')['val'],
      'groupbpname':row['field'].firstWhere((field) => field['@column'] == 'groupbpname')['val'],
      'tax_id': row['field'].firstWhere((field) => field['@column'] == 'TaxID')['val'],
      'is_vendor': row['field'].firstWhere((field) => field['@column'] == 'IsVendor')['val'],
      'lco_tax_id_type_id': row['field'].firstWhere((field) => field['@column'] == 'LCO_TaxIdType_ID')['val'],
      'tax_id_type_name':row['field'].firstWhere((field) => field['@column'] == 'TaxIdTypeName')['val'],
      'c_bpartner_location_id': row['field'].firstWhere((field) => field['@column'] == 'C_BPartner_Location_ID')['val'],
      'is_bill_to': row['field'].firstWhere((field) => field['@column'] == 'IsBillTo')['val'],
      'phone': row['field'].firstWhere((field) => field['@column'] == 'Phone')['val'],
      'c_location_id': row['field'].firstWhere((field) => field['@column'] == 'C_Location_ID')['val'],
      'address': row['field'].firstWhere((field) => field['@column'] == 'Address1')['val'],
      'city': row['field'].firstWhere((field) => field['@column'] == 'City')['val'],
      'country_name': row['field'].firstWhere((field) => field['@column'] == 'CountryName')['val'],
      'postal': row['field'].firstWhere((field) => field['@column'] == 'Postal')['val'],
      'c_city_id': row['field'].firstWhere((field) => field['@column'] == 'C_City_ID')['val'],
      'c_country_id': row['field'].firstWhere((field) => field['@column'] == 'C_Country_ID')['val'],
      'lco_taxt_payer_type_id': row['field'].firstWhere((field) => field['@column'] == 'LCO_TaxPayerType_ID')['val'],
      'tax_payer_type_name': row['field'].firstWhere((field) => field['@column'] == 'TaxPayerTypeName')['val'],
      // 'lve_person_type_id': row['field'][22]['val'],
      // 'person_type_name': row['field'][23]['val'],

     // Asegúrate de convertir la cantidad a un tipo numérico adecuado
      // Añade otros campos que necesites sincronizar
    };


    // print('Esto es tax payer type ${row['field'][26]['val']}');
         
             
    // Agrega los datos del producto a la lista
    vendorsData.add(vendorsDatas);
  }
} catch (e) {

  print("ESTE ES EL ERROR $e");
  
}

  print("esto es vendorData $vendorsData");

  return vendorsData;
}