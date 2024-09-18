import 'dart:convert';
import 'dart:io';

import 'package:femovil/config/getPosProperties.dart';
import 'package:femovil/config/url.dart';
import 'package:femovil/database/create_database.dart';
import 'package:femovil/database/gets_database.dart';
import 'package:femovil/database/update_database.dart';
import 'package:femovil/infrastructure/models/products.dart';
import 'package:femovil/infrastructure/models/vendors.dart';
import 'package:femovil/presentation/perfil/perfil_http.dart';
import 'package:femovil/presentation/products/idempiere/create_product.dart';
import 'package:femovil/presentation/screen/home/home_screen.dart';
import 'package:femovil/presentation/screen/proveedores/idempiere/create_vendor.dart';
import 'package:femovil/presentation/screen/ventas/idempiere/create_orden_sales.dart';
import 'package:path_provider/path_provider.dart';

updateAndCreateVendors(orderPurchaseList) async{

  Map<String, dynamic>? vendorIsSincronized = await getVendorsById(orderPurchaseList['proveedor_id']);

      print('Esto es vendor $vendorIsSincronized ');

        if(vendorIsSincronized!['c_bpartner_id'] == 0 && vendorIsSincronized['c_code_id'] == 0){
          
            Vendor vendor = Vendor(
                    cBPartnerId: vendorIsSincronized['c_bpartner_id'],
                    cCodeId: vendorIsSincronized['c_code_id'],
                    bPName: vendorIsSincronized['bpname'],
                    cBPGroupId: vendorIsSincronized['c_bp_group_id'],
                    groupBPName: vendorIsSincronized['groupbpname'],
                    taxId: vendorIsSincronized['tax_id'],
                    isBillTo: vendorIsSincronized['is_bill_to'],
                    isVendor: vendorIsSincronized['is_vendor'],
                    address: vendorIsSincronized['address'],
                    phone: vendorIsSincronized['phone'],
                    cCityId: vendorIsSincronized['c_city_id'],
                    cCountryId: vendorIsSincronized['c_country_id'],
                    cLocationId: vendorIsSincronized['c_location_id'], 
                    city: vendorIsSincronized['city'],
                    email: vendorIsSincronized['email'],
                    lcoTaxIdTypeId: vendorIsSincronized['lco_tax_id_type_id'],
                    lvePersonTypeId: vendorIsSincronized['lve_person_type_id'],
                    personTypeName: vendorIsSincronized['person_type_name'],
                    cBPartnerLocationId: vendorIsSincronized['c_bpartner_location_id'],
                    countryName: vendorIsSincronized['country_name'],
                    postal: vendorIsSincronized['postal'],
                    taxIdTypeName: vendorIsSincronized['tax_id_type_name'],
                    lcoTaxtPayerTypeId: vendorIsSincronized['lco_taxt_payer_type_id'],
                    taxPayerTypeName: vendorIsSincronized['tax_payer_type_name'],
                    ciiuId: vendorIsSincronized['ciiu_id'],
                    ciiuTagName: vendorIsSincronized['ciiu_tagname'],
                    province: vendorIsSincronized['province']
                );
 
        print('Entre aqui en la creacion del proveedor');
                dynamic result = await createVendorIdempiere(vendor.toMap());
    print('este es el $result');

    final cBParnertId =
        result['CompositeResponses']['CompositeResponse']
        ['StandardResponse'][0]['outputFields']
        ['outputField'][0]['@value'];
    final newCodClient =
        result['CompositeResponses']['CompositeResponse']
        ['StandardResponse'][0]['outputFields']
        ['outputField'][1]['@value'];
    final cLocationId =  result['CompositeResponses']['CompositeResponse']
        ['StandardResponse'][1]['outputFields']
        ['outputField']['@value'];
    final cBPartnerLocationId = result['CompositeResponses']['CompositeResponse']
        ['StandardResponse'][2]['outputFields']
        ['outputField']['@value'];

    print('Esto es el codigo de partnert id  $cBParnertId, esto es el $newCodClient, esto es el $cLocationId y esto es el cbparnert location id $cBPartnerLocationId');

      
    await updateCBPartnerIdAndCodVendor(
        vendorIsSincronized['id'], cBParnertId, newCodClient, cLocationId, cBPartnerLocationId );


        Map<String, dynamic>? customerIsSincronizedTrue = await getVendorsById(orderPurchaseList['proveedor_id']);
             final db = await DatabaseHelper.instance.database;


            try {
          if (db != null) {
            print('entre aqui 4');
            int rowsAffected = await db.update(
              'orden_compra',
              {
                'c_bpartner_location_id': customerIsSincronizedTrue!['c_bpartner_location_id'],
                'c_bpartner_id': customerIsSincronizedTrue['c_bpartner_id'],
              },
              where: 'proveedor_id = ?',
              whereArgs: [customerIsSincronizedTrue['id']],
            );

            print('Filas afectadas: $rowsAffected');
          }
        } catch (e) {
          print('Error al actualizar la base de datos: $e');
        }
        
        }


  return await obtenerOrdenDeCompraConLineasPorId(orderPurchaseList['id']);


}

 processMap(Map data) async {
  final lines = data['lines'];
  for (var line in lines) {
    final productId = line['m_product_id'];
    if (productId == 0) {
      // Si el m_product_id es 0, busca y actualiza el producto en la base de datos


      final products = await findProductById(line['producto_id']); 
        
        print('Entre aqui $line');
        
        print('esto es products id ${products['id']}');

        print('Estos son los productos $products');

         Product product = Product(
        mProductId: products['m_product_id'],
        productType: products['product_type'],
        productTypeName: products['product_type_name'] ,
        codProd: products['cod_product'],
        prodCatId: products['pro_cat_id'],
        taxName: products['tax_cat_name'] ,
        umId: products['um_id'],
        name: products['name'],
        price: products['price'],
        quantity: products['quantity'],
        categoria:products['categoria'],
        qtySold: 0,
        taxId: products['tax_cat_id'],
        umName: products['um_name'],
        productGroupId: products['product_group_id'],
        produtGroupName: products['product_group_name'],
        priceListSales: products['pricelistsales']
      );



         dynamic result = await createProductIdempiere(product.toMap());

    final mProductId = result['StandardResponse']['outputFields']['outputField'][0]['@value'];
    final codProdc = result['StandardResponse']['outputFields']['outputField'][1]['@value'];
    print('Este es el mp product id $mProductId && el codprop $codProdc');
   

    await updateProductMProductIdAndCodProd(products['id'], mProductId, codProdc);
    await updateMProductIdOrderCompra(line['line_id'], mProductId);
  

    }else{

      print('Este producto esta registrado en idempiere');
    }
  }

  print('Esto es la orden ${data['id']}');

return await obtenerOrdenDeCompraConLineasPorId(data['id']);

}


  findProductById(int productId) async {
  // Implementa la lógica para buscar el producto en la base de datos por su ID
  // Retorna el producto encontrado o null si no se encuentra.
  // Esto variará dependiendo de tu configuración específica.

   final db = await DatabaseHelper.instance.database;
    if (db != null) {
      final product = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [productId],
      );



    return product.first;  

    } else {
      print('Error: db is null');
    }



}



