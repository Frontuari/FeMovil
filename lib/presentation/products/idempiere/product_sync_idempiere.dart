import 'package:femovil/database/gets_database.dart'; // Asumo que aquí tendrás getProductsNoSync
import 'package:femovil/database/update_database.dart'; // Asumo que aquí tendrás updateProductAfterSync
import 'package:femovil/infrastructure/models/products.dart'; // Tu modelo Product
import 'package:femovil/presentation/products/idempiere/create_product.dart'; // Tu servicio HTTP
import 'package:femovil/utils/searck_key_idempiere.dart';

class ProductSyncService {
  Future<int> syncProducts() async {
    // Debes asegurarte de crear este método en tu gets_database.dart
    final productsNoSync = await getProductNoSync(); 
    int syncedCount = 0;

    for (final item in productsNoSync) {
      try {
        final product = Product(
          codProd: item['cod_product'], 
          mProductId: item['m_product_id'], 
          name: item['name'],
          quantity: item['quantity'],
          price: item['price'],
          productType: item['product_type'],
          productTypeName: item['product_type_name'], 
          prodCatId: item['pro_cat_id'],
          categoria: item['categoria'],
          productGroupId: item['product_group_id'],
          produtGroupName: item['product_group_name'],
          taxId: item['tax_cat_id'],
          taxName: item['tax_cat_name'],
          umId: item['um_id'],
          umName: item['um_name'],
          qtySold: item['quantity_sold'],
          priceListSales: item['pricelistsales'],
        );

        // 3. Enviar a iDempiere
        final response = await createProductIdempiere(product.toMap());
        final int mProductIdResponse = int.tryParse(findValueByColumn(response, 'M_Product_ID').toString()) ?? 0;
        final dynamic codProdResponse = findValueByColumn(response, 'Value'); 

        if (mProductIdResponse > 0) {
          
          // 6. Actualizar la base de datos local con el ID real y el Código generado
          await updateProductAfterSync(
            localId: item['id'], 
            mProductId: mProductIdResponse,
            codProd: codProdResponse,
          );

          syncedCount++;
        } else {
            print('Error Sync Producto ${product.name}: ID devuelto fue 0');
        }
        
      } catch (e) {
        print('Error sincronizando producto ${item['name']}: $e');
        // Continuamos con el siguiente producto aunque este falle
        continue;
      }
    }

    return syncedCount;
  }
}