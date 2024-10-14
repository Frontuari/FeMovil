import 'package:femovil/database/create_database.dart';

Future<void> updateProduct(Map<String, dynamic> updatedProduct) async {
    final db = await DatabaseHelper.instance.database;
    if (db != null) {
      await db.update(
        'products',
        updatedProduct,
        where: 'id = ?',
        whereArgs: [updatedProduct['id']],
      );
    } else {
      // Manejar el caso en el que db sea null
      print('Error: db is null');
    }
  }

    Future<void> updateClient(Map<String, dynamic> updatedClient) async {
    final db = await DatabaseHelper.instance.database;
    if (db != null) {
      await db.update(
        'clients',
        updatedClient,
        where: 'id = ?',
        whereArgs: [updatedClient['id']],
      );
    } else {
      // Manejar el caso en el que db sea null
      print('Error: db is null');
    }
  }

    Future<void> updateProvider(Map<String, dynamic> updatedProvider) async {
    final db = await DatabaseHelper.instance.database;
    if (db != null) {
      await db.update(
        'providers',
        updatedProvider,
        where: 'id = ?',
        whereArgs: [updatedProvider['id']],
      );
    } else {
      // Manejar el caso en el que db sea null
      print('Error: db is null');
    }
  }


Future<void> updateProductMProductIdAndCodProd(int productId, int newMProductId, int newCodProduct) async {
    final db = await DatabaseHelper.instance.database;
  print("esto es el valor de me produc id $newMProductId y el valor de newcodprodu $newCodProduct");
  if (db != null) {
    await db.update(
      'products',
      {
        'm_product_id': newMProductId,
        'cod_product': newCodProduct,
      },
      where: 'id = ?',
      whereArgs: [productId],
    );
    print('Product updated successfully');
  } else {
    print('Error: db is null');
  }
}

Future<void> updateCustomerCBPartnerIdAndCodClient(
  int customerId, 
  int cBPartnerId,
  int newCodClient,
  int cLocationId,
  int cBparnetLocationId,
   ) async {
    final db = await DatabaseHelper.instance.database;

  if (db != null) {
    await db.update(
      'clients',
      {
        'c_bpartner_id': cBPartnerId,
        'cod_client': newCodClient,
        'c_location_id':cLocationId,
        'c_bpartner_location_id': cBparnetLocationId,
      },
      where: 'id = ?',
      whereArgs: [customerId],
    );
    print('Customer updated successfully');
  } else {
    print('Error: db is null');
  }
}


Future<void> updateVendorCBPartnerIdAndCodId(
  int vendorId, 
  int cBPartnerId,
  int newCodVendor,
  int cLocationId,
  int cBparnetLocationId,
   ) async {
    final db = await DatabaseHelper.instance.database;

  if (db != null) {
    await db.update(
      'providers',
      {
        'c_bpartner_id': cBPartnerId,
        'cod_client': newCodVendor,
        'c_location_id':cLocationId,
        'c_bpartner_location_id': cBparnetLocationId,
      },
      where: 'id = ?',
      whereArgs: [vendorId],
    );
    print('proveedor updated successfully');
  } else {
    print('Error: db is null');
  }
}


Future<void> updateCBPartnerIdAndCodVendor(
  int customerId, 
  int cBPartnerId,
  int newCodClient,
  int cLocationId,
  int cBparnetLocationId,
   ) async {
    final db = await DatabaseHelper.instance.database;

  if (db != null) {
    await db.update(
      
      'providers',
      {
        'c_bpartner_id': cBPartnerId,
        'c_code_id': newCodClient,
        'c_location_id':cLocationId,
        'c_bpartner_location_id': cBparnetLocationId,
      },
      where: 'id = ?',
      whereArgs: [customerId],
    );
    print('Proveedor updated successfully');
  } else {
    print('Error: db is null');
  }
}






Future updateOrdereSalesForStatusSincronzed(int orderId, String newStatus) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    await db.update(
      'orden_venta',
      {
        'status_sincronized': newStatus,
      },
      where: 'id = ?',
      whereArgs: [orderId],
    );
    print('order Sales updated successfully');
    return 1;
  } else {
    print('Error: db is null');
  }
}

Future updateOrderePurchaseForStatusSincronzed(int orderId, String newStatus) async {
    final db = await DatabaseHelper.instance.database;
  if (db != null) {
    await db.update(
      'orden_compra',
      {
        'status_sincronized': newStatus,
      },
      where: 'id = ?',
      whereArgs: [orderId],
    );
    print('order purchase updated successfully');
    return 1;
  } else {
    print('Error: db is null');
  }
}



Future updateMProductIdOrderCompra(int orderId, int mProductId) async {
    final db = await DatabaseHelper.instance.database;
  if (db != null) {
    await db.update(
      'orden_compra_lines',
      {
        'm_product_id': mProductId,
      },
      where: 'id = ?',
      whereArgs: [orderId],
    );
    print('order purchase updated successfully');
    return 1;
  } else {
    print('Error: db is null');
  }
}




 Future<void> actualizarDocumentNo(int id, Map<String, dynamic> nuevoDocumentNoAndCOrderId) async {
    final db = await DatabaseHelper.instance.database;

    print('Entre aqui en actualizacion de orden de venta $id Y $nuevoDocumentNoAndCOrderId');

    int resultado = await db!.update(
      'orden_venta',
      {
      'documentno': nuevoDocumentNoAndCOrderId['documentno'],
      'c_order_id': nuevoDocumentNoAndCOrderId['c_order_id']
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    if (resultado == 1) {
      print('Actualización exitosa.');
    } else {
      print('La actualización falló.');
    }
  }

   Future<void> actualizarDocumentNoVendor(int id, Map<String, dynamic> nuevoDocumentNoAndCOrderId) async {
    final db = await DatabaseHelper.instance.database;

    int resultado = await db!.update(
      'orden_compra',
      {
      'documentno': nuevoDocumentNoAndCOrderId['documentno'],
      'c_order_id': nuevoDocumentNoAndCOrderId['c_order_id']
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    if (resultado == 1) {
      print('Actualización exitosa.');
    } else {
      print('La actualización falló.');
    }
  }



  Future<void> updateDocumentNoCobro(
  int cobrorId, 
  dynamic documentNo,
   ) async {
    final db = await DatabaseHelper.instance.database;
    
    print('Este es el cobroId $cobrorId y este es el documentno $documentNo');

  if (db != null) {
    await db.update(
      
      'cobros',
      {
        'documentno': documentNo,
    
      },
      where: 'id = ?',
      whereArgs: [cobrorId],
    );
    
    print('Cobro updated successfully');

  } else {
    
    print('Error: db is null');
  
  }
}



  Future<void> updateNumberInvoiceAndDocumentNo(
  int orderSalesId, 
  dynamic documentNo,
  dynamic invoiceId,
   ) async {
    final db = await DatabaseHelper.instance.database;
    

  if (db != null) {
    await db.update(
      
      'orden_venta',
      {
        'id_factura': invoiceId,
        'documentno_factura': documentNo
      },
      where: 'id = ?',
      whereArgs: [orderSalesId],
    );
    
    print('Orden de venta updated successfully');

  } else {
    
    print('Error: db is null');
  
  }
}



