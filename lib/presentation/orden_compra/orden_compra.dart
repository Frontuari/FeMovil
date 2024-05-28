import 'dart:convert';
import 'dart:io';

import 'package:femovil/config/app_bar_sampler.dart';
import 'package:femovil/config/getPosProperties.dart';
import 'package:femovil/database/create_database.dart';
import 'package:femovil/database/insert_database.dart';
import 'package:femovil/presentation/orden_compra/product_selection.dart';
import 'package:femovil/presentation/orden_venta/product_selection.dart';
import 'package:femovil/presentation/perfil/perfil_http.dart';
import 'package:femovil/presentation/screen/home/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart'; // Importa la librería de formateo de fechas

class OrdenDeCompraScreen extends StatefulWidget {
  final int providerId;
  final String providerName;
  final int cBPartnerID;
  final int cBPartnerLocationId;
  final String rucProvider;
  final String emailProvider;
  final String phoneProvider;
  const OrdenDeCompraScreen(
      {super.key,
      required this.providerId,
      required this.providerName,
      required this.cBPartnerID,
      required this.cBPartnerLocationId,
      required this.rucProvider,
      required this.emailProvider,
      required this.phoneProvider});

  @override
  _OrdenDeCompraScreenState createState() => _OrdenDeCompraScreenState();
}

class _OrdenDeCompraScreenState extends State<OrdenDeCompraScreen> {
  TextEditingController numeroReferenciaController = TextEditingController();
  TextEditingController fechaController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  TextEditingController montoController = TextEditingController();
  TextEditingController numeroFacturaController = TextEditingController();
  TextEditingController saldoNetoController = TextEditingController();
  TextEditingController fechaIdempiereController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController saldoImpuestoController = TextEditingController();
  TextEditingController saldoExentoController = TextEditingController();
  
  List<Map<String, dynamic>> selectedProducts = [];
  DateTime selectedDate = DateTime.now();
  double? saldoNeto;
  double? totalImpuesto;
  Map<String, dynamic> infoUserForOrder = {};

  double calcularSaldoNetoProducto(cantidadProducts, price) {
    double multi =
        (cantidadProducts as num).toDouble() * (price as num).toDouble();

    saldoNeto = multi;

    return multi;
  }

  double calcularMontoImpuesto(impuesto, monto) {
    double montoImpuesto = monto * impuesto / 100;

    totalImpuesto = montoImpuesto;

    print(
        'El monto $monto y el impuesto $impuesto y el monto impuesto seria $montoImpuesto');
    return montoImpuesto;
  }

dynamic calcularMontoTotal() {
  double total = 0;
  double totalNeto = 0;
  double suma = 0;
  double saldoExento = 0.0;

  // Formateador para el monto total y neto
  final formatter = NumberFormat('#,##0.00', 'es_ES');

  for (var product in selectedProducts) {
    double price = double.tryParse(product['price'].toString().replaceAll(',', '.')) ?? 0;
    double quantity = double.tryParse(product['quantity'].toString()) ?? 0;
    double impuesto = double.tryParse(product['impuesto'].toString()) ?? 0;

    total += price * quantity * (impuesto / 100);
    totalNeto += price * quantity;

    if(product['impuesto'] == 0.0){

        saldoExento += price * quantity;

    }

  }

  saldoExentoController.text = '\$ ${formatter.format(saldoExento)}';
  saldoNetoController.text = '\$ ${formatter.format(totalNeto)}';
  suma = total + totalNeto;
  montoController.text = '\$ ${formatter.format(suma)}';
  print('productos totales $selectedProducts');
    print('Esto es la suma $suma');
    saldoImpuestoController.text = '\$ ${formatter.format(total)}';


  String parseFormatNumber = formatter.format(suma);

  return parseFormatNumber;
}

