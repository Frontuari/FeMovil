import 'dart:convert';

// Función para procesar la respuesta de iDempiere y extraer los datos de los productos
import 'dart:convert';

List<Map<String, dynamic>> extractCustomersData(String responseData) {
  print("data response $responseData");

  // Decodifica la respuesta JSON
  final Map<String, dynamic> parsedResponse = jsonDecode(responseData);

  // Verificación de integridad: abortar tempranamente si no hay registros
  if (parsedResponse['WindowTabData']['@NumRows'] == 0) {
    return [];
  }

  // Corrección de la estructura: Asegurar que DataRow se trate como Lista incluso si viene 1 solo registro
  List<dynamic> dataRows =
      parsedResponse['WindowTabData']['DataSet']['DataRow'] is Map
          ? [parsedResponse['WindowTabData']['DataSet']['DataRow']]
          : parsedResponse['WindowTabData']['DataSet']['DataRow'];

  List<Map<String, dynamic>> customersData = [];

  try {
    for (var row in dataRows) {
      
      // Función interna para blindar la extracción de cada nodo
      dynamic getVal(String columnName, {dynamic defaultValue}) {
        final field = row['field'].firstWhere(
          (f) => f['@column'] == columnName,
          orElse: () => null,
        );

        // Si la columna ni siquiera existe en este registro, devolvemos el valor por defecto
        if (field == null) return defaultValue;

        final val = field['val'];

        // Cazar y neutralizar los nulos explícitos de iDempiere ("@nil": true)
        if (val is Map && (val['@nil'] == true || val['@nil'] == 'true')) {
          return defaultValue;
        }
        
        // Limpiar strings vacíos que puedan causar ruido
        if (val is String && val.trim().isEmpty) {
          return defaultValue;
        }

        return val;
      }

      // Extracción limpia y segura garantizando tipos de datos predecibles
      Map<String, dynamic> customerData = {
        'c_bpartner_id': getVal('C_BPartner_ID', defaultValue: 0),
        'cod_client': getVal('Value', defaultValue: ''),
        'bp_name': getVal('BPName', defaultValue: ''),
        'c_bp_group_id': getVal('C_BP_Group_ID', defaultValue: 0),
        'group_bp_name': getVal('groupbpname', defaultValue: ''), 
        'lco_tax_id_typeid': getVal('LCO_TaxIdType_ID', defaultValue: 0),
        'tax_id_type_name': getVal('TaxIdTypeName', defaultValue: ''),
        'email': getVal('EMail', defaultValue: ''),
        'c_bpartner_location_id': getVal('C_BPartner_Location_ID', defaultValue: 0),
        'is_bill_to': getVal('IsBillTo', defaultValue: ''),
        'phone': getVal('Phone', defaultValue: ''),
        'c_location_id': getVal('C_Location_ID', defaultValue: 0),
        'city': getVal('City', defaultValue: ''),
        'region': getVal('RegionName', defaultValue: ''),
        'country': getVal('CountryName', defaultValue: ''),
        'code_postal': getVal('Postal', defaultValue: ''),
        'c_city_id': getVal('C_City_ID', defaultValue: 0),
        'c_region_id': getVal('C_Region_ID', defaultValue: 0),
        'c_country_id': getVal('C_Country_ID', defaultValue: 0),
        'ruc': getVal('TaxID', defaultValue: ''),
        'address': getVal('Address', defaultValue: ''), 
        'lco_tax_payer_typeid': getVal('LCO_TaxPayerType_ID', defaultValue: 0),
        'tax_payer_type_name': getVal('TaxPayerTypeName', defaultValue: ''),
      };

      customersData.add(customerData);
    }
  } catch (e) {
    // Un simple print en un try-catch general a veces oculta qué fila específica falló, 
    // pero al menos ahora la aplicación no sufrirá un fatal crash.
    print("❌ Error crítico procesando clientes del ERP: $e");
  }

  print("esto es customer data $customersData");

  return customersData;
}