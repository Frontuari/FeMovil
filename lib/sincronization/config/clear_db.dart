import 'package:femovil/database/create_database.dart';

Future<void> clearDatabase() async {

  final db = await DatabaseHelper.instance.database;

  if(db != null){

  await db.transaction((txn) async {
    // Elimina registros de todas las tablas
    await txn.delete('ciiu');
    await txn.delete('products');
    await txn.delete('clients');
    await txn.delete('providers');
    await txn.delete('orden_venta');
    await txn.delete('orden_venta_lines');
    await txn.delete('orden_compra');
    await txn.delete('orden_compra_lines');
    await txn.delete('cobros');
    await txn.delete('f_retenciones');
    await txn.delete('f_retencion_lines');
    await txn.delete('payment_term_fr');
    await txn.delete('usuarios');
    await txn.delete('posproperties');
    await txn.delete('tax');
    await txn.delete('bank_account_app');
    await txn.delete('tax_id_types');
    await txn.delete('tax_payer_types');
    await txn.delete('countries');
    await txn.delete('regions');
    await txn.delete('cities');


    
  });


  // await db.close();
}

}