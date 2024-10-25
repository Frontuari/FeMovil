import 'package:femovil/config/app_bar_femovil.dart';
import 'package:femovil/config/getOrgInfo.dart';
import 'package:femovil/database/gets_database.dart';
import 'package:femovil/presentation/perfil/perfil_http.dart';
import 'package:femovil/presentation/screen/ventas/ventas_details.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';


class Product {
  dynamic name;
  int quantity;
  double price;
  double subtotal;

  Product({
    required this.name,
    required this.quantity,
    required this.price,
    required this.subtotal
  });
}

class Ventas extends StatefulWidget {
  const Ventas({super.key});

  @override
  State<Ventas> createState() => _VentasState();
}

class _VentasState extends State<Ventas> {
  String _filter = "";
  DateTimeRange? _selectedDateRange; // Declare and initialize to null

  late List<Map<String, dynamic>> ventas = [];
  List<Map<String, dynamic>> filteredVentas = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController inputValue = TextEditingController();
  Map userInfo = {};
  Map orgInfo = {};

  String input = "";
  int? searchValue;

  Future<void> _loadVentas() async {
    final ventasData  = await getAllOrdersWithClientNames(); // Cambiar a la función de obtener ventas
    final userData    = await getLogin();
    final orgData     = await getOrgInfo();

    setState(() {
      ventas = ventasData;
      filteredVentas = ventasData;
      userInfo = userData;
      orgInfo = orgData;
    });
  }

  @override
  void initState() {
    _loadVentas();
    super.initState();
  }

  double parseNumberToDouble(String number) {
  number = number.replaceAll('.', '').replaceAll(',', '.');
  return double.parse(number);
}

  void _filterByMaxPrice(double maxPrice) {
    setState(() {
        filteredVentas = ventas.where((venta) {
    double monto = parseNumberToDouble(venta['monto']);
    return monto <= maxPrice;
  }).toList();

  filteredVentas.sort((a, b) {
    double montoA = parseNumberToDouble(a['monto']);
    double montoB = parseNumberToDouble(b['monto']);
    return montoB.compareTo(montoA);
  }); 
    });
  }

  void _showDateRangePicker(BuildContext context) async {
    // Enhanced user experience with custom date range and better initial selection
    final picked = await showDateRangePicker(
      context: context,
      locale: const Locale("es", "ES"), 
      initialDateRange: DateTimeRange(
        start: DateTime.now()
            .subtract(const Duration(days: 7)), // Default to past week
        end: DateTime.now(),
      ),
      firstDate:
          DateTime(2010), // Adjust minimum year based on your requirements
      lastDate: DateTime.now()
          .add(const Duration(days: 365)), // Extend to a year from now
    );

    print("esto es picked $picked");
    if (picked != null) {
      print("Entre aqui");
      setState(() {
        _selectedDateRange = picked;
        _sortByDateRange(picked.start, picked.end);
      });
    }
  }

  void _sortByDateRange(DateTime start, DateTime end) {
    // Guardar start y end en variables locales
    final startDate = start;
    final endDate = end;

    print("fecha start $start y fecha end $end");
    setState(() {
      filteredVentas = ventas.where((venta) {
        final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
        try {
          if (venta['fecha'] != null && venta['fecha'] != '') {
            print("ventas  ${venta['fecha']}");
            final ventaDate = dateFormat.parse(venta['fecha']);
            return ventaDate
                    .isAfter(startDate.subtract(const Duration(days: 1))) &&
                ventaDate.isBefore(endDate.add(const Duration(days: 1)));
          } else {
            // La fecha está en blanco, por lo tanto, no cumple con la condición
            return false;
          }
        } catch (e) {
          print('Error al parsear la fecha: $e');
          return false; // O maneja el error de otra manera
        }
      }).toList();
      print("entre aqui para el sort o algoritmo de ordenamiento");
      print("FItered Ventas $filteredVentas ");
      // Ordena las ventas dentro del rango de fechas seleccionado
      filteredVentas.sort((a, b) {
        final DateFormat inputFormat = DateFormat('dd/MM/yyyy');
        final DateTime dateA = inputFormat.parse(a['fecha']);
        final DateTime dateB = inputFormat.parse(b['fecha']);

        // Formatea las fechas como "yyyy-mm-dd" antes de compararlas
        final String formattedDateA =
            '${dateA.year}-${dateA.month.toString().padLeft(2, '0')}-${dateA.day.toString().padLeft(2, '0')}';
        final String formattedDateB =
            '${dateB.year}-${dateB.month.toString().padLeft(2, '0')}-${dateB.day.toString().padLeft(2, '0')}';

        return formattedDateA.compareTo(formattedDateB);
      });
    });
  }