createOrdenPurchaseIdempiere(orderPurchaseList) async {


   dynamic isConnection = await checkInternetConnectivity();

              if(!isConnection){
                return false;
              }
      
    orderPurchaseList =  await processMap(orderPurchaseList);
      


          if(orderPurchaseList!['c_bpartner_id'] == 0 && orderPurchaseList['c_bpartner_location_id'] == 0){

            orderPurchaseList = await updateAndCreateVendors(orderPurchaseList);
          
          }




    print('Esto es orderPurchase actual $orderPurchaseList');
      
      HttpClient httpClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) {
          return true;
        };

      try {
        initV() async {
         
          if (variablesG.isEmpty) {
           
            List<Map<String, dynamic>> response = await getPosPropertiesV();
            print('variables Entre aqui');
            variablesG = response;
          }
        }

    await initV();

    print('variables globales $variablesG');

    var map = await getRuta();
    var variablesLogin = await getLogin();
    final uri = Uri.parse('${map['URL']}ADInterface/services/rest/composite_service/composite_operation');

    final request = await httpClient.postUrl(uri);

    final info = await getApplicationSupportDirectory();
    print("esta es la ruta ${info.path}");

    final String filePathEnv = '${info.path}/.env';
    final File archivo = File(filePathEnv);
    String contenidoActual = await archivo.readAsString();
    print('Contenido actual del archivo:\n$contenidoActual');

    // Convierte el contenido JSON a un mapa
    dynamic requestBody = {};
    Map<String, dynamic> jsonData = jsonDecode(contenidoActual);

    var role = jsonData["RoleID"];
    var orgId = jsonData["OrgID"];
    var clientId = jsonData["ClientID"];
    var wareHouseId = jsonData["WarehouseID"];
    var language = jsonData["Language"];
    print("Esto es orderPurchase List nuevo $orderPurchaseList");
   
  
       requestBody = {
        "CompositeRequest": {
          "ADLoginRequest": {
            "user": variablesLogin['user'],
            "pass": variablesLogin['password'],
            "lang": jsonData["Language"], 
            "ClientID": jsonData["ClientID"],
            "RoleID": jsonData["RoleID"],
            "OrgID": jsonData["OrgID"],
            "WarehouseID": jsonData["WarehouseID"],
            "stage": "9",
          },
          "serviceType": "UCCompositeOrder",
          "operations": {
            "operation": [
              {
                "@preCommit": "false",
                "@postCommit": "false",
                "TargetPort": "createData",
                "ModelCRUD": {
                  "serviceType": "UCCreateOrder",
                  "TableName": "C_Order",
                  "RecordID": "0",
                  "Action": "CreateUpdate",
                  "DataRow": {
                    "field": [
                      {
                        "@column": "AD_Client_ID",
                        "val": orderPurchaseList['ad_client_id']
                      },
                      {"@column": "AD_Org_ID", "val": orderPurchaseList['ad_org_id']},
                      {
                        "@column": "C_BPartner_ID",
                        "val": orderPurchaseList['c_bpartner_id'],
                      },
                      {
                        "@column": "C_BPartner_Location_ID",
                        "val": orderPurchaseList['c_bpartner_location_id'],
                      },
                      {
                        "@column": "C_Currency_ID",
                        "val": "100",
                      },
                      {
                        "@column": "Description",
                        "val": orderPurchaseList['description'],
                      },
                      // {
                      //   "@column": "C_ConversionType_ID",
                      //   "val": variablesG[0]['c_conversion_type_id']
                      // },
                      {
                        "@column": "C_DocTypeTarget_ID",
                        "val": orderPurchaseList['c_doc_type_target_id']
                      },
                      {
                        "@column": "C_PaymentTerm_ID",
                        "val": variablesG[0]['c_paymentterm_id']
                      },
                      {
                        "@column": "DateOrdered",
                        "val": orderPurchaseList['dateordered']
                      },
                      {"@column": "IsTransferred", "val": 'Y'},
                      {
                        "@column": "M_PriceList_ID",
                        "val": variablesG[0]['m_pricelist_id']
                      },
                      {
                        "@column": "M_Warehouse_ID",
                        "val": orderPurchaseList['m_warehouse_id']
                      },
                      {"@column": "PaymentRule", "val": 'P'},
                      {
                        "@column": "SalesRep_ID",
                        "val": orderPurchaseList['usuario_id']
                      },
                      // {"@column": "LVE_PayAgreement_ID", "val": '1000001'},
                      {"@column": "IsSOTrx", "val": 'N'}
                  
                    ]
                  }
                }
              },
               
            ]
          }
        }
      };

      // Crear las líneas de la orden
  final lines = createLines(orderPurchaseList['lines'], orderPurchaseList['usuario_id']);

  // Agregar las líneas de la orden al JSON de la orden
  for (var line in lines) {
    requestBody['CompositeRequest']['operations']['operation'].add(line);
  }

  dynamic doAction  = {
        "@preCommit": "false",
        "@postCommit": "false",
        "TargetPort": "setDocAction",                      
          "ModelSetDocAction": {
              "serviceType": "completeOrder",
              "tableName": "C_Order",
              "recordIDVariable": "@C_Order.C_Order_ID",
              "docAction": variablesG[0]['doc_status_order_po'],
          }
      };
                
   requestBody['CompositeRequest']['operations']['operation'].add(doAction);


      // Configurar el cuerpo de la solicitud en formato JSON

      final jsonBody = jsonEncode(requestBody);

      request.headers.set('Content-Type', 'application/json; charset=utf-8');
      request.headers.set('Accept', 'application/json');

      request.write(jsonBody);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      final parsedJson = jsonDecode(responseBody);

      print("esta es la respuesta $parsedJson");

        dynamic documentNo = parsedJson['CompositeResponses']['CompositeResponse']['StandardResponse'][0]['outputFields']['outputField'][1]['@value'];
        dynamic cOrderId = parsedJson['CompositeResponses']['CompositeResponse']['StandardResponse'][0]['outputFields']['outputField'][0]['@value'];
        print(' esto es el client id ${orderPurchaseList['id']} Esto es el document no $documentNo y este es el orderid $cOrderId');
        dynamic isError = parsedJson['CompositeResponses']['CompositeResponse']['StandardResponse'][2]['@IsError'];


                        if(isError){

                          return false;
                        }



                        Map<String, dynamic> nuevoDocumentNoAndCOrderId = {

                            'documentno': documentNo,
                            'c_order_id':cOrderId


                        };

                      String newStatus = 'Enviado';

                      updateOrderePurchaseForStatusSincronzed(orderPurchaseList['id'], newStatus);

                      actualizarDocumentNoVendor(orderPurchaseList['id'], nuevoDocumentNoAndCOrderId);

    return parsedJson;

  } catch (e) {
    return 'este es el error e $e';
  }
}




createLines(lines, rePId) {
  List linea = [];

  lines.forEach((line) => {
        print("line $line"),
        linea.add({
          "@preCommit": "false",
            "@postCommit": "false",
            "TargetPort": "createData",
            "ModelCRUD": {
                "serviceType": "UCCreateOrderLine",
                "TableName": "C_OrderLine",
                "recordID": "0",
                "Action": "Create",
                "DataRow": {
          "field": [
            {"@column": "AD_Client_ID", "val": line['ad_client_id']},
            {"@column": "AD_Org_ID", "val": line['ad_org_id']},
            {"@column": "C_Order_ID", "val": "@C_Order.C_Order_ID"},
            {"@column": "PriceEntered", "val": line['price_entered']},
            {"@column": "PriceActual", "val": line['price_entered']},
            {"@column": "M_Product_ID", "val": line['m_product_id']},
            {"@column": "QtyOrdered", "val": line['qty_entered']},
            {"@column": "QtyEntered", "val": line['qty_entered']},
            {"@column": "SalesRep_ID", "val": rePId}
          ]
         }
        }
        })
      });

  print("estas son las lineas $linea");

  return linea;

}



