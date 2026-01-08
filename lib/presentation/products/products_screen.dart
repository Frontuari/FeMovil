import 'package:femovil/assets/nav_bottom_menu.dart';
import 'package:femovil/config/app_bar_femovil.dart';
import 'package:femovil/database/create_database.dart';
import 'package:femovil/database/gets_database.dart';
import 'package:femovil/presentation/products/add_products.dart';
import 'package:femovil/presentation/products/filter_dialog.dart';
import 'package:femovil/presentation/products/idempiere/product_sync_idempiere.dart';
import 'package:femovil/presentation/products/products_details.dart';
import 'package:femovil/utils/alerts_messages.dart';
import 'package:femovil/utils/snackbar_messages.dart';
import 'package:femovil/utils/widgets.dart';
import 'package:flutter/material.dart';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  String _filter = "";
  List<Map<String, dynamic>> products = [];
  dynamic filteredProducts = [];
  TextEditingController searchController = TextEditingController();
  String input = "";
  late ScrollController _scrollController;
  bool _showAddButton = true;
  final int _pageSize = 25; // Tamaño de cada página
  bool _isLoading = false;
  bool _hasMoreProducts = true;
  int countProductSync = 0;

  late List<Map<String, dynamic>> taxes =
      []; // Lista para almacenar los impuestos
  late List<Map<String, dynamic>> productNoSync = [];

  Future<void> _loadProducts() async {
    final productos = await getProductsScreen(
        page: 1, pageSize: _pageSize); // Obtener todos los productos
    // final inserccion = await DatabaseHelper.instance.insertTaxData(); // Obtener todos los productos
    print("Estoy obteniendo products $products");

    print('Products cargados: $productos');

    setState(() {
      products = productos;
      filteredProducts = productos;
      _hasMoreProducts = productos.length == _pageSize;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _loadMoreProducts();
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      if (_showAddButton) {
        setState(() {
          _showAddButton = false;
        });
      }
    } else {
      if (!_showAddButton) {
        setState(() {
          _showAddButton = true;
        });
      }
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoading || !_hasMoreProducts) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final List<Map<String, dynamic>> newData = await getProductsScreen(
          page: (products.length ~/ _pageSize) + 1, pageSize: _pageSize);

      print('Data Productos $newData');

      if (newData.isNotEmpty) {
        setState(() {
          for (var prod in newData) {
            bool exists = products
                .any((existingProduct) => existingProduct['id'] == prod['id']);
            if (!exists) {
              products = [...products, prod];
            }
          }
          _hasMoreProducts = newData.length == _pageSize;
        });
      } else {
        setState(() {
          _hasMoreProducts = false; // No hay más productos para cargar
        });
      }
      print(
          "esto es el valor de productos despues de agrgarle el siguiente $products");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> anyNoSyncProduct() async {
    final productNoSync = await getProductNoSync();

    print("Estoy obteniendo Clientes No Sincronizados $productNoSync");

    setState(() {
      this.productNoSync = productNoSync;
      countProductSync = productNoSync.length;
    });

    print("Estoy obteniendo Productos $productNoSync");
    print('Cantidades no Sincronizados $countProductSync');
    if (countProductSync > 0) {
      showWarningSnackbarDisplace(
          context, 'Productos Por Enviar $countProductSync');
    }
  }

  Future<void> sendProductIdempiereScreen() async {
    showLoadingDialog(context, message: 'Sincronizando Productos...');
    final productSyncService = ProductSyncService();

    int syncedCount = await productSyncService.syncProducts();

    print('Se sincronizaron $syncedCount clientes con iDempiere');

    Navigator.of(context).pop(); // Cerrar el diálogo de carga

    if (syncedCount > 0) {
      await SuccesMessages.showSuccesMessagesDialog(
          context, 'Se sincronizaron $syncedCount Productos con iDempiere');
    } else {
      await ErrorMessage.showErrorMessageDialog(
          context, 'No se pudo Sincronizar los Productos intente más tarde ');
    }

    await anyNoSyncProduct();
  }

  void _showFilterOptions(BuildContext context) async {
    final selectedFilter = await showDialog<String>(
      context: context,
      builder: (context) => FilterCategories(
        products: products,
      ), // Reemplaza YourFilterDialog con tu widget de filtro
    );

    print("Esto es el valor del select $selectedFilter");

    if (selectedFilter != null) {
      setState(() {
        _filter = selectedFilter;
        print("Esto es el filter $_filter");
      });
    }
  }

  @override
  void initState() {
    _loadProducts();
    _scrollController = ScrollController();

    _scrollController.addListener(_scrollListener);
    print('Esto es el montaje');
    anyNoSyncProduct();
    // _deleteBaseDatos();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (input == "") {
      filteredProducts = products.toList();
    }

    if (_filter != "" && input == "") {
      setState(() {
        if (_filter == "Todos") {
          searchController.clear();
          input = "";

          filteredProducts = products.toList();
        } else {
          filteredProducts = products
              .where((product) => product['categoria'] == _filter)
              .toList();
        }
        input = ""; // Limpiar el campo de búsqueda al filtrar por categoría
      });
    } else if (input != "") {
      setState(() {
        filteredProducts = products
            .where((product) =>
                product['name'].toLowerCase().contains(input.toLowerCase()))
            .toList();
      });
    }

    if (_filter != "" && _filter != "Todos") {
      filteredProducts =
          products.where((product) => product['categoria'] == _filter).toList();
      searchController.clear();
      input = "";
    } else if (_filter == "Todos") {
      searchController.clear();
      input = "";

      filteredProducts = products.toList();
    }

    final screenMax = MediaQuery.of(context).size.width * 0.8;
    final screenHeight = MediaQuery.of(context).size.height * 0.8;

    return GestureDetector(
      onTap: () {
        if (MediaQuery.of(context).viewInsets.bottom > 0) {
          // Verificar si hay un teclado visible
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        //Boton flotante para Agregar iMAGEN
        floatingActionButton: _showAddButton
            ? SizedBox(
                width: 80,
                height: 80,
                child: FloatingActionButton(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  highlightElevation: 0,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddProductForm()),
                    );
                  },
                  child: Image.asset(
                    'lib/assets/Agregar@3x.png',
                    fit: BoxFit.contain,
                  ),
                ),
              )
            : null,
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(170),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const AppBars(
                labelText: 'Productos',
              ),
              Positioned(
                left: 16,
                right: 16,
                top: 160,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: 300,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          9.0), // Ajusta el radio de las esquinas
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey
                              .withOpacity(0.2), // Color de la sombra
                          spreadRadius: 2, // Extensión de la sombra
                          blurRadius: 3, // Difuminado de la sombra
                          offset:
                              const Offset(0, 2), // Desplazamiento de la sombra
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) async {
                        setState(() {
                          input = value;
                          _filter =
                              ''; // Limpia el filtro para evitar conflictos
                        });

                        if (value.isNotEmpty) {
                          // Si el texto de búsqueda no está vacío
                          List<Map<String, dynamic>> searchResults = products
                              .where((product) => product['name']
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();

                          if (searchResults.isNotEmpty) {
                            // Si se encontraron productos, actualiza filteredProducts
                            setState(() {
                              filteredProducts = searchResults;
                            });
                          } else {
                            // Si no se encontraron productos, realiza una búsqueda en la base de datos
                            List<Map<String, dynamic>> dbResults =
                                await getProductByName(value);
                            print("esto es dbresult $dbResults");
                            setState(() {
                              products = dbResults;
                            });
                          }
                        } else {
                          products = await getProductsScreen(
                              page: (products.length ~/ _pageSize) + 1,
                              pageSize: _pageSize);
                          setState(() {
                            filteredProducts = products.toList();
                          });
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 3.0, horizontal: 20.0),
                        hintText: 'Nombre del producto',
                        labelStyle: const TextStyle(
                            color: Colors.black, fontFamily: 'Poppins Regular'),
                        suffixIcon: Image.asset('lib/assets/Lupa.png'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 25,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Image.asset(
                          'lib/assets/filtro@3x.png',
                          width: 25,
                          height: 35,
                        ),
                        onPressed: () {
                          _showFilterOptions(context);
                        },
                      ),
                      if (countProductSync > 0)
                        ElevatedButton.icon(
                          onPressed: () {
                            sendProductIdempiereScreen();
                          },
                          icon: const Icon(Icons.sync),
                          label: const Text('Enviar Datos de Productos'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff7531ff),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      IconButton(
                          onPressed: () {
                            _loadProducts();
                          },
                          icon: const Icon(
                            Icons.refresh,
                            color: Color(0xFF7531ff),
                          ))
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          filteredProducts.length + 1, // +1 para el loader
                      itemBuilder: (context, index) {
                        // Manejo del loader al final
                        if (index >= filteredProducts.length) {
                          return _isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                )
                              : const SizedBox();
                        }

                        final product = filteredProducts[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          elevation: 3,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Container(
                            // Aquí hacemos el truco de la "Barra Lateral" usando un borde izquierdo grueso
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                left: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary, // El color "petróleo" de tu imagen
                                  width: 6.0, // El grosor de la barra
                                ),
                              ),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(15, 12, 15, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize
                                    .min, // Para que se ajuste al contenido
                                children: [
                                  Text(
                                    (product['name'] ?? 'SIN NOMBRE')
                                        .toString()
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins Bold',
                                      fontSize: 15,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary, // Mismo color de la barra
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 8),

                                  // 2. LOS DATOS (Como RIF, Correo, etc.)
                                  buildTextRow(
                                      'Código:', '${product['cod_product']}'),
                                  const SizedBox(height: 4),
                                  buildTextRow('Categoría:',
                                      '${product['tax_cat_name']}'),
                                  const SizedBox(height: 4),
                                  buildTextRow('Stock:',
                                      '${product['quantity'] ?? 0} ${product['um_name'] ?? ''}'),
                                  const SizedBox(height: 4),
                                  buildTextRow('Precio:',
                                      '${product['pricelistsales'] ?? 0}\$'),
                                  // const SizedBox(height: 4),
                                  // buildTextRow('Precio de Compra:',
                                  //     '${product['price'] ?? 0}\$'),

                                  // 3. BOTÓN VER (Alineado a la derecha como en la foto)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      onTap: () =>
                                          _verMasProducto('${product['id']}'),
                                      borderRadius: BorderRadius.circular(20),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Ver',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary, // Color acorde al diseño
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Poppins SemiBold',
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Icon(
                                              Icons
                                                  .remove_red_eye, // El ícono de ojo
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                  //esto para abajo es el navbar bottom
                ],
              ),
            ),
          ],
        ),
        // bottomNavigationBar: CustomBottomNavigationBar(
        //   onAddPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => const AddProductForm()),
        //     );
        //   },
        //   onRefreshPressed: () {
        //     _loadProducts();
        //   },
        //   onBackPressed: () {
        //     Navigator.pop(context);
        //   },
        // ),
      ),
    );
  }

  void _verMasProducto(String productId) async {
    print('productId: $productId'); // Añade esta línea para depurar

    final db = await DatabaseHelper.instance.database;
    if (db != null) {
      final product = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [int.parse(productId)],
      );
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product.first)),
      );
    } else {
      print('Error: db is null');
    }
  }
}
