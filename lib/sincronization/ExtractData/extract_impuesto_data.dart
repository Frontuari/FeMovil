import 'dart:convert';

// Función para procesar la respuesta de iDempiere y extraer los datos de los productos
import 'dart:convert';

List<Map<String, dynamic>> extractImpuestoData(String responseData) {
  print("data response $responseData");

  // Decodifica la respuesta JSON
  final Map<String, dynamic> parsedResponse = jsonDecode(responseData);

  // Verificación temprana: Si la consulta no trae impuestos, salimos de inmediato
  if (parsedResponse['WindowTabData']['@NumRows'] == 0) {
    return [];
  }

  // Normalización crítica de DataRow: Convertimos a lista en caso de que venga 1 solo registro (Map)
  List<dynamic> dataRows =
      parsedResponse['WindowTabData']['DataSet']['DataRow'] is Map
          ? [parsedResponse['WindowTabData']['DataSet']['DataRow']]
          : parsedResponse['WindowTabData']['DataSet']['DataRow'];

  List<Map<String, dynamic>> impuestosData = [];

  try {
    for (var row in dataRows) {
      
      // Función interna de extracción defensiva
      dynamic getVal(String columnName, {dynamic defaultValue}) {
        final field = row['field'].firstWhere(
          (f) => f['@column'] == columnName,
          orElse: () => null,
        );

        if (field == null) return defaultValue;

        final val = field['val'];

        // Neutralizar el @nil explícito de iDempiere
        if (val is Map && (val['@nil'] == true || val['@nil'] == 'true')) {
          return defaultValue;
        }
        
        // Evitar strings vacíos donde se espera información útil
        if (val is String && val.trim().isEmpty) {
          return defaultValue;
        }

        return val;
      }

      // Mapeo seguro con valores por defecto orientados al tipo de dato (IDs/Rates a número, Nombres a string)
      Map<String, dynamic> impuestoData = {
        'c_tax_id': getVal('C_Tax_ID', defaultValue: 0),
        'tax_indicator': getVal('TaxIndicator', defaultValue: ''),
        'rate': getVal('Rate', defaultValue: 0.0), // Asumimos que la tasa (Rate) es un valor decimal
        'name': getVal('Name', defaultValue: ''),
        'c_tax_category_id': getVal('C_TaxCategory_ID', defaultValue: 0),
        'iswithholding': getVal('IsWithholding', defaultValue: 'N'), // Suele ser 'Y' o 'N' en el ERP
        'sopo_type': getVal('SOPOType', defaultValue: 'P'),
      };

      impuestosData.add(impuestoData);
    }
  } catch (e) {
    print("❌ Error crítico procesando impuestos del ERP: $e");
  }

  print("esto es impuestosData $impuestosData");

  return impuestosData;
}