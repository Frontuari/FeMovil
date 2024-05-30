import 'dart:convert';
import 'dart:io';

import 'package:femovil/config/app_bar_sampler.dart';
import 'package:femovil/config/getPosProperties.dart';
import 'package:femovil/database/gets_database.dart';
import 'package:femovil/database/insert_database.dart';
import 'package:femovil/presentation/orden_compra/product_selection.dart';
import 'package:femovil/presentation/perfil/perfil_http.dart';
import 'package:femovil/presentation/retenciones/helpers/search_providers.dart';
import 'package:femovil/presentation/retenciones/idempiere/create_factura_retencion.dart';
import 'package:femovil/presentation/screen/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class CrearRetenciones extends StatefulWidget {
  const CrearRetenciones({super.key});

  @override
  State<CrearRetenciones> createState() => _CrearRetencionesState();
}

class _CrearRetencionesState extends State<CrearRetenciones> {
  TextEditingController totalBdi = TextEditingController();
  TextEditingController numeroDocumentoController = TextEditingController();
  TextEditingController porcentaje = TextEditingController();
  TextEditingController numeroFacturaController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  TextEditingController fechaFacturacionController = TextEditingController();
  TextEditingController fechaIdempiereController = TextEditingController();
  final TextEditingController _establishmentController =
      TextEditingController();
  final TextEditingController _searchDialogController = TextEditingController();
  final TextEditingController _textTerceroController = TextEditingController();
  final TextEditingController _emisionController = TextEditingController();
  final TextEditingController _sriAuthorizationCodeController =
      TextEditingController();
  final TextEditingController _sequenceController = TextEditingController();
  final TextEditingController _cbPartnerIdController = TextEditingController();
  final TextEditingController _cbPartnerLocationIdController =
      TextEditingController();
  final TextEditingController _providerIdController = TextEditingController();
  TextEditingController saldoNetoController = TextEditingController();
  TextEditingController montoController = TextEditingController();
  TextEditingController saldoImpuestoController = TextEditingController();
  TextEditingController saldoExtentoController = TextEditingController();
  String? tipoRetencionSeleccionado = '';
  String? reglaRetencionSeleccionada = '';
  String? valorSeleccionado = '';
  String? impuestoValue = '';
  bool _isFocused = false;

  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();
  List<Map<String, dynamic>> ordenesSinRetencion = [];
  List<Map<String, dynamic>> selectedProducts = [];

  List<dynamic>? filteredTerceros;
  String? paymentTypeValue;
  String _selectTypePaymentRule = '';
  String? taxSustance;
  String _selectTaxSutance = "";
  Future<List<Map<String, dynamic>>>? _paymentTermsFuture;
  bool flag = false;
  double? saldoNeto;
  double? totalImpuesto;
  BuildContext? currentContext;
  bool _hasError = false;

  double calcularMontoTotal() {
    double total = 0;
    double totalNeto = 0;
    double suma = 0;
    double sumaExenta = 0;

    for (var product in selectedProducts) {
      total +=
          product['price'] * product['quantity'] * (product['impuesto'] / 100);
      totalNeto += product['price'] * product['quantity'];

          if(product['impuesto'] == 0.0 ){

           sumaExenta += product['price'] * product['quantity'];

          }


    }
    print('Esto es el total $total');
    saldoNetoController.text = '\$${totalNeto.toStringAsFixed(2)}';
    saldoExtentoController.text = '\$${sumaExenta.toStringAsFixed(2)}';
    suma = total + totalNeto;
    montoController.text = '\$${suma.toStringAsFixed(2)}';
    saldoImpuestoController.text = '\$${total.toStringAsFixed(2)}';

    print('productos totales $selectedProducts');

    return suma;
  }

  initV() async {
    if (variablesG.isEmpty) {
      List<Map<String, dynamic>> response = await getPosPropertiesV();
      print('variables Entre aqui');
      variablesG = response;
    }
    print('Estas son las variables globales $variablesG');
  }

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
        final availableQuantity = product['quantity_avaible'] ??
            0; // Obtener la cantidad disponible del producto
        final selectedQuantity =
            product['quantity']; // Obtener la cantidad seleccionada

        print("cantidad disponible $availableQuantity");

