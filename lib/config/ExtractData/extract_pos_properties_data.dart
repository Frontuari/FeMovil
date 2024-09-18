import 'dart:convert';

// Función para procesar la respuesta de iDempiere y extraer los datos de los productos
List<Map<String, dynamic>> extractGetPosPropertiesData(String responseData) {
  // Decodifica la respuesta JSON
  Map<String, dynamic> parsedResponse = jsonDecode(responseData);

  // Extrae la lista de DataRow de la respuesta
  List<dynamic> dataRows = parsedResponse['WindowTabData']['DataSet']['DataRow'];

  // Crea una lista para almacenar los datos de los productos
  List<Map<String, dynamic>> posPropertiesData = [];

  print('Esto es la respuesta del erp getProperties ${dataRows[15]}');

  // Itera sobre cada DataRow y extrae los datos relevantes de los productos

try {

     dynamic getValue(dynamic dataRows, String columnName) {
    for (var row in dataRows) {
      var field = row['field'].firstWhere(
          (field) => field['@column'] == 'Name' && field['val'] == columnName,
          orElse: () => null);
      if (field != null) {
        return row['field'].firstWhere(
            (field) => field['@column'] == 'Value')['val'];
      }
    }
    return null; // Retorna null si no se encuentra el campo
  }
  

    Map<String, dynamic> posPropiertieData = {
      'country_id': getValue(dataRows, 'C_Country_ID'),
      // 'tax_payer_type_natural': dataRows[4]['field'][1]['val'],
      // 'tax_payer_type_juridic': dataRows[5]['field'][1]['val'],
      // 'person_type_juridic': dataRows[6]['field'][1]['val'],
      // 'person_type_natural': dataRows[7]['field'][1]['val'],
      // 'm_warehouse_id':dataRows[8]['field'][1]['val'], 
      'c_doc_type_order_id': getValue(dataRows, 'C_DocTypeOrder_ID'),
      // 'c_conversion_type_id': dataRows[10]['field'][1]['val'],
      'c_paymentterm_id': getValue(dataRows, 'C_PaymentTerm_ID'),
      // 'c_bankaccount_id': dataRows[12]['field'][1]['val'],
      // 'c_bpartner_id': dataRows[13]['field'][1]['val'],
      'c_doctypepayment_id': getValue(dataRows, 'C_DocTypePayment_ID'),
      'c_doctypereceipt_id': getValue(dataRows, 'C_DocTypeReceipt_ID' ),
      'city': getValue(dataRows, 'City'),
      'address1':getValue(dataRows, 'Address1'),
      'm_pricelist_id':getValue(dataRows, 'M_PriceList_ID'),
      'c_currency_id':getValue(dataRows, 'C_Currency_ID'),
      'c_doc_type_order_co': getValue(dataRows, 'C_DocTypeOrder_Co'),
      'm_price_saleslist_id': getValue(dataRows, 'M_PriceListSales_ID'),
      'doc_status_receipt' : getValue(dataRows, 'DocStatusReceipt'),
      'doc_status_invoice_so': getValue(dataRows, 'DocStatusInvoiceSO'),
      'doc_status_order_so': getValue(dataRows, 'DocStatusOrderSO'),
      'doc_status_order_po': getValue(dataRows, 'DocStatusOrderPO'),
      'c_doc_type_target_fr': getValue(dataRows, 'C_DocTypeTarget_FR')

    };
    // Agrega los datos del producto a la lista
    posPropertiesData.add(posPropiertieData);
  
} catch (e) {

  print("ESTE ES EL ERROR $e");
  
}

  print("esto es impuestosData $posPropertiesData");

  return posPropertiesData;
}