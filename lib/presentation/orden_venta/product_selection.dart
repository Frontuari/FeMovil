import 'package:femovil/database/create_database.dart';
import 'package:flutter/material.dart';

class ProductSelectionScreen extends StatefulWidget {
  @override
  _ProductSelectionScreenState createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  List<Map<String, dynamic>>? products;  // Lista de productos

  List<Map<String, dynamic>> selectedProducts = []; // Lista de productos seleccionados

  Map<String, int> productQuantities = {}; // Mapa para almacenar las cantidades seleccionadas por producto

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final productList = await DatabaseHelper.instance.getProducts(); // Obtener todos los productos

    setState(() {
      products = productList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Productos'),
      ),
      body: products != null
          ? ListView.builder(
              itemCount: products!.length,
              itemBuilder: (context, index) {
                final productName = products![index]['name'];
                final productPrice = products![index]['price'];
                final isSelected = selectedProducts.any((product) => product['name'] == productName);
                final quantity = productQuantities[productName] ?? 0; // Obtener la cantidad seleccionada o 0 si no hay ninguna

                return ListTile(
                  title: Text(productName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Precio: \$${productPrice.toStringAsFixed(2)}'),
                      Text('Cantidad: $quantity'), // Mostrar la cantidad seleccionada
                    ],
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: Colors.green) // Icono de check si el producto está seleccionado
                      : null,
                  onTap: () async {
                    final selectedQuantity = await _showQuantityPickerDialog(context, productName);
                    if (selectedQuantity != null) {
                      setState(() {
                        if (isSelected) {
                          selectedProducts.removeWhere((product) => product['name'] == productName); // Desmarca el producto si ya estaba seleccionado
                        } else {
                          selectedProducts.add(products![index]); // Marca el producto si no estaba seleccionado
                        }
                        productQuantities[productName] = selectedQuantity;
                      });
                    }
                  },
                );
              },
            )
          : Center(child: CircularProgressIndicator()), // Muestra un indicador de carga mientras se cargan los productos
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, selectedProducts); // Devuelve los productos seleccionados al presionar el botón de regresar
        },
        child: Icon(Icons.check),
      ),
    );
  }

  Future<int?> _showQuantityPickerDialog(BuildContext context, String productName) {
    int quantity = 1; // Cantidad inicial seleccionada

    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 200,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Seleccione la cantidad de $productName',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (quantity > 1) {
                              quantity--;
                            }
                          });
                        },
                        icon: Icon(Icons.remove),
                      ),
                      Text(
                        quantity.toString(),
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                        icon: Icon(Icons.add),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, quantity);
                    },
                    child: Text('Confirmar'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
