import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:femovil/config/app_bar_sampler.dart';
import 'package:femovil/config/getPosProperties.dart';
import 'package:femovil/database/gets_database.dart';
import 'package:femovil/database/insert_database.dart';
import 'package:femovil/presentation/orden_venta/product_selection.dart';
import 'package:femovil/presentation/perfil/perfil_http.dart';
import 'package:femovil/presentation/screen/home/home_screen.dart';
import 'package:femovil/presentation/screen/ventas/idempiere/create_orden_sales.dart';
import 'package:femovil/presentation/screen/ventas/ventas.dart';
import 'package:femovil/presentation/screen/ventas/ventas_details.dart';
import 'package:femovil/utils/alerts_messages.dart';
import 'package:femovil/utils/searck_key_idempiere.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart'; // Importa la librería de formateo de fechas

class OrdenDeVentaScreen extends StatefulWidget {
  final int clientId;
  final String clientName;
  final int cBPartnerId;
  final int? cBPartnerLocationId;
  final String rucCbpartner;
  final String emailCustomer;
  final String phoneCustomer;

  const OrdenDeVentaScreen(
      {super.key,
      required this.clientId,
      required this.clientName,
      required this.cBPartnerId,
      required this.cBPartnerLocationId,
      required this.rucCbpartner,
      required this.emailCustomer,
      required this.phoneCustomer});

  @override
  _OrdenDeVentaScreenState createState() => _OrdenDeVentaScreenState();
}

class _OrdenDeVentaScreenState extends State<OrdenDeVentaScreen> {
  TextEditingController numeroReferenciaController = TextEditingController();
  TextEditingController fechaController = TextEditingController();
  TextEditingController fechaIdempiereController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  TextEditingController montoController = TextEditingController();
  TextEditingController saldoNetoController = TextEditingController();
  TextEditingController saldoImpuestoController = TextEditingController();
  TextEditingController saldoExentoController = TextEditingController();
  List<Map<String, dynamic>> selectedProducts = [];
  DateTime selectedDate = DateTime.now();
  double? saldoNeto;
  double? totalImpuesto;
  Map<String, dynamic> infoUserForOrder = {};
  bool isDragging = false;
  bool enableButton = true;
  dynamic rucCliente='';

 dynamic calcularMontoTotal() {
  double total = 0;
  double totalNeto = 0;
  double suma = 0;
  double saldoExento = 0;

  // Formateador para el monto total y neto
  final formatter = NumberFormat('#,##0.00', 'es_ES');

  for (var product in selectedProducts) {
    double price = double.tryParse(product['price'].toString().replaceAll(',', '.')) ?? 0;
    double quantity = double.tryParse(product['quantity'].toString()) ?? 0;
    double impuesto = double.tryParse(product['impuesto'].toString()) ?? 0;

    if(impuesto == 0.0){
      saldoExento = price * quantity;
    }

    total += price * quantity * (impuesto / 100);
    totalNeto += price * quantity;
  }

  saldoExentoController.text = '\$ ${formatter.format(saldoExento)}';
  saldoImpuestoController.text = '\$ ${formatter.format(total)}';

  saldoNetoController.text = '\$ ${formatter.format(totalNeto)}';
  suma = total + totalNeto;
  montoController.text = '\$ ${formatter.format(suma)}';
  

  String parseFormatNumber = formatter.format(suma);


  return parseFormatNumber;

}