  void _showMaxPriceDialog(BuildContext context, screenMedia) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          elevation: 0,
          title: const Text('Ingrese el monto máximo'),
          content: Container(
            width: screenMedia,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 7,
                      spreadRadius: 2)
                ]),
            child: TextField(
              controller: inputValue, // Controlador para el campo de entrada
              keyboardType: TextInputType
                  .number, // Teclado numérico para ingresar el monto
              decoration: const InputDecoration(
                  hintText: 'Ingrese el monto máximo',
                  contentPadding: EdgeInsets.all(10),
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(width: 1, color: Colors.white))
                      ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                inputValue.clear();
              },
              child: const Text('Cancelar', style: TextStyle(fontFamily: 'Poppins SemiBold', color: Colors.red),),
            ),
            TextButton(
              onPressed: () {
                // Obtener el valor ingresado por el usuario

                final double maxPrice = double.tryParse(inputValue.text) ??
                    0.0; // Convertir a double
                print("esto es el maxprice ${inputValue.text}");
                _filterByMaxPrice(maxPrice);
                Navigator.of(context).pop();
                inputValue.clear();
              },
              child: const Text('Aceptar', style: TextStyle(fontFamily: 'Poppins SemiBold', color: Color(0xFF7531ff)),),
            ),
          ],
        );
      },
    );
  }

  void _showFilterOptions(BuildContext context, colorPrimary, screenMax) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      shape: RoundedRectangleBorder(
          // Redondear los bordes del menú emergente
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            width: 5,
            color: Colors.grey.withOpacity(
                0.5), // Establece el color transparente como punto inicial del gradiente
          )),
      elevation: 2,
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          const Offset(20, 250), // Punto de inicio en la esquina superior izquierda
        const Offset(155, 240),  // Punto de fin en la esquina superior izquierda
        ),
        overlay.localToGlobal(Offset.zero) & overlay.size, // Tamaño del overlay
      ),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: ListTile(
            title: Row(
              children: [
                Image.asset(
                  'lib/assets/Check@3x.png',
                  width: 25,
                  color: const Color(0xFF7531ff),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.02,
                ),
                const Text(
                  'Mostrar Todos',
                  style: TextStyle(fontFamily: 'Poppins Regular'),
                ),
              ],
            ),
            onTap: () {
              Navigator.pop(context);
              _loadVentas();
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            title: Row(
              children: [
                Image.asset(
                  'lib/assets/Check@3x.png',
                  width: 25,
                  color: const Color(0xFF7531ff),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.02,
                ),
                const Text(
                  'Filtrar Por el monto Mayor',
                  style: TextStyle(fontFamily: 'Poppins Regular'),
                ),
              ],
            ),
            onTap: () {
              Navigator.pop(context);
              _showMaxPriceDialog(context, screenMax);
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            title: Row(
              children: [
                Image.asset(
                  'lib/assets/Check@3x.png',
                  width: 25,
                  color: const Color(0xFF7531ff),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.02,
                ),
                const Text(
                  'Ordenar por un rango de fecha',
                  style: TextStyle(fontFamily: 'Poppins Regular'),
                ),
              ],
            ),
            onTap: () {
              Navigator.pop(context);
              _showDateRangePicker(context);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenMax = MediaQuery.of(context).size.width * 0.8;
    final colorPrimary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () {

          FocusScope.of(context).requestFocus(FocusNode());

      },
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(170),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const AppBars(
                  labelText: 'Ventas',
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
                        onChanged: (value) {
                          if (searchController.text.isNotEmpty) {
                            setState(() {
                              _filter = "";
                            });
                          }
      
                          setState(() {
                            input = value.toLowerCase();
                            setState(() {
                              filteredVentas = ventas.where((venta) {
                                final numeroReferencia = venta['id'].toString();
                                final nombreCliente = venta['nombre_cliente']
                                    .toString()
                                    .toLowerCase();
                                final orderSale = venta['documentno'].toString();
                                return numeroReferencia.contains(input) ||
                                    nombreCliente.contains(input) ||
                                    orderSale.contains(input);
                              }).toList();
                            });
                          });
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
            )),
        body: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  // Cierra el teclado tocando en cualquier parte del Stack
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 25,
                    ),
                    IconButton(
                      icon: Image.asset(
                        'lib/assets/filtro@3x.png',
                        width: 25,
                        height: 35,
                      ),
                      onPressed: () {
                        _showFilterOptions(context, colorPrimary, screenMax);
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredVentas.length,
                        itemBuilder: (context, index) {
                          final venta = filteredVentas[index];
      
                          print('Esta es la venta: $venta');
      
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: screenMax,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 160,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(255, 255, 255, 255),
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              top: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                height: 50,
                                                width: screenMax,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF0EBFC),
                                                  borderRadius: BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey.withOpacity(0.2),
                                                      spreadRadius: 2,
                                                      blurRadius: 5,
                                                      offset: const Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                  child: Row( 
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        venta['documentno'] == '' ? 'N° ${venta['ruc'].toString()}' : 'N° ${venta['documentno'].toString()}',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontFamily: 'Poppins Bold',
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                        ),
                                                        textAlign: TextAlign.start,
                                                      ),
                                                      PopupMenuButton(
                                                        onSelected: (value) async {
                                                          if (value == 'PREVIEW') {
                                                            final pdf = pw.Document();

                                                            dynamic orderData = await getOrderWithProducts(venta["id"]);
                                                            var orderClient   = orderData["client"][0];
                                                            var orderInfo     = orderData["order"];
                                                            var orderProducts = orderData["products"];

                                                            DateTime orderDateParsed = DateTime.parse(orderData["order"]["date_ordered"]);
                                                            String orderDate = DateFormat('dd/MM/yyyy').format(orderDateParsed);
                                                            String orderTime = DateFormat('HH:mm').format(orderDateParsed);

                                                            List<List<dynamic>> productList = [];
                                                            orderProducts.map((product) {
                                                              dynamic productQty      = product['qty_entered'];
                                                              dynamic productName     = product['name'];
                                                              dynamic productPrice    = product['price_actual'];
                                                              dynamic productSubtotal = double.parse(product['price_actual'].toString()) * int.parse(product['qty_entered'].toString());

                                                              productList.add([
                                                                productQty, 
                                                                productName,
                                                                productPrice, 
                                                                productSubtotal
                                                              ]);
                                                            }).toList();

                                                            pdf.addPage(
                                                              pw.Page(
                                                                pageFormat: PdfPageFormat.roll57,
                                                                margin: pw.EdgeInsets.all(5),
                                                                orientation: pw.PageOrientation.portrait,
                                                                build: (pw.Context context) {
                                                                  return pw.ListView(
                                                                    children: [
                                                                      // NOMBRE ORGANIZACION
                                                                      orgInfo.isNotEmpty && orgInfo["name"].toString() != 'null' ? pw.Text(
                                                                        orgInfo["name"].toString(), 
                                                                        style: pw.TextStyle(fontSize: 6.0, fontWeight: pw.FontWeight.bold), 
                                                                        textAlign: pw.TextAlign.center
                                                                      ) : pw.SizedBox(),
                                                                      orgInfo.isNotEmpty && orgInfo["name"].toString() != 'null' 
                                                                        ? pw.SizedBox(height: 3) 
                                                                        : pw.SizedBox(),

                                                                      // RUC ORGANIZACION
                                                                      orgInfo.isNotEmpty && orgInfo["ruc"].toString() != 'null' ? pw.Text( 
                                                                        orgInfo["ruc"].toString(), 
                                                                        style: pw.TextStyle(fontSize: 6.0, fontWeight: pw.FontWeight.bold), 
                                                                        textAlign: pw.TextAlign.center
                                                                      ) : pw.SizedBox(),
                                                                      orgInfo.isNotEmpty && orgInfo["ruc"].toString() != 'null' 
                                                                        ? pw.SizedBox(height: 3) 
                                                                        : pw.SizedBox(),

                                                                      // DIRECCION ORGANIZACION
                                                                      orgInfo.isNotEmpty && orgInfo["address"].toString() != 'null' ? pw.Text(
                                                                        orgInfo["address"].toString(), 
                                                                        style: pw.TextStyle(fontSize: 6.0), textAlign: pw.TextAlign.center
                                                                      ) : pw.SizedBox(),
                                                                      orgInfo.isNotEmpty && orgInfo["address"].toString() != 'null' 
                                                                        ? pw.SizedBox(height: 10) 
                                                                        : pw.SizedBox(),


                                                                      pw.Text('OBLIGADO A LLEVAR CONTABILIDAD: SI', style: pw.TextStyle(fontSize: 5.5), textAlign: pw.TextAlign.center),
                                                                      pw.SizedBox(height: 3),
                                                                      pw.Text('AGENTE DE RETENCION', style: pw.TextStyle(fontSize: 5.5)),
                                                                      pw.SizedBox(height: 3),
                                                                      pw.Text('Resolucion No.: 1', style: pw.TextStyle(fontSize: 5.5)),
                                                                      pw.SizedBox(height: 8),


                                                                      pw.Row(
                                                                        children: [
                                                                          pw.Text('NO. FACTURA ', style: pw.TextStyle(fontSize: 5.5)),
                                                                          pw.Text(orderInfo["documentno_factura"], style: pw.TextStyle(fontSize: 5.5)),
                                                                        ]
                                                                      ),
                                                                      pw.SizedBox(height: 12),


                                                                      // VA UN CAMPO MAS AQUI (**PREGUNTAR**) aparece null en factura: autenticacion


                                                                      pw.Row(
                                                                        children: [                                                                          
                                                                          pw.Expanded(
                                                                            child: pw.Row(
                                                                              children: [
                                                                                pw.Text('AMBIENTE: ', style: pw.TextStyle(fontSize: 5.5)),
                                                                                pw.Text('PRODUCCION', style: pw.TextStyle(fontSize: 5.5)),
                                                                              ]
                                                                            )
                                                                          ),
                                                                          pw.Expanded(
                                                                            child: pw.Row(
                                                                              children: [
                                                                                pw.Text('EMISION: ', style: pw.TextStyle(fontSize: 5.5)),
                                                                                pw.Text('NORMAL', style: pw.TextStyle(fontSize: 5.5)),
                                                                              ]
                                                                            )
                                                                          ),
                                                                        ]
                                                                      ),
                                                                      pw.SizedBox(height: 3), 
                                                                      pw.Row(
                                                                        children: [                                                                          
                                                                          pw.Expanded(
                                                                            child: pw.Row(
                                                                              children: [
                                                                                pw.Text('FECHA: ', style: pw.TextStyle(fontSize: 5.5)),
                                                                                pw.Text(orderDate, style: pw.TextStyle(fontSize: 5.5)),
                                                                              ]
                                                                            )
                                                                          ),
                                                                          pw.Expanded(
                                                                            child: pw.Row(
                                                                              children: [
                                                                                pw.Text('HORA: ', style: pw.TextStyle(fontSize: 5.5)),
                                                                                pw.Text(orderTime, style: pw.TextStyle(fontSize: 5.5)),
                                                                              ]
                                                                            )
                                                                          ),
                                                                        ]
                                                                      ), 
                                                                      pw.SizedBox(height: 3),  
                                                                      pw.Row(
                                                                        children: [
                                                                          pw.Text('CLIENTE: ', style: pw.TextStyle(fontSize: 5.5)),
                                                                          pw.Text(orderClient["bp_name"], style: pw.TextStyle(fontSize: 5.5)),
                                                                        ]
                                                                      ),
                                                                      pw.SizedBox(height: 3),  
                                                                      pw.Row(
                                                                        children: [
                                                                          pw.Text('RUC/CI: ', style: pw.TextStyle(fontSize: 5.5)),
                                                                          pw.Text(orderClient["ruc"], style: pw.TextStyle(fontSize: 5.5)),
                                                                        ]
                                                                      ),
                                                                      pw.SizedBox(height: 3),    
                                                                      pw.Row(
                                                                        children: [
                                                                          pw.Text('DIRECCION: ', style: pw.TextStyle(fontSize: 5.5)),
                                                                          pw.Text(
                                                                            orderClient["address"].toString(), 
                                                                            style: pw.TextStyle(fontSize: 5.5)
                                                                          ),
                                                                        ]
                                                                      ),
                                                                      pw.SizedBox(height: 20), 


                                                                      // LISTADO DE PRODUCTOS
                                                                      pw.TableHelper.fromTextArray(
                                                                        headers: ['CANT.', 'PRODUCTO', 'P. U.', 'P. TOT.'],
                                                                        border: null,
                                                                        //cellHeight: 5.0,
                                                                        data: productList,
                                                                        headerStyle: pw.TextStyle(fontSize: 5.0, fontWeight: pw.FontWeight.bold),
                                                                        cellStyle: pw.TextStyle(fontSize: 6.0),
                                                                        headerAlignments: {
                                                                          0: pw.Alignment.centerLeft,
                                                                          1: pw.Alignment.centerLeft,
                                                                          2: pw.Alignment.centerLeft,
                                                                          3: pw.Alignment.centerLeft,
                                                                        },
                                                                        cellAlignments: {
                                                                          0: pw.Alignment.centerLeft,
                                                                          1: pw.Alignment.centerLeft,
                                                                          2: pw.Alignment.centerRight,
                                                                          3: pw.Alignment.centerRight,
                                                                        },
                                                                      ),
                                                                      pw.SizedBox(height: 5),


                                                                      // SUBTOTAL 12%
                                                                      pw.Row(
                                                                        children: [
                                                                          pw.Expanded(
                                                                            flex: 2,
                                                                            child: pw.Text('SUBTOTAL 12%: ', style: pw.TextStyle(
                                                                              fontSize: 5.5, 
                                                                              fontWeight: pw.FontWeight.bold
                                                                            ), textAlign: pw.TextAlign.right)
                                                                          ),
                                                                          pw.Expanded(child: pw.Text('0.00', style: pw.TextStyle(fontSize: 5.5), textAlign: pw.TextAlign.right))                                                                          
                                                                        ]
                                                                      ),
                                                                      pw.SizedBox(height: 3.0),
                                                                      // SUBTOTAL 0%
                                                                      pw.Row(
                                                                        children: [
                                                                          pw.Expanded(
                                                                            flex: 2,
                                                                            child: pw.Text('SUBTOTAL 0%: ', style: pw.TextStyle(
                                                                              fontSize: 5.5, 
                                                                              fontWeight: pw.FontWeight.bold
                                                                            ), textAlign: pw.TextAlign.right)
                                                                          ),
                                                                          pw.Expanded(child: pw.Text('0.00', style: pw.TextStyle(fontSize: 5.5), textAlign: pw.TextAlign.right))                                                                          
                                                                        ]
                                                                      ),
                                                                      pw.SizedBox(height: 3.0),
                                                                      // DESCUENTO
                                                                      pw.Row(
                                                                        children: [
                                                                          pw.Expanded(
                                                                            flex: 2,
                                                                            child: pw.Text('DESCUENTO: ', style: pw.TextStyle(
                                                                              fontSize: 5.5, 
                                                                              fontWeight: pw.FontWeight.bold
                                                                            ), textAlign: pw.TextAlign.right)
                                                                          ),
                                                                          pw.Expanded(child: pw.Text('0.00', style: pw.TextStyle(fontSize: 5.5), textAlign: pw.TextAlign.right))
                                                                        ]
                                                                      ),
                                                                      pw.SizedBox(height: 3.0),
                                                                      // SUBTOTAL
                                                                      pw.Row(
                                                                        children: [
                                                                          pw.Expanded(
                                                                            flex: 2,
                                                                            child: pw.Text('SUBTOTAL: ', style: pw.TextStyle(
                                                                              fontSize: 5.5, 
                                                                              fontWeight: pw.FontWeight.bold
                                                                            ), textAlign: pw.TextAlign.right)
                                                                          ),
                                                                          pw.Expanded(child: pw.Text(orderInfo["saldo_neto"], style: pw.TextStyle(fontSize: 5.5), textAlign: pw.TextAlign.right))
                                                                        ]
                                                                      ),
                                                                      pw.SizedBox(height: 3.0),
                                                                      // CE
                                                                      pw.Row(
                                                                        children: [
                                                                          pw.Expanded(
                                                                            flex: 2,
                                                                            child: pw.Text('CE: ', style: pw.TextStyle(
                                                                              fontSize: 5.5, 
                                                                              fontWeight: pw.FontWeight.bold
                                                                            ), textAlign: pw.TextAlign.right)
                                                                          ),
                                                                          pw.Expanded(child: pw.Text(orderInfo["saldo_exento"], style: pw.TextStyle(fontSize: 5.5), textAlign: pw.TextAlign.right))
                                                                        ]
                                                                      ),
                                                                      pw.SizedBox(height: 3.0),
                                                                      // IVA 12
                                                                      pw.Row(
                                                                        children: [
                                                                          pw.Expanded(
                                                                            flex: 2,
                                                                            child: pw.Text('IVA 12: ', style: pw.TextStyle(
                                                                              fontSize: 5.5, 
                                                                              fontWeight: pw.FontWeight.bold
                                                                            ), textAlign: pw.TextAlign.right)
                                                                          ),
                                                                          pw.Expanded(child: pw.Text(orderInfo["saldo_impuesto"], style: pw.TextStyle(fontSize: 5.5), textAlign: pw.TextAlign.right))
                                                                        ]
                                                                      ),
                                                                      pw.SizedBox(height: 3.0),
                                                                      // TOTAL
                                                                      pw.Row(
                                                                        children: [
                                                                          pw.Expanded(
                                                                            flex: 2,
                                                                            child: pw.Text('TOTAL: ', style: pw.TextStyle(
                                                                              fontSize: 5.5, 
                                                                              fontWeight: pw.FontWeight.bold
                                                                            ), textAlign: pw.TextAlign.right)
                                                                          ),
                                                                          pw.Expanded(child: pw.Text(orderInfo["saldo_total_formatted"], style: pw.TextStyle(fontSize: 5.5), textAlign: pw.TextAlign.right))
                                                                        ]
                                                                      ),
                                                                      pw.SizedBox(height: 20),


                                                                      pw.SizedBox(
                                                                        child: pw.Text(
                                                                          'SU COMPROBANTE SERA ENVIADO A: ${orderClient["email"]} PARA CONSULTAR SU FACTURA INGRESE A WWW.SRI.GOB.EC SRI EN LINEA',
                                                                          style: pw.TextStyle(fontSize: 5.5)
                                                                        )
                                                                      ),
                                                                      pw.SizedBox(height: 3),
                                                                      pw.Row(
                                                                        children: [
                                                                          pw.Text('Usuario: ', style: pw.TextStyle(fontSize: 5.5)),
                                                                          pw.Text(userInfo["user"], style: pw.TextStyle(fontSize: 5.5)),
                                                                        ]
                                                                      ), 
                                                                    ]
                                                                  );
                                                                }
                                                              )
                                                            );

                                                            final root = Platform.isAndroid 
                                                              ? await getExternalStorageDirectory() 
                                                              : await getApplicationDocumentsDirectory();

                                                            final filePath  = '${root!.path}/reporte.pdf';
                                                            final file      = File('$filePath');

                                                            await file.writeAsBytes(
                                                              await pdf.save()
                                                            );

                                                            OpenFile.open(filePath);
                                                          }
                                                        },
                                                        itemBuilder: (BuildContext bc) {
                                                          return const [
                                                            PopupMenuItem(child: Text("Editar"), value: 'EDIT'),
                                                            PopupMenuItem(child: Text("Eliminar"), value: 'DELETE'),
                                                            PopupMenuItem(child: Text("Vista Previa"), value: 'PREVIEW'),
                                                            PopupMenuItem(child: Text("Imprimir"), value: 'PRINT'),                                                            
                                                          ];
                                                        },
                                                      )
                                                    ]
                                                  )
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 55,
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: SizedBox(
                                                  width: screenMax * 1,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          // NOMBRE
                                                          /*Row(
                                                            children: [
                                                              const Text('Nombre: ', style: TextStyle(fontFamily: 'Poppins SemiBold'),                                                          ),
                                                              SizedBox(width: screenMax * 0.40,
                                                                child: Text(
                                                                  '${venta['nombre_cliente']}',
                                                                  style: const TextStyle(fontFamily: 'Poppins Regular'),
                                                                  overflow: TextOverflow.ellipsis,
                                                                )
                                                              )
                                                            ],
                                                          )*/
                                                          Row(
                                                            children: [
                                                              const Text('Nombre: ', style: TextStyle(fontFamily: 'Poppins SemiBold'),                                                          ),
                                                              SizedBox(width: screenMax * 0.40,
                                                                child: Text(
                                                                  '${venta['nombre_cliente']}',
                                                                  style: const TextStyle(fontFamily: 'Poppins Regular'),
                                                                  overflow: TextOverflow.ellipsis,
                                                                )                                                                  
                                                              )
                                                            ],
                                                          ),
                                                          // FECHA
                                                          Row(
                                                            children: [
                                                              const Text('Fecha: ', style: TextStyle(fontFamily: 'Poppins SemiBold')),
                                                              SizedBox(
                                                                width: screenMax * 0.40,
                                                                child: Text(
                                                                  '${venta['fecha']}',
                                                                  style: const TextStyle(fontFamily: 'Poppins Regular'),
                                                                  overflow: TextOverflow.ellipsis,
                                                                )
                                                              ),
                                                            ],
                                                          ),
                                                          // MONTO
                                                          Row(
                                                            children: [
                                                              const Text('Monto: ', style: TextStyle(fontFamily: 'Poppins SemiBold')),
                                                              SizedBox(
                                                                width: screenMax * 0.40,
                                                                child: Text(
                                                                  '${venta['monto']}\$',
                                                                  style: const TextStyle(fontFamily: 'Poppins Regular'),
                                                                  overflow: TextOverflow.ellipsis,
                                                                )
                                                              )
                                                            ],
                                                          ),
                                                          // DESCRIPCION
                                                          Row(
                                                            children: [
                                                              const Text('Descripción: ', style: TextStyle(fontFamily: 'Poppins SemiBold')),
                                                              SizedBox(
                                                                  width: screenMax * 0.40,
                                                                  child: Text(
                                                                    venta['descripcion'].toString(),
                                                                    style: const TextStyle(fontFamily: 'Poppins Regular'),
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ))
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                VentasDetails(
                                                                  ventaId: venta['id'],
                                                                  nameClient: venta['nombre_cliente'],
                                                                  saldoTotal: venta['saldo_total'],
                                                                  rucClient: venta['ruc'],
                                                                  emailClient: venta['email'],
                                                                  phoneClient: venta['phone'].toString()      
                                                                ),
                                                            ),
                                                          );
                                                        },
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            const Text('Ver', style: TextStyle(color: Color(0xFF7531FF))),
                                                            const SizedBox(width: 10),
                                                            Image.asset('lib/assets/Lupa-2@2x.png', width: 25),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
