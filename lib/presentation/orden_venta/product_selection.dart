import 'package:femovil/config/app_bar_sampler.dart';
import 'package:femovil/database/gets_database.dart';
import 'package:flutter/material.dart';

class ProductSelectionScreen extends StatefulWidget {
  const ProductSelectionScreen({super.key});

  @override
  _ProductSelectionScreenState createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  List<Map<String, dynamic>>? products; // Lista de productos
  List<Map<String, dynamic>> filteredProducts =
      []; // Lista de productos filtrados
  List<Map<String, dynamic>> selectedProducts =
      []; // Lista de productos seleccionados
  Map<String, int> productQuantities =
      {}; // Mapa para almacenar las cantidades seleccionadas por producto

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final productList =
        await getProductsAndTaxes(); // Obtener todos los productos

    // Filtrar los productos con precio igual a '{@nil=true}'
    final filteredList = productList
        .where((product) => product['pricelistsales'] != '{@nil=true}')
        .toList();

    print('Esto es el productList $productList');
    setState(() {
      products = filteredList;
      filteredProducts = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaScreen = MediaQuery.of(context).size.width * 0.8;
    final colorTheme = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: const PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: AppBarSample(label: 'Productos')),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: mediaScreen * 0.05,
              ),
              Container(
                width: mediaScreen * 0.98,
                height: mediaScreen * 0.18,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 7,
                          spreadRadius: 2,
                          color: Colors.grey.withOpacity(0.5))
                    ]),
                child: TextField(
                  onChanged: (query) {
                    setState(() {
                      filteredProducts = products!
                          .where((product) => product['name']
                              .toLowerCase()
                              .contains(query.toLowerCase()))
                          .toList();
                    });

                    print('Esto es el filtro de productos $filteredProducts');
                  },
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(
                        fontFamily: 'Poppins Regular', color: Colors.black),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 25, horizontal: 20),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      borderSide: BorderSide.none, // Color del borde
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 25,
                      ), // Color del borde cuando está enfocado
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 25,
                      ), // Color del borde cuando no está enfocado
                    ),
                    labelText: 'Nombre del producto',
                    suffixIcon: Image.asset('lib/assets/Lupa.png'),
                  ),
                  style: const TextStyle(fontFamily: 'Poppins Regular'),
                ),
              ),
              SizedBox(
                height: mediaScreen * 0.05,
              ),
              Expanded(
                child: filteredProducts.isNotEmpty
                    ? SizedBox(
                        width: mediaScreen,
                        child: ListView.builder(
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final productName = filteredProducts[index]['name'];
                            final productPrice = filteredProducts[index]
                                        ['pricelistsales'] ==
                                    '{@nil=true}'
                                ? 0
                                : filteredProducts[index]['pricelistsales'];
                            final mProductId =
                                filteredProducts[index]['m_product_id'];

                            final isSelected = selectedProducts.any(
                                (product) => product['name'] == productName);
                            final quantity =
                                productQuantities[productName] ?? 0;

                            return Card(
                              elevation: 0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              shadowColor: Colors.grey.withOpacity(0.5),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? const Color(0xff7531FF).withOpacity(0.5)
                                          : Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0, vertical: 7),
                                    child: Text(productName,
                                        style: const TextStyle(
                                            fontFamily: 'Poppins Bold')),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Stock: ',
                                            style: TextStyle(
                                                fontFamily: 'Poppins SemiBold'),
                                          ),
                                          Text(
                                              '${filteredProducts[index]['quantity']}'),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Precio: ',
                                            style: TextStyle(
                                                fontFamily: 'Poppins SemiBold'),
                                          ),
                                          Text(
                                              '\$ ${productPrice != '{@nil=true}' ? productPrice.toStringAsFixed(2) : 0}')
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Cantidad Seleccionada: ',
                                            style: TextStyle(
                                                fontFamily: 'Poppins SemiBold'),
                                          ),
                                          Text(quantity.toString())
                                        ],
                                      ),
                                    ],
                                  ),
                                  onTap: () async {
                                    final selectedQuantity =
                                        await _showQuantityPickerDialog(context,
                                            productName, quantity, colorTheme);
                                    if (selectedQuantity != null) {
                                      if (selectedQuantity > 0) {
                                        final selectedProductIndex =
                                            selectedProducts.indexWhere(
                                                (product) =>
                                                    product['name'] ==
                                                    productName);
                                        final int newQuantity =
                                            selectedQuantity;

                                        final selectedProduct = {
                                          "id": filteredProducts[index]['id'],
                                          "name": productName,
                                          "quantity_avaible":
                                              filteredProducts[index]
                                                  ['quantity'],
                                          "quantity": newQuantity,
                                          "price": productPrice,
                                          "impuesto": filteredProducts[index]
                                              ['tax_rate'],
                                          'm_product_id': mProductId
                                        };

                                        setState(() {
                                          print(
                                              "que tiene newquantity $newQuantity");
                                          if (isSelected) {
                                            selectedProducts[
                                                    selectedProductIndex] =
                                                selectedProduct;
                                          } else {
                                        
                                              selectedProducts
                                                  .add(selectedProduct);
                                           
                                          }
                                          productQuantities[productName] =
                                              newQuantity;
                                        });
                                      } else {
                                        setState(() {
                                          selectedProducts.removeWhere(
                                              (product) =>
                                                  product['name'] ==
                                                  productName);
                                          productQuantities.remove(productName);
                                        });
                                      }
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            ],
          ),
        ),
        // Muestra un indicador de carga mientras se cargan los productos
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context,
                selectedProducts); // Devuelve los productos seleccionados al presionar el botón de regresar
          },
          backgroundColor: const Color(0xff7531ff),
          foregroundColor: Colors.white,
          child: const Icon(Icons.check),
        ),
      ),
    );
  }

  Future<int?> _showQuantityPickerDialog(BuildContext context,
      String productName, dynamic quantity, Color colorTheme) {
    int selectedQuantity =
        quantity; // Inicializar selectedQuantity con la cantidad pasada por parámetro

    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled:
          true, // Permitir que el contenido haga scroll si es necesario
      builder: (BuildContext context) {
        return SingleChildScrollView(
          // Envolver el contenido con SingleChildScrollView
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Seleccione la cantidad de $productName',
                      style: const TextStyle(
                        fontFamily: 'Poppins SemiBold',
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (selectedQuantity > 0) {
                                selectedQuantity--;
                              }
                            });
                          },
                          icon: const Icon(Icons.remove),
                        ),
                        Text(
                          selectedQuantity.toString(),
                          style: const TextStyle(
                            fontFamily: 'Poppins Regular',
                            fontSize: 20,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                            
                                selectedQuantity++;
                              
                            });
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ButtonStyle(
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                          backgroundColor:
                              const WidgetStatePropertyAll(Color(0xff7531ff)),
                          foregroundColor:
                              const WidgetStatePropertyAll(Colors.white)),
                      onPressed: () {
                        Navigator.pop(context, selectedQuantity);
                      },
                      child: const Text(
                        'Confirmar',
                        style: TextStyle(fontFamily: 'Poppins Bold'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