  double calcularSaldoTotalProducts(dynamic price, dynamic quantity) {
    double prices;
    double quantitys;

    // Verificar si quantity es un String
    if (quantity is String || price is String) {
      // Intentar convertir el String a un número
      try {
        quantitys = double.parse(quantity).toDouble();
        prices = double.parse(price).toDouble();
      } catch (e) {
        print('Error al convertir quantity a double: $e');
        // Si hay un error, establecer quantitys como 0
        prices = 0.0;
        quantitys = 0.0;
      }
    } else {
      // Si quantity no es un String, asumir que es numérico
      quantitys = quantity.toDouble();
      prices = price.toDouble();
    }
    double sum = prices * quantitys;

    print('price $price & quantity is $quantity');
    print('Suma es $sum');
    return sum;
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
        final availableQuantity = product['quantity_avaible'] ??
            0; // Obtener la cantidad disponible del producto

        print("cantidad disponible $availableQuantity");

      
          // Si la cantidad seleccionada es menor o igual que la cantidad disponible, agregar el producto a la lista
          setState(() {
            selectedProducts.add(product);
          });
        
      }
    }
  }

  void _removeProduct(int index) {
    
    setState(() {
      
      selectedProducts.removeAt(index);
      montoController.text = '\$ ${calcularMontoTotal()}';

    });
    

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

  @override
  void initState() {
    initV();
    initGetUser();
    print('infouser $infoUserForOrder');
    print('infouser $variablesG');
    fechaController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    print("Esto es el id ${widget.clientId}");
    print("Esto es el name ${widget.clientName}");
    fechaIdempiereController.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaScreen = MediaQuery.of(context).size.width * 0.8;

Color getColor(Set<WidgetState> states){

    const Set<WidgetState> interactiveStates = <WidgetState>{

        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused

    };
    if(states.any(interactiveStates.contains)){
      return Colors.black;
    }


    return Colors.white;

}


Color getColorBg(Set<WidgetState> states){

    const Set<WidgetState> interactiveStates = <WidgetState>{

        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused

    };
    if(states.any(interactiveStates.contains)){
      return Colors.white;
    }


    return const Color(0xff7531FF);

}

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: const PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: AppBarSample(label: 'Orden de Venta')),
        body: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: mediaScreen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: mediaScreen * 0.05,
                  ),
                  SizedBox(
                    width: mediaScreen,
                    child: const Text(
                      "Datos del Cliente",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins Bold',
                          fontSize: 18),
                    ),
                  ),
                  SizedBox(
                    height: mediaScreen * 0.05,
                  ),
                  Container(
                    width: mediaScreen,
                    height: mediaScreen * 0.7,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 7,
                              spreadRadius: 2,
                              color: Colors.grey.withOpacity(0.5))
                        ]),
                   child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: mediaScreen * 0.5,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Nombre', style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 18)),
                                      Text(widget.clientName.length > 25
                                          ? widget.clientName.substring(0, 25)
                                          : widget.clientName)
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: mediaScreen * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('RUC/DNI', style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 18)),
                                      Text(widget.rucCbpartner.length > 15 ? widget.rucCbpartner.substring(0, 15) : widget.rucCbpartner),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            width: mediaScreen,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Detalles',
                                style: TextStyle(
                                    fontFamily: 'Poppins Bold', fontSize: 18),
                                textAlign: TextAlign.start,
                              ),
                            )),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Correo: ', style: TextStyle(fontFamily: 'Poppins SemiBold')),
                              Text(widget.emailCustomer == '{@nil: true}' ? '' : widget.emailCustomer, style: const TextStyle(
                                fontFamily: 'Poppins Regular'),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Telefono: ', style: TextStyle(fontFamily: 'Poppins SemiBold')),
                              Text(widget.phoneCustomer == '{@nil: true}' ? '' : widget.phoneCustomer, style: const TextStyle(
                                fontFamily: 'Poppins Regular'),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: mediaScreen * 0.08,
                  ),
                  SizedBox(
                    width: mediaScreen,
                    child: const Text(
                      "Detalles de Orden",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins Bold',
                          fontSize: 18),
                    ),
                  ),
                  SizedBox(
                    height: mediaScreen * 0.05,
                  ),
                  Container(
                    width: mediaScreen,
                    height: mediaScreen * 0.20,
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
                      enabled: false,
                      controller: numeroReferenciaController,
                      decoration: const InputDecoration(
                        labelStyle: TextStyle(fontFamily: 'Poppins Regular', color: Colors.black),
                        labelText: 'Orden N°',
                        contentPadding: EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15.0)), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15.0)), borderSide: BorderSide(color: Colors.white, width: 25)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15.0)), borderSide: BorderSide(color: Colors.white, width: 25)),
                        filled: true,
                        fillColor: Color(0xFFE0E0E0),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(
                    height: mediaScreen * 0.05,
                  ),
                  Container(
                    width: mediaScreen,
                    height: mediaScreen * 0.20,
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
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                                const BorderSide(width: 1, color: Colors.red)),
                        labelText: 'Fecha',
                        labelStyle: const TextStyle(
                            fontFamily: 'Poppins Regular', color: Colors.black),
                        suffixIcon: IconButton(
                          onPressed: () => _selectDate(context),
                          icon: Image.asset('lib/assets/Calendario.png'),
                        ),
                      ),
                      readOnly: true,
                    ),
                  ),
                  SizedBox(
                    height: mediaScreen * 0.05,
                  ),
                  Container(
                    width: mediaScreen,
                    height: mediaScreen * 0.28,
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
                        labelStyle: TextStyle(
                            fontFamily: 'Poppins Regular', color: Colors.black),
                        labelText: 'Descripción',
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          borderSide: BorderSide.none, // Color del borde
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 25,
                          ), // Color del borde cuando está enfocado
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 25,
                          ), // Color del borde cuando no está enfocado
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: mediaScreen * 0.08,
                  ),
                  SizedBox(
                    width: mediaScreen,
                    child: const Text(
                      "Productos",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins Bold',
                          fontSize: 18),
                    ),
                  ),
                  SizedBox(
                    height: mediaScreen * 0.05,
                  ),
                  Container(
                    width: mediaScreen,
                    height: mediaScreen * 0.5,
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
                                  horizontal: 20, vertical: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Nombre',
                                    style: TextStyle(
                                        fontFamily: 'Poppins Bold',
                                        fontSize: 15),
                                  ),
                                  Text('Cant.',
                                      style: TextStyle(
                                          fontFamily: 'Poppins Bold',
                                          fontSize: 15)),
                                  Text('Subtotal',
                                      style: TextStyle(
                                          fontFamily: 'Poppins Bold',
                                          fontSize: 15))
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                shrinkWrap:
                                    true, // Asegura que el ListView tome solo el espacio que necesita
                                itemCount: selectedProducts.length,
                                itemBuilder: (context, index) {
                                  final product = selectedProducts[index];

                                  return Column(children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 0),
                                      child: SizedBox(
                                        width: mediaScreen * 0.95,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                               GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            _removeProduct(
                                                                index);
                                                          });
                                                        },
                                                        child: Image.asset(
                                                            'lib/assets/Eliminar.png')),
                                                            const SizedBox(width: 5,),
                                              SizedBox(
                                                  width: 70,
                                                  child: Text(product['name'])),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.1,
                                              ),
                                              GestureDetector(
                                                  onTap: () {
                                                    if (product['quantity'] <=  1) {
                                                      return;
                                                    }

                                                    setState(() {
                                                      product['quantity'] -= 1;
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
                                                    const EdgeInsets.all(8.0),
                                                child: Text(product['quantity']
                                                    .toString()),
                                              ),
                                              GestureDetector(
                                                  onTap: () {
                                                

                                                    setState(() {
                                                      product['quantity'] += 1;
                                                      calcularMontoTotal();
                                                    });
                                                  },
                                                  child: Container(
                                                      child: Image.asset(
                                                    'lib/assets/Más-2.png',
                                                    width: 16,
                                                  ))),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.13,
                                              ),
                                              SizedBox(
                                                width: mediaScreen * 0.25,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                        child: Text(
                                                            '\$${calcularSaldoTotalProducts(product['price'].toString(), product['quantity'].toString())}')),
                                                   
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]);
                                },
                              ),
                            ),
                          SizedBox(
                            width: mediaScreen,
                            height: mediaScreen * 0.13,
                          )
                          ],
                        ),
                        Positioned(
                          top: mediaScreen * 0.40,
                          left: mediaScreen * 0.45,
                          child: GestureDetector(
                              onTap: () async {
                                final selectedProductsResult =
                                    await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ProductSelectionScreen()),
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
                  SizedBox(height: mediaScreen * 0.1,),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal ,
                    child: SizedBox(
                      width: mediaScreen,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                           Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('SubTotal', style: TextStyle(fontFamily: 'Poppins Regular', fontSize: 18),),
                              Text(saldoNetoController.text, style: const TextStyle(fontFamily: 'Poppins Regular', fontSize: 18),)
                            ],
                          ),
                           Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Exento', style: TextStyle(fontFamily: 'Poppins Regular', fontSize: 18),),
                              Text(saldoExentoController.text, style: const TextStyle(fontFamily: 'Poppins Regular', fontSize: 18),)
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Impuesto', style: TextStyle(fontFamily: 'Poppins Regular', fontSize: 18),),
                              Text(saldoImpuestoController.text, style: const TextStyle(fontFamily: 'Poppins Regular', fontSize: 18),)
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total', style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 18),),
                              Text(montoController.text, style: const TextStyle(fontFamily: 'Poppins Bold', fontSize: 18),)
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                
                SizedBox(height: mediaScreen * 0.1,),

              
                  SizedBox(
                    width: mediaScreen,
                    height: mediaScreen * 0.15,
                    child: ElevatedButton(
                      
                      style: ButtonStyle(
                        textStyle: WidgetStateProperty.all<TextStyle>(const TextStyle(
                          fontFamily: 'Poppins Bold'
                        )),
                        foregroundColor: WidgetStateProperty.resolveWith(getColor),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)
                        )),
                        animationDuration: Duration.zero,
                        elevation: WidgetStateProperty.all(0.5),
                        backgroundColor: WidgetStateProperty.resolveWith(getColorBg)
                      ),                      
                      onPressed: enableButton ? () async{              
                        if (infoUserForOrder.isNotEmpty) {                                    
                          if (selectedProducts.isEmpty) {                   
                            ErrorMessage.showErrorMessageDialog(context, 'Debe agregar al menos un producto a la orden de venta.');

                            return;
                          }

                          setState(() {
                            enableButton = false;
                          });

                          final order = {
                            'cliente_id': widget.clientId,
                            'documentno': numeroReferenciaController.text,
                            'fecha': fechaController.text,
                            'descripcion': descripcionController.text,
                            'monto': montoController.text.substring(2),
                            'saldo_neto': saldoNetoController.text.substring(2),
                            'productos': selectedProducts,
                            'c_bpartner_id': widget.cBPartnerId,
                            'c_bpartner_location_id': widget.cBPartnerLocationId,
                            'c_doctypetarget_id': variablesG[0]['c_doc_type_order_id'],
                            'ad_client_id': infoUserForOrder['clientid'],
                            'ad_org_id': infoUserForOrder['orgid'],
                            'm_warehouse_id': infoUserForOrder['warehouseid'],
                            'paymentrule': 'P',
                            'date_ordered': fechaIdempiereController.text,
                            'salesrep_id': infoUserForOrder['userId'],
                            'usuario_id': infoUserForOrder['userId'],
                            'saldo_exento': saldoExentoController.text.substring(2),
                            'saldo_impuesto' : saldoImpuestoController.text.substring(2),
                            'status_sincronized': 'Borrador',
                          };
                          rucCliente= widget.rucCbpartner;

                          // Luego puedes guardar la orden de venta en la base de datos o enviarla al servidor
                     
                          await insertOrder(order).then((orderId) async {
                            print('Se guardo la orden: $orderId');
                          
                            final orderCreateIdempiere = {
                              'client': [{'id': widget.clientId,}],
                              'order':{
                                'id': orderId,
                                'documentno': numeroReferenciaController.text,
                                'fecha': fechaController.text,
                                'descripcion': descripcionController.text,
                                'monto': montoController.text.substring(2),
                                'saldo_neto': saldoNetoController.text.substring(2),
                                'c_bpartner_id': widget.cBPartnerId,
                                'c_bpartner_location_id': widget.cBPartnerLocationId,
                                'c_doctypetarget_id': variablesG[0]['c_doc_type_order_id'],
                                'ad_client_id': infoUserForOrder['clientid'],
                                'ad_org_id': infoUserForOrder['orgid'],
                                'm_warehouse_id': infoUserForOrder['warehouseid'],
                                'paymentrule': 'P',
                                'date_ordered': fechaIdempiereController.text,
                                'salesrep_id': infoUserForOrder['userId'],
                                'usuario_id': infoUserForOrder['userId'],
                                'saldo_exento': saldoExentoController.text.substring(2),
                                'saldo_impuesto' : saldoImpuestoController.text.substring(2),
                                'status_sincronized': 'Borrador'
                              },
                              'products': selectedProducts,
                            };

                          try {
                      showLoadingDialog(   context, message: 'Enviando Orden de Venta...');
                        final result = await createOrdenSalesIdempiere(orderCreateIdempiere);
                      Navigator.of(context).pop(); // cerrar el diálogo de carga

                        print("RESULTADO DE LA FUNCIÓN: $result");

                        // Caso: sin conexión o error interno (retorna false)
                        if (result == false) {

                            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                          WarningMessages.showWarningMessagesDialog(
                            context,
                            'Sin Conexión, Envie La Orden de Venta Individualmente N° $rucCliente'
                          );
                       
                    
                          return;
                        }
                        else{
                         final documentNo = findValueByColumn(result, "DocumentNo") ?? "Sin Número";
                        
                          print("NUMERO DE DOCUMENTO: $documentNo");
                          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                          SuccesMessages.showSuccesMessagesDialog(
                            context,
                            'Orden de Venta Enviada Correctamente\nN° $documentNo',
                          );
                    }

                      } catch (err) {
                        ErrorMessage.showErrorMessageDialog(
                          context,
                          'Error inesperado: $err',
                          goBack: true,
                        );
                        setState(() => enableButton = true);
                      }

                      
                            // Notificar al usuario que la orden se ha guardado exitosamente
                          });
                        }
                      } : null,
                      child: Text(!enableButton ? 'Procesando...' : 'Agregar Orden'),
                    ),
                  ),                
                  SizedBox(height: mediaScreen * 0.1,),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
