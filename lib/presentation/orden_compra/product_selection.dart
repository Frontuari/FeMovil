import 'package:femovil/config/app_bar_sampler.dart';
import 'package:femovil/database/gets_database.dart';
import 'package:femovil/presentation/screen/home/home_screen.dart';
import 'package:flutter/material.dart';

class ProductSelectionComprasScreen extends StatefulWidget {
  @override
  _ProductSelectionComprasScreenState createState() =>
      _ProductSelectionComprasScreenState();
}

class _ProductSelectionComprasScreenState
    extends State<ProductSelectionComprasScreen> {
  List<Map<String, dynamic>>? products; // Lista de productos
  List<Map<String, dynamic>> filteredProducts =
      []; // Lista de productos filtrados
  List<Map<String, dynamic>> selectedProducts =
      []; // Lista de productos seleccionados
  Map<String, int> productQuantities =
      {}; // Mapa para almacenar las cantidades seleccionadas por producto
  int newQuantity = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final productList =
        await getProductsAndTaxes(); // Obtener todos los productos
    print('esto es productList de ordenes de compras $productList');
    setState(() {
      products = productList;
      filteredProducts = productList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaScreen = MediaQuery.of(context).size.width * 0.8;
    final screenHeight = MediaQuery.of(context).size.height * 1;

    return Scaffold(
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBarSample(label: 'Productos')),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: screenHeight * 0.030,
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
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
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
              height: screenHeight * 0.030,
            ),
            Expanded(
              child: filteredProducts.isNotEmpty
                  ? SizedBox(
                      width: mediaScreen,
                      child: ListView.builder(
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final productName = filteredProducts[index]['name'];
                          final productPrice =
                              filteredProducts[index]['price'] == '{@nil=true}'
                                  ? 0
                                  : filteredProducts[index]['price'];
                          final mProductId =
                              filteredProducts[index]['m_product_id'];

                          final isSelected = selectedProducts
                              .any((product) => product['name'] == productName);
                          final quantity = productQuantities[productName] ?? 0;

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
                                        ? const Color(0xff7531ff)
                                            .withOpacity(0.5)
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                      await _showQuantityPickerDialog(
                                          context,
                                          productName,
                                          quantity,
                                          const Color(0xff7531ff));
                                  if (selectedQuantity != null) {
                                    if (selectedQuantity > 0) {
                                      final selectedProductIndex =
                                          selectedProducts.indexWhere(
                                              (product) =>
                                                  product['name'] ==
                                                  productName);
                                      final int newQuantity = selectedQuantity;

                                      final selectedProduct = {
                                        "id": filteredProducts[index]['id'],
                                        "name": productName,
                                        "quantity_avaible":
                                            filteredProducts[index]['quantity'],
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
                                          if (newQuantity > 0) {
                                            selectedProducts
                                                .add(selectedProduct);
                                          } else {
                                            print(
                                                'La cantidad seleccionada es mayor que la cantidad disponible');
                                          }
                                        }
                                        productQuantities[productName] =
                                            newQuantity;
                                      });
                                    } else {
                                      setState(() {
                                        selectedProducts.removeWhere(
                                            (product) =>
                                                product['name'] == productName);
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
      ), // Muestra un indicador de carga mientras se cargan los productos
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff7531ff),
        onPressed: () {
          Navigator.pop(context,
              selectedProducts); // Devuelve los productos seleccionados al presionar el botón de regresar
        },
        child: const Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<int?> _showQuantityPickerDialog(BuildContext context,
      String productName, dynamic quantity, Color colorPrimary) {
    int selectedQuantity =
        quantity; // Inicializar selectedQuantity con la cantidad pasada por parámetro

    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                          fontSize: 18, fontFamily: 'Poppins Bold'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (selectedQuantity > 1) {
                                selectedQuantity--;
                              }
                            });
                          },
                          icon: const Icon(Icons.remove),
                        ),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            style:
                                const TextStyle(fontFamily: 'Poppins Regular'),
                            textAlign: TextAlign.center,
                            controller: TextEditingController(
                                text: selectedQuantity.toString()),
                            onChanged: (value) {
                              setState(() {
                                selectedQuantity = int.tryParse(value) ?? 1;
                              });
                            },
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

  void _filterProducts(String searchText) {
    setState(() {
      filteredProducts = products!
          .where((product) =>
              product['name'].toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }
}

class ProductSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> products;

  ProductSearchDelegate(this.products);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, ''));
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final filteredProducts = products
        .where((product) =>
            product['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final productName = filteredProducts[index]['name'];
        return ListTile(
          title: Text(productName),
          onTap: () {
            close(context, productName);
          },
        );
      },
    );
  }
}
