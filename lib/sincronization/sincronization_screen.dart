import 'package:femovil/database/create_database.dart';
import 'package:femovil/infrastructure/models/products.dart';
import 'package:femovil/presentation/products/idempiere/create_product.dart';
import 'package:femovil/presentation/products/products_http.dart';
import 'package:femovil/sincronization/sincronizar.dart';
import 'package:flutter/material.dart';

class SynchronizationScreen extends StatefulWidget {
  const SynchronizationScreen({Key? key}) : super(key: key);

  @override
  _SynchronizationScreenState createState() => _SynchronizationScreenState();
}

class _SynchronizationScreenState extends State<SynchronizationScreen> {
  double _syncPercentage = 0.0; // Estado para mantener el porcentaje sincronizado

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 247, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 236, 247, 255),
        title: const Text('Synchronization'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 25),
          Align(
            alignment: Alignment.topCenter,
            child: ElevatedButton(
              onPressed: () async {
                // Llamada a la función de sincronización

                synchronizeProductsWithIdempiere();
           
                _synchronizeWithIdempiere();
              },
              child: const Text('Sincronizar'),
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Column(
                  children: [
                    const Text('Productos'),
                    Container(
                      width: 150,
                      color: Colors.white,
                      child: Text(
                        '${_syncPercentage.toStringAsFixed(1)} %',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Ícono de check para mostrar que la sincronización fue exitosa
                    _syncPercentage == 100.0
                        ? const Icon(Icons.check, color: Colors.green)
                        : const SizedBox(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _synchronizeWithIdempiere() {
    // Simulación de sincronización (actualización del porcentaje cada segundo)
    const totalSteps = 100;
    const delay = Duration(milliseconds: 100);
    for (int i = 1; i <= totalSteps; i++) {
      Future.delayed(delay * i, () {
        setState(() {
          _syncPercentage = (i / totalSteps) * 100;
        });
      });
    }
  }
}




synchronizeProductsWithIdempiere() async {

      sincronizationProducts();
                List<Map<String, dynamic>> productsWithZeroValues = await getProductsWithZeroValues();
                for (var productData in productsWithZeroValues) {

                  Product product = Product(
                    mProductId: productData['m_product_id'],
                    productType: productData['product_type'],
                    productTypeName: productData['product_type_name'],
                    codProd: productData['cod_product'],
                    prodCatId: productData['pro_cat_id'],
                    taxName: productData['tax_cat_name'],
                    productGroupId: productData['product_group_id'],
                    produtGroupName: productData['product_group_name'],
                    umId: productData['um_id'],
                    umName: productData['um_name'],
                    name: productData['name'],
                    price: productData['price'],
                    quantity: productData['quantity'],
                    categoria: productData['categoria'],
                    qtySold: productData['total_sold'],
                    taxId: productData['tax_cat_id'],
                  );

                       dynamic result = await createProductIdempiere(product.toMap());
                           print('este es el $result');
                       
                    final mProductId = result['StandardResponse']['outputFields']['outputField'][0]['@value'];
                    final codProdc = result['StandardResponse']['outputFields']['outputField'][1]['@value'];
                    print('Este es el mp product id $mProductId && el codprop $codProdc');
                    // Limpia los controladores de texto después de guardar el producto

                    await DatabaseHelper.instance.updateProductMProductIdAndCodProd(productData['id'], mProductId, codProdc);
                  


                }

}