        // Si la cantidad seleccionada es menor o igual que la cantidad disponible, agregar el producto a la lista
        setState(() {
          selectedProducts.add(product);
        });
      }
    }
  }

  void _handlePriceChange(String newValue, int index) {
    final double newPrice = double.tryParse(newValue) ?? 0.0;
    setState(() {
      selectedProducts[index]['price'] = newPrice;
    });
  }

  void _removeProduct(int index) {
    setState(() {
      selectedProducts.removeAt(index);
      montoController.text = calcularMontoTotal().toString();
    });
  }

  @override
  void initState() {
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    if (mounted) {
      setState(() {
        _paymentTermsFuture = getPaymentTerms();
      });

      initV();

      fechaIdempiereController.text =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      fechaFacturacionController = TextEditingController(
          text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
      _focusNode.attach(context);
    }
    super.initState();
  }

  @override
  void dispose() {
    _searchDialogController.clear();
    fechaFacturacionController.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenMedia = MediaQuery.of(context).size.width * 0.8;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final scrennSelect = MediaQuery.of(context).size.width * 1;
    setState(() {
      currentContext = context;
    });

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: AppBarSample(label: 'Factura con Retencion')),
        body: Center(
          child: SizedBox(
            width: screenMedia,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    SizedBox(
                      height: screenHeight * 0.03,
                    ),
                    Container(
                      height: screenMedia * 0.20,
                      width: screenMedia * 0.95,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 7,
                                spreadRadius: 2)
                          ]),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: numeroDocumentoController,
                        decoration: InputDecoration(
                            labelText: 'Numero de documento',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 25, horizontal: 20),
                            labelStyle: const TextStyle(
                              fontFamily:
                                  'Poppins Regular', // Reemplaza con el nombre definido en pubspec.yaml
                              fontSize: 15.0, // Tamaño de la fuente
                              // Peso de la fuente (por ejemplo, bold)
                              color: Color.fromARGB(
                                  255, 0, 0, 0), // Color del texto
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide.none, // Color del borde
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 25,
                              ), // Color del borde cuando está enfocado
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 25,
                              ), // Color del borde cuando no está enfocado
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.red)),
                            errorStyle:
                                TextStyle(fontFamily: 'Poppins Regular')),
                        onChanged: (value) {
                          if (_hasError == false) {
                            setState(() {});
                          }

                          print('Este es el valor $value');
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Por favor, proporciona un numero de documento.";
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    Container(
                      height: screenMedia * 0.20,
                      width: screenMedia * 0.95,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 7,
                                spreadRadius: 2)
                          ]),
                      child: TextFormField(
                        readOnly: true,
                        controller: fechaFacturacionController,
                        decoration: InputDecoration(
                            labelText: 'Fecha de Facturacion',
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 25, horizontal: 20),
                            labelStyle: const TextStyle(
                              fontFamily:
                                  'Poppins Regular', // Reemplaza con el nombre definido en pubspec.yaml
                              fontSize: 15.0, // Tamaño de la fuente
                              // Peso de la fuente (por ejemplo, bold)
                              color: Color.fromARGB(
                                  255, 0, 0, 0), // Color del texto
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide.none, // Color del borde
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 25,
                              ), // Color del borde cuando está enfocado
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 25,
                              ), // Color del borde cuando no está enfocado
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.red))),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    Container(
                      height: screenMedia * 0.30,
                      width: screenMedia * 0.95,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 7,
                                spreadRadius: 2)
                          ]),
                      child: TextFormField(
                        controller: descripcionController,
                        decoration: InputDecoration(
                          labelText: 'Descripcion',
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 25, horizontal: 20),
                          labelStyle: const TextStyle(
                            fontFamily:
                                'Poppins Regular', // Reemplaza con el nombre definido en pubspec.yaml
                            fontSize: 15.0, // Tamaño de la fuente
                            // Peso de la fuente (por ejemplo, bold)
                            color:
                                Color.fromARGB(255, 0, 0, 0), // Color del texto
                          ),
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                            borderSide: BorderSide.none, // Color del borde
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 25,
                            ), // Color del borde cuando está enfocado
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 25,
                            ), // Color del borde cuando no está enfocado
                          ),
                        ),
                        onChanged: (value) {
                          if (_hasError == false) {
                            print('Entre aqui');
                            setState(() {});
                          }
                        },
                        maxLines: 2,
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                   TercerosFutureBuilder(onSelected: (bpName, cBpartnerId, cBpartnerLocationId, providerId, hasError) {

                            setState(() {
                              _hasError = hasError;
                                  _textTerceroController
                                                  .text =
                                              bpName
                                                  .toString();
                                          _cbPartnerIdController
                                                  .text =
                                              cBpartnerId
                                                  .toString();
                                          _cbPartnerLocationIdController
                                                  .text =
                                              cBpartnerLocationId
                                                  .toString();
                                          _providerIdController
                                                  .text =
                                              providerId
                                                  .toString();
                            });

                          

                   },),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _paymentTermsFuture,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(
                              child: Text('Error al cargar los datos'));
                        } else if (snapshot.hasData) {
                          // Creando una lista de DropdownMenuItems a partir de los datos
                          var dropdownItems = snapshot.data!
                              .map<DropdownMenuItem<int>>(
                                  (Map<String, dynamic> value) {
                            return DropdownMenuItem<int>(
                              value: value['c_paymentterm_id'],
                              child: Text(
                                value['name'].toString(),
                                style: TextStyle(fontFamily: 'Poppins Regular'),
                              ),
                            );
                          }).toList();

                          return Container(
                            width: screenMedia * 0.97,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 7,
                                      spreadRadius: 2,
                                      color: Colors.grey.withOpacity(0.5))
                                ]),
                            child: DropdownButtonFormField<int>(
                              icon: Image.asset('lib/assets/Abajo.png'),
                              validator: (value) {
                                if (value == null) {
                                  return 'Por Favor, selecciona un término de pago';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                focusedErrorBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.red)),
                                errorBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.red)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    borderSide: BorderSide(
                                        width: 25, color: Colors.white)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    borderSide: BorderSide(
                                        width: 25, color: Colors.white)),
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    borderSide: BorderSide.none),
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Poppins Regular',
                                ),
                                errorStyle:
                                    TextStyle(fontFamily: 'Poppins Regular'),
                                label: SizedBox(
                                    width: scrennSelect,
                                    child: Text(
                                      'Selecciona un término de pago',
                                    )),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 20),
                              ),
                              items: dropdownItems,
                              onChanged: (int? newValue) {
                                // Aquí puedes manejar el valor seleccionado
                                print("Selected value: $newValue");
                                if (_hasError == false) {
                                  setState(() {});
                                }
                              },
                            ),
                          );
                        } else {
                          return const Center(
                              child: Text('No hay datos disponibles'));
                        }
                      },
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    Container(
                      width: screenMedia * 0.97,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 7,
                                spreadRadius: 2,
                                color: Colors.grey.withOpacity(0.5))
                          ]),
                      child: DropdownButtonFormField<String>(
                        icon: Image.asset('lib/assets/Abajo.png'),
                        value: paymentTypeValue,
                        onChanged: (String? newValue) {
                          setState(() {
                            paymentTypeValue = newValue;
                          });

                          if (newValue == 'Caja de Punto de Venta') {
                            setState(() {
                              _selectTypePaymentRule = 'B';
                            });
                          } else if (newValue == 'Cheque') {
                            setState(() {
                              _selectTypePaymentRule = 'S';
                            });
                          } else if (newValue == "Con Término de Pago") {
                            setState(() {
                              _selectTypePaymentRule = 'P';
                            });
                          } else if (newValue == "Depósito Directo") {
                            setState(() {
                              _selectTypePaymentRule = 'T';
                            });
                          } else if (newValue == 'Multiples Medios de Pago') {
                            setState(() {
                              _selectTypePaymentRule = 'M';
                            });
                          } else if (newValue == 'Tarjeta De Crédito') {
                            setState(() {
                              _selectTypePaymentRule = 'K';
                            });
                          }

                          print(
                              'Este es el valor de paymentTypeValue $paymentTypeValue && este es el valor de $_selectTypePaymentRule');
                        },
                        items: <String>[
                          'Caja de Punto de Venta',
                          'Cheque',
                          'Con Término de Pago',
                          'Depósito Directo',
                          'Multiples Medios de Pago',
                          'Tarjeta De Crédito'
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(fontFamily: 'Poppins Regular'),
                            ),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                borderSide:
                                    BorderSide(width: 1, color: Colors.red)),
                            errorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                borderSide:
                                    BorderSide(width: 1, color: Colors.red)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                borderSide:
                                    BorderSide(width: 25, color: Colors.white)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                borderSide:
                                    BorderSide(width: 25, color: Colors.white)),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                borderSide: BorderSide.none),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 20),
                            label: SizedBox(
                                width: scrennSelect,
                                child: Text('Regla de Pago')),
                            labelStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontFamily: 'Poppins Regular',
                                height: 0.5),
                            errorStyle:
                                TextStyle(fontFamily: 'Poppins Regular')),
                        onTap: () {
                          if (_hasError == false) {
                            setState(() {});
                          }
                        },
                        validator: (value) {
                          if (value == null) {
                            return "Por Favor, selecciona una regla de pago";
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    Container(
                      height: screenMedia * 0.20,
                      width: screenMedia * 0.95,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 7,
                                spreadRadius: 2)
                          ]),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _sriAuthorizationCodeController,
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 25, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide.none, // Color del borde
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 25,
                              ), // Color del borde cuando está enfocado
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 25,
                              ), // Color del borde cuando no está enfocado
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.red)),
                            labelText: 'Codigo Autorizado por el SRI',
                            labelStyle: TextStyle(
                                fontFamily: 'Poppins Regular',
                                color: Colors.black),
                            filled: true,
                            fillColor: Colors.white,
                            errorStyle:
                                TextStyle(fontFamily: 'Poppins Regular')),
                        onChanged: (value) {
                          if (_hasError == false) {
                            setState(() {});
                          }
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Por Favor, Ingresa un Codigo Autorizado por el SRI";
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    Container(
                      height: screenMedia * 0.20,
                      width: screenMedia * 0.95,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 7,
                                spreadRadius: 2)
                          ]),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _establishmentController,
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 25, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide.none, // Color del borde
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 25,
                              ), // Color del borde cuando está enfocado
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 25,
                              ), // Color del borde cuando no está enfocado
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.red)),
                            labelText: 'Establecimiento',
                            errorStyle:
                                TextStyle(fontFamily: 'Poppins Regular'),
                            labelStyle: TextStyle(
                                fontFamily: 'Poppins Regular',
                                color: Colors.black),
                            filled: true,
                            fillColor: Colors.white),
                        onChanged: (value) {
                          if (_hasError == false) {
                            setState(() {});
                          }
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Por Favor, ingrese un establecimiento";
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    Container(
                      height: screenMedia * 0.20,
                      width: screenMedia * 0.95,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 7,
                                spreadRadius: 2)
                          ]),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _emisionController,
                        onChanged: (value) {
                          if (_hasError == false) {
                            setState(() {});
                          }
                        },
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 25, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide.none, // Color del borde
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 25,
                              ), // Color del borde cuando está enfocado
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 25,
                              ), // Color del borde cuando no está enfocado
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.red)),
                            labelText: 'Emisión',
                            labelStyle: TextStyle(
                                fontFamily: 'Poppins Regular',
                                color: Colors.black),
                            filled: true,
                            fillColor: Colors.white,
                            errorStyle:
                                TextStyle(fontFamily: 'Poppins Regular')),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Por Favor, ingresa el numero de emision";
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    Container(
                      height: screenMedia * 0.20,
                      width: screenMedia * 0.95,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 7,
                                spreadRadius: 2)
                          ]),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _sequenceController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 25, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                            borderSide: BorderSide.none, // Color del borde
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 25,
                            ), // Color del borde cuando está enfocado
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 25,
                            ), // Color del borde cuando no está enfocado
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.red)),
                          labelStyle: TextStyle(
                              fontFamily: 'Poppins Regular',
                              color: Colors.black),
                          errorStyle: TextStyle(fontFamily: 'Poppins Regular'),
                          labelText: 'Secuencia',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          if (_hasError == false) {
                            setState(() {});
                          }
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Por Favor, ingrese el numero de secuencia";
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    Container(
                      width: screenMedia * 0.95,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 7,
                                spreadRadius: 2,
                                color: Colors.grey.withOpacity(0.5))
                          ]),
                      child: DropdownButtonFormField<String>(
                        icon: Image.asset('lib/assets/Abajo.png'),
                        value: taxSustance,
                        onChanged: (String? newValue) {
                          setState(() {
                            taxSustance = newValue;
                          });

                          if (newValue ==
                              'Crédito Tributario para declaración de IVA') {
                            setState(() {
                              _selectTaxSutance = '01';
                            });
                          } else if (newValue ==
                              'Costo o Gasto para declaración de Imp. a la Renta') {
                            setState(() {
                              _selectTaxSutance = '02';
                            });
                          } else if (newValue == "Activo Fijo") {
                            setState(() {
                              _selectTaxSutance = '03';
                            });
                          } else if (newValue ==
                              "Activo Fijo - Costo o Gasto") {
                            setState(() {
                              _selectTaxSutance = '04';
                            });
                          } else if (newValue ==
                              'Liquidación de Gastos de Viaje, hospedaje y Alimentación') {
                            setState(() {
                              _selectTaxSutance = '05';
                            });
                          } else if (newValue ==
                              'Inventario - Crédito Tributario para la declaración de IVA') {
                            setState(() {
                              _selectTaxSutance = '06';
                            });
                          } else if (newValue ==
                              'Inventario - Costo o Gasto para declaración de Imp.') {
                            setState(() {
                              _selectTaxSutance = '07';
                            });
                          } else if (newValue ==
                              'Valor pagado para solicitar Reembolso de Gastos') {
                            setState(() {
                              _selectTaxSutance = '08';
                            });
                          } else if (newValue == 'Reembolso por Siniestros') {
                            setState(() {
                              _selectTaxSutance = '09';
                            });
                          } else if (newValue ==
                              'Distribución de Dividendos, Beneficios o Utilidades') {
                            setState(() {
                              _selectTaxSutance = '10';
                            });
                          } else if (newValue ==
                              'Impuestos y retenciones presuntivos') {
                            setState(() {
                              _selectTaxSutance = '11';
                            });
                          } else if (newValue ==
                              'Valores reconocidos por entidades del sector público') {
                            setState(() {
                              _selectTaxSutance = '12';
                            });
                          }

                          print(
                              'Este es el valor de Sustento Tributario $taxSustance && este es el valor de $_selectTaxSutance');
                        },
                        items: <String>[
                          'Crédito Tributario para declaración de IVA',
                          'Costo o Gasto para declaración de Imp. a la Renta',
                          'Activo Fijo',
                          'Activo Fijo - Costo o Gasto',
                          'Liquidación de Gastos de Viaje, hospedaje y Alimentación',
                          'Inventario - Crédito Tributario para la declaración de IVA',
                          'Inventario - Costo o Gasto para declaración de Imp.',
                          'Valor pagado para solicitar Reembolso de Gastos',
                          'Reembolso por Siniestros',
                          'Distribución de Dividendos, Beneficios o Utilidades',
                          'Impuestos y retenciones presuntivos',
                          'Valores reconocidos por entidades del sector público'
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: SizedBox(
                                width: screenMedia,
                                child: Text(
                                  value,
                                  overflow: TextOverflow
                                      .ellipsis, // Para manejar texto largo
                                )),
                          );
                        }).toList(),
                        isExpanded: true,
                        decoration: InputDecoration(
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide:
                                  BorderSide(width: 1, color: Colors.red)),
                          errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide:
                                  BorderSide(width: 1, color: Colors.red)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide:
                                  BorderSide(width: 25, color: Colors.white)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide:
                                  BorderSide(width: 25, color: Colors.white)),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide.none),
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Poppins Regular',
                          ),
                          errorStyle: TextStyle(fontFamily: 'Poppins Regular'),
                          label: SizedBox(
                              width: scrennSelect,
                              child: Text(
                                'Sustento Tributario',
                              )),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 20),
                        ),
                        onTap: () {
                          if (_hasError == false) {
                            setState(() {});
                          }
                        },
                        validator: (value) {
                          if (value == null) {
                            return "Por Favor, selecciona un sustento tributario";
                          }

                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.05,
                    ),
                    const Text(
                      'Productos',
                      style:
                          TextStyle(fontFamily: 'Poppins Bold', fontSize: 18),
                    ),
                    SizedBox(
                      height: screenHeight * 0.03,
                    ),
                    Container(
                      width: screenMedia * 0.97,
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
                                                      child: Text(
                                                          product['name'])),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  GestureDetector(
                                                      onTap: () {
                                                        if (product[
                                                                'quantity'] <=
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
                                                        const EdgeInsets.all(
                                                            1.0),
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
                                                          calcularMontoTotal();
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
                                                        BorderRadius.circular(
                                                            15),
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
                                                          '\$${calcularMontoTotal()}';
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
                                      _addOrUpdateProduct(
                                          selectedProductsResult);

                                      montoController.text =
                                          '\$${calcularMontoTotal()}';
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
                                  saldoExtentoController.text,
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
                   
                    const SizedBox(
                      height: 5,
                    ),
                    Center(
                      child: SizedBox(
                        width: screenMedia,
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              width: screenMedia * 0.97,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    foregroundColor:
                                        WidgetStatePropertyAll(Colors.white),
                                    backgroundColor: WidgetStatePropertyAll(
                                        Color(0xFF7531FF)),
                                    shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)))),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final info =
                                        await getApplicationSupportDirectory();
                                    print("esta es la ruta ${info.path}");

                                    final String filePathEnv =
                                        '${info.path}/.env';
                                    final File archivo = File(filePathEnv);
                                    String contenidoActual =
                                        await archivo.readAsString();
                                    print(
                                        'Contenido actual del archivo:\n$contenidoActual');

                                    // Convierte el contenido JSON a un mapa
                                    Map<String, dynamic> jsonData =
                                        jsonDecode(contenidoActual);
                                    print(
                                        'Esto es cbpartnerId ${_cbPartnerIdController.text} ');
                                    print(
                                        'Esto es provider id ${_providerIdController.text}');
                                    print(
                                        'Esto es el cbpartnerlocationid ${_cbPartnerLocationIdController.text}');
                                    print('Esto es el jsonData $jsonData');

                                    dynamic userId = await getLogin();

                                    Map<String, dynamic> nuevaRetencion = {
                                      'ad_client_id': jsonData['ClientID'],
                                      'ad_org_id': jsonData['OrgID'],
                                      'c_bpartner_id':
                                          _cbPartnerIdController.text,
                                      'c_bpartner_location_id':
                                          _cbPartnerLocationIdController.text,
                                      'c_currency_id': variablesG[0]
                                          ['c_currency_id'],
                                      'c_doctypetarget_id': variablesG[0]
                                          ['c_doc_type_target_fr'],
                                      'c_paymentterm_id': variablesG[0]
                                          ['c_paymentterm_id'],
                                      'description': descripcionController.text,
                                      'documentno':
                                          numeroDocumentoController.text,
                                      'date': fechaFacturacionController.text,
                                      'is_sotrx': 'N',
                                      'm_pricelist_id': variablesG[0]
                                          ['m_pricelist_id'],
                                      'payment_rule': _selectTypePaymentRule,
                                      'date_invoiced':
                                          fechaIdempiereController.text,
                                      'date_acct':
                                          fechaIdempiereController.text,
                                      'sales_rep_id': userId['userId'],
                                      'sri_authorization_code':
                                          _sriAuthorizationCodeController.text,
                                      'ing_establishment':
                                          _establishmentController.text,
                                      'ing_emission': _emisionController.text,
                                      'ing_sequence': _sequenceController.text,
                                      'ing_taxsustance': _selectTaxSutance,
                                      'provider_id': _providerIdController.text,
                                      'monto': double.parse(
                                          montoController.text.substring(1)),
                                      'productos': selectedProducts,
                                    };

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
                                                  Navigator.pop(
                                                      context); // Cerrar el diálogo
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      return;
                                    }

                                    print(
                                        'Esto es la factura con retencion $nuevaRetencion');
                                    createInvoicedWithholdingIdempiere(
                                        nuevaRetencion);
                                    insertRetencion(nuevaRetencion);
                                    _formKey.currentState?.reset();

                                    totalBdi.clear();
                                    numeroDocumentoController.clear();
                                    porcentaje.clear();

                                    // Mostrar un mensaje al usuario
                                    ScaffoldMessenger.of(currentContext!)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Retención creada exitosamente'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                    // Navigator.pop(context);
                                  } else {
                                    setState(() {
                                      _hasError = true;
                                    });
                                  }
                                },
                                child: const Text(
                                  'Crear retención',
                                  style: TextStyle(
                                      fontFamily: 'Poppins Bold', fontSize: 17),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
