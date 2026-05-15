import 'dart:convert';

// Función para procesar la respuesta de iDempiere y extraer los datos de los productos
List<Map<String, dynamic>> extractVendorsData(String responseData) {
  print("data response $responseData");

  final Map<String, dynamic> parsedResponse = jsonDecode(responseData);

  // Verificación temprana: Si no hay filas, retornamos la lista vacía inmediatamente.
  if (parsedResponse['WindowTabData']['@NumRows'] == 0) {
    return [];
  }

  // Corrección crítica: Normalización de DataRow a Lista para evitar crashes cuando solo viene 1 registro
  List<dynamic> dataRows =
      parsedResponse['WindowTabData']['DataSet']['DataRow'] is Map
          ? [parsedResponse['WindowTabData']['DataSet']['DataRow']]
          : parsedResponse['WindowTabData']['DataSet']['DataRow'];

  List<Map<String, dynamic>> vendorsData = [];

  try {
    for (var row in dataRows) {
      
      // Función de extracción segura
      dynamic getVal(String columnName, {dynamic defaultValue}) {
        final field = row['field'].firstWhere(
          (f) => f['@column'] == columnName,
          orElse: () => null,
        );

        if (field == null) return defaultValue;

        final val = field['val'];

        // Validar si val es objeto con @nil = true o string vacío
        if (val is Map && (val['@nil'] == true || val['@nil'] == 'true')) {
          return defaultValue;
        }
        if (val is String && val.trim().isEmpty) {
          return defaultValue;
        }

        return val;
      }

      // Mapeo riguroso con valores por defecto acordes al tipo de dato esperado
      Map<String, dynamic> vendorsDatas = {
        'c_bpartner_id': getVal('C_BPartner_ID', defaultValue: 0),
        'c_code_id': getVal('Value', defaultValue: ''),
        'bpname': getVal('BPName', defaultValue: ''),
        'email': getVal('EMail', defaultValue: ''),
        'c_bp_group_id': getVal('C_BP_Group_ID', defaultValue: 0),
        'groupbpname': getVal('groupbpname', defaultValue: ''), // Nota: Verifica si en el ERP es 'GroupBPName' o 'groupbpname'
        'tax_id': getVal('TaxID', defaultValue: ''),
        'is_vendor': getVal('IsVendor', defaultValue: ''),
        'lco_tax_id_type_id': getVal('LCO_TaxIdType_ID', defaultValue: 0),
        'tax_id_type_name': getVal('TaxIdTypeName', defaultValue: ''),
        'c_bpartner_location_id': getVal('C_BPartner_Location_ID', defaultValue: 0),
        'is_bill_to': getVal('IsBillTo', defaultValue: ''),
        'phone': getVal('Phone', defaultValue: ''),
        'c_location_id': getVal('C_Location_ID', defaultValue: 0),
        'address': getVal('Address1', defaultValue: ''),
        'city': getVal('City', defaultValue: ''),
        'country_name': getVal('CountryName', defaultValue: ''),
        'postal': getVal('Postal', defaultValue: ''),
        'c_city_id': getVal('C_City_ID', defaultValue: 0),
        'c_country_id': getVal('C_Country_ID', defaultValue: 0),
        'lco_taxt_payer_type_id': getVal('LCO_TaxPayerType_ID', defaultValue: 0),
        'tax_payer_type_name': getVal('TaxPayerTypeName', defaultValue: ''),
      };

      vendorsData.add(vendorsDatas);
    }
  } catch (e) {
    print("❌ Error procesando proveedores del ERP: $e");
  }

  print("esto es vendorData $vendorsData");

  return vendorsData;
}