  initGetUser() async {
    final info = await getApplicationSupportDirectory();
    print("esta es la ruta ${info.path}");

    final String filePathEnv = '${info.path}/.env';
    final File archivo = File(filePathEnv);
    String contenidoActual = await archivo.readAsString();

    Map<String, dynamic> infoLogin = await getLogin();
    Map<String, dynamic> jsonData = jsonDecode(contenidoActual);

    var orgId = jsonData["OrgID"];
    var clientId = jsonData["ClientID"];
    var wareHouseId = jsonData["WarehouseID"];

    print('Esto es infologin $infoLogin');

    // Map<String, dynamic> getUser = await getUsers(username, password);

    setState(() {
      infoUserForOrder = {
        'orgid': orgId,
        'clientid': clientId,
        'warehouseid': wareHouseId,
        'userId': infoLogin['userId']
      };
    });

    print('infouserFororder $infoUserForOrder');
  }

  initV() async {
    if (variablesG.isEmpty) {
      List<Map<String, dynamic>> response = await getPosPropertiesV();
      setState(() {
        variablesG = response;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: currentDate,
      lastDate: currentDate,
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        fechaController.text = DateFormat('dd/MM/yyyy')
            .format(selectedDate); // Formato día/mes/año
      });
    }
  }

  void _addOrUpdateProduct(List<Map<String, dynamic>> products) {
    for (var product in products) {
      int index = selectedProducts
          .indexWhere((element) => element['name'] == product['name']);
      if (index != -1) {
        // Si el producto ya existe, actualizar la cantidad
        setState(() {
          selectedProducts[index]['quantity'] += product['quantity'];
        });
      } else {
        // Si el producto no existe, verificar la disponibilidad antes de agregarlo
        final selectedQuantity =
            product['quantity']; // Obtener la cantidad seleccionada

        if (selectedQuantity == 0) {
          // Si la cantidad seleccionada es mayor que la cantidad disponible, mostrar un mensaje de error
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Error'),
                content:
                    Text('No hay suficientes ${product['name']} disponibles.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Cerrar el diálogo
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          // Si la cantidad seleccionada es menor o igual que la cantidad disponible, agregar el producto a la lista
          setState(() {
            selectedProducts.add(product);
          });
        }
      }
    }
  }

  void _handlePriceChange(String newValue, int index) {
    final String normalizedValue = newValue.replaceAll(',', '.');
    final double newPrice = double.tryParse(normalizedValue) ?? 0.0;

    

    setState(() {
      selectedProducts[index]['price'] = newPrice ;
    });
  }

  void _removeProduct(int index) {
    setState(() {
      selectedProducts.removeAt(index);
      montoController.text = '\$ ${calcularMontoTotal()}';
    });
  }

  @override
  void initState() {
    initV();
    initGetUser();
    fechaController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    fechaIdempiereController.text =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate);
    print("Esto es el id ${widget.providerId}");
    print("Esto es el name ${widget.providerName}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenMedia = MediaQuery.of(context).size.width * 0.8;
    final screenHeight = MediaQuery.of(context).size.height * 0.8;

    return Scaffold(
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBarSample(label: 'Orden de Compra')),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: screenMedia,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: screenHeight * 0.03,
                  ),
                  const Text(
                    'Datos del Proveedor',
                    style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 18),
                  ),
                  SizedBox(
                    height: screenHeight * 0.03,
                  ),
                  Container(
                    width: screenMedia,
                    height: screenHeight * 0.35,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 7,
                              spreadRadius: 2)
                        ]),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                    width: screenMedia * 0.5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Nombre',
                                          style: TextStyle(
                                            fontFamily: 'Poppins Bold',
                                            fontSize: 18,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                        SizedBox(
                                          height: screenHeight * 0.02,
                                        ),
                                        SizedBox(
                                          width: screenMedia * 0.45,
                                        ),
                                        Text(
                                          widget.providerName,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins Regular',
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                      ],
                                    )),
                                SizedBox(
                                  width: screenMedia * 0.3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Ruc/DNI',
                                        style: TextStyle(
                                          fontFamily: 'Poppins Bold',
                                          fontSize: 18,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                      SizedBox(
                                        height: screenMedia * 0.03,
                                      ),
                                      Center(
                                          child: Text(
                                        '${widget.rucProvider.toString()}',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins Regular',
                                        ),
                                        textAlign: TextAlign.start,
                                      ))
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: screenMedia * 0.03,
                            ),
                            SizedBox(
                              width: screenMedia,
                              child: const Text(
                                'Detalles',
                                style: TextStyle(
                                    fontFamily: 'Poppins Bold', fontSize: 18),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            SizedBox(
                              height: screenMedia * 0.03,
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Correo: ',
                                  style:
                                      TextStyle(fontFamily: 'Poppins SemiBold'),
                                ),
                                Flexible(
                                    child: Text(
                                  widget.emailProvider != '{@nil=true}'
                                      ? widget.emailProvider
                                      : '',
                                  style: const TextStyle(
                                      fontFamily: 'Poppins Regular'),
                                ))
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Telefono: ',
                                  style: TextStyle(
                                      fontFamily: 'Poppins SemiBold',
                                      overflow: TextOverflow.clip),
                                ),
                                Flexible(
                                    child: Text(
                                  widget.phoneProvider != '{@nil=true}'
                                      ? widget.phoneProvider
                                      : '',
                                  style: const TextStyle(
                                      fontFamily: 'Poppins Regular'),
                                ))
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.05,
                  ),
                  const Text(
                    'Detalles de Orden',
                    style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 18),
                  ),
                  SizedBox(
                    height: screenHeight * 0.05,
                  ),
                  Container(
                    width: screenMedia,
                    height: screenHeight * 0.1,
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 7,
                              spreadRadius: 2)
                        ]),
                    child: TextField(
                      readOnly: true,
                      controller: numeroReferenciaController,
                      decoration: const InputDecoration(
                          labelText: 'Número de Documento',
                          labelStyle: TextStyle(
                              fontFamily: 'Poppins Regular',
                              color: Colors.black),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide:
                                  BorderSide(width: 25, color: Colors.white)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide:
                                  BorderSide(width: 25, color: Colors.white)),
                          disabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide:
                                  BorderSide(width: 25, color: Colors.white)),
                          errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide:
                                  BorderSide(width: 25, color: Colors.white)),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 25)),
                    ),
                  ),
                  SizedBox(
                    height: screenMedia * 0.03,
                  ),
                  Container(
                    width: screenMedia,
                    height: screenHeight * 0.1,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 7,
                              spreadRadius: 2)
                        ]),
                    child: TextField(
                      controller: numeroFacturaController,
                      decoration: const InputDecoration(
                          labelText: 'Número de Factura',
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 25,
                              )),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 25,
                              )),
                          errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 25,
                              )),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 25),
                          labelStyle: TextStyle(
                              fontFamily: 'Poppins Regular',
                              color: Colors.black)),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(
                    height: screenMedia * 0.03,
                  ),
                  Container(
                    width: screenMedia,
                    height: screenHeight * 0.1,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 7,
                              spreadRadius: 2)
                        ]),
                    child: TextField(
                      controller: fechaController,
                      decoration: InputDecoration(
                          labelText: 'Fecha',
                          suffixIcon: IconButton(
                            onPressed: () => _selectDate(context),
                            icon: Image.asset('lib/assets/Calendario.png'),
                          ),
                          border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide.none),
                          focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 25,
                              )),
                          enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 25,
                              )),
                          labelStyle: const TextStyle(
                              fontFamily: 'Poppins Regular',
                              color: Colors.black),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 25)),
                      readOnly: true,
                    ),
                  ),
                  SizedBox(
                    height: screenMedia * 0.03,
                  ),
                  Container(
                    width: screenMedia,
                    height: screenHeight * 0.18,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 7,
                              spreadRadius: 2)
                        ]),
                    child: TextField(
                      maxLines: 2,
                      controller: descripcionController,
                      decoration: const InputDecoration(
                          labelText: 'Descripción',
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 25,
                              )),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 25,
                              )),
                          labelStyle: TextStyle(
                              fontFamily: 'Poppins Regular',
                              color: Colors.black),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 25)),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.05,
                  ),
                  const Text(
                    'Productos',
                    style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 18),
                  ),
                  SizedBox(
                    height: screenHeight * 0.03,
                  ),
                  Container(
                    width: screenMedia,
                    height: screenHeight * 0.32,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 7,
                              spreadRadius: 2)
                        ]),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Nombre',
                                    style: TextStyle(
                                        fontFamily: 'Poppins Bold',
                                        fontSize: 18),
                                  ),
                                  Text(
                                    'Cant.',
                                    style: TextStyle(
                                        fontFamily: 'Poppins Bold',
                                        fontSize: 18),
                                  ),
                                  Text(
                                    'Precio',
                                    style: TextStyle(
                                        fontFamily: 'Poppins Bold',
                                        fontSize: 18),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: selectedProducts.length,
                                itemBuilder: (context, index) {
                                  final product = selectedProducts[index];

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        _removeProduct(index);
                                                      });
                                                    },
                                                    child: Image.asset(
                                                        'lib/assets/Eliminar.png')),
                                                SizedBox(
                                                  width: screenMedia * 0.01,
                                                ),
                                                SizedBox(
                                                    width: screenMedia * 0.23,
                                                    child:
                                                        Text(product['name'])),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                GestureDetector(
                                                    onTap: () {
                                                      if (product['quantity'] <=
                                                          0) {
                                                        return;
                                                      }

                                                      setState(() {
                                                        product['quantity'] -=
                                                            1;
                                                        calcularMontoTotal();

                                                        print(
                                                            'Productos ${product['quantity_avaible']}');
                                                      });
                                                    },
                                                    child: Image.asset(
                                                      'lib/assets/menos.png',
                                                      width: 16,
                                                    )),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(1.0),
                                                  child: SizedBox(
                                                    width: screenMedia * 0.15,
                                                    child: Text(
                                                      product['quantity']
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              'Poppins Regular'),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        product['quantity'] +=
                                                            1;
                                                        calcularMontoTotal()
                                                            ;
                                                      });
                                                    },
                                                    child: Image.asset(
                                                      'lib/assets/Más-2.png',
                                                      width: 16,
                                                    )),
                                              ],
                                            ),
                                            Container(
                                              width: screenMedia * 0.2,
                                              height: screenHeight * 0.06,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Color(int.parse(
                                                            '0xFF7531FF')),
                                                        blurRadius: 7,
                                                        spreadRadius: 2)
                                                  ]),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                initialValue:
                                                    '${product['price']}', // Valor inicial del precio
                                                decoration:
                                                    const InputDecoration(
                                                        border:
                                                            OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide
                                                                        .none),
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        2)),

                                                onChanged: (newValue) {
                                                  _handlePriceChange(
                                                      newValue, index);

                                                  setState(() {
                                                    montoController.text =
                                                        '\$ ${calcularMontoTotal()}';
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: screenHeight * 0.01,
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              width: screenMedia,
                              height: screenHeight * 0.07,
                            )
                          ],
                        ),
                        Positioned(
                          top: screenHeight * 0.26,
                          left: screenMedia * 0.45,
                          child: GestureDetector(
                              onTap: () async {
                                final selectedProductsResult =
                                    await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ProductSelectionComprasScreen()),
                                );
                                print(
                                    "Cantidad de productos $selectedProductsResult");
                                if (selectedProductsResult != null) {
                                  setState(() {
                                    _addOrUpdateProduct(selectedProductsResult);

                                    montoController.text =
                                        '\$ ${calcularMontoTotal()}';
                                  });
                                }
                              },
                              child: Image.asset(
                                'lib/assets/Más@3x.png',
                                width: 23,
                              )),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'SubTotal',
                              style: TextStyle(
                                  fontFamily: 'Poppins Regular', fontSize: 18),
                            ),
                            Text(
                              saldoNetoController.text,
                              style: const TextStyle(
                                  fontFamily: 'Poppins Regular', fontSize: 18),
                            )
                          ],
                        ),    
                         Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Exento',
                              style: TextStyle(
                                  fontFamily: 'Poppins Regular', fontSize: 18),
                            ),
                            Text(
                              saldoExentoController.text,
                              style: const TextStyle(
                                  fontFamily: 'Poppins Regular', fontSize: 18),
                            )
                          ],
                        ),
                         Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Impuesto',
                              style: TextStyle(
                                  fontFamily: 'Poppins Regular', fontSize: 18),
                            ),
                            Text(
                              saldoImpuestoController.text,
                              style: const TextStyle(
                                  fontFamily: 'Poppins Regular', fontSize: 18),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                  fontFamily: 'Poppins Bold', fontSize: 18),
                            ),
                            Text(
                              montoController.text,
                              style: const TextStyle(
                                  fontFamily: 'Poppins Bold', fontSize: 18),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () {
                      // Aquí puedes realizar la transacción y guardar la orden de venta en la base de datos
                      // con los datos proporcionados
                      // Por ejemplo:

                      //  if (descripcionController.text.isEmpty) {
                      //           setState(() {
                      //             _validateDescription = true; // Marcar como campo inválido si está vacío
                      //           });

                      //                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:  Text('Por favor ingrese una descripción.')));

                      //           return; // Detener el proceso de agregar la orden si el campo está vacío
                      //     }

                      if (selectedProducts.isEmpty) {
                        // Mostrar un diálogo o mensaje indicando que la orden debe tener productos adjuntos
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: const Text(
                                  'La orden debe tener productos adjuntos.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Cerrar el diálogo
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );

                        return;
                      }

                      print('Esto es el monto ${montoController.text}');

                      final order = {
                        'proveedor_id': widget.providerId,
                        'documentno': numeroReferenciaController.text,
                        'c_doc_type_target_id': variablesG[0]
                            ['c_doc_type_order_co'],
                        'ad_client_id': infoUserForOrder['clientid'],
                        'ad_org_id': infoUserForOrder['orgid'],
                        'm_warehouse_id': infoUserForOrder['warehouseid'],
                        'payment_rule': 'B',
                        'dateordered': fechaIdempiereController.text,
                        'sales_rep_id': infoUserForOrder['userId'],
                        'c_bpartner_id': widget.cBPartnerID,
                        'c_bpartner_location_id': widget.cBPartnerLocationId,
                        'm_price_list_id': variablesG[0]['m_pricelist_id'],
                        'c_currency_id': 100,
                        'c_payment_term_id': variablesG[0]['c_paymentterm_id'],
                        'c_conversion_type_id': variablesG[0]
                            ['c_conversion_type_id'],
                        'po_reference': numeroFacturaController.text,
                        'id_factura': 0,
                        'fecha': fechaController.text,
                        'description': descripcionController.text,
                        'monto': montoController.text.substring(2),
                        'saldo_neto': saldoNetoController.text.substring(2),
                        'productos': selectedProducts,
                        'usuario_id': infoUserForOrder['userId'],
                        'saldo_exento': saldoExentoController.text.substring(2),
                        'saldo_impuesto': saldoImpuestoController.text.substring(2),
                        'status_sincronized': 'Borrador',
                      };

                      // Luego puedes guardar la orden de venta en la base de datos o enviarla al servidor
                      insertOrderCompra(order).then((orderId) {
                        // Limpiar los campos después de guardar la orden
                        if (orderId is Map<String, dynamic> &&
                            orderId.containsKey('failure')) {
                          if (orderId['failure'] == -1) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  orderId['Error'],
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                        } else {
                          print(
                              'orderId no es un mapa válido o no contiene la propiedad "failure"');
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Orden de venta guardada correctamente con ID: $orderId'),
                          ),
                        );

                        numeroReferenciaController.clear();
                        descripcionController.clear();
                        montoController.clear();
                        numeroFacturaController.clear();
                        saldoNetoController.clear();

                        // Limpiar la lista de productos seleccionados después de guardar la orden
                        setState(() {
                          selectedProducts.clear();
                        });

                        // Notificar al usuario que la orden se ha guardado exitosamente
                      });
                    },
                    style: ButtonStyle(
                        foregroundColor:
                            const WidgetStatePropertyAll(Colors.white),
                        backgroundColor: WidgetStatePropertyAll(
                            Color(int.parse('0xFF7531FF')))),
                    child: const Text(
                      'Completar',
                      style:
                          TextStyle(fontFamily: 'Poppins Bold', fontSize: 15),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.05,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
