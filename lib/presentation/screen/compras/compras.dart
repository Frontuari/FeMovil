import 'package:femovil/config/app_bar_femovil.dart';
import 'package:femovil/database/gets_database.dart';
import 'package:femovil/presentation/screen/compras/compras_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';




class Compras extends StatefulWidget {
  const Compras({super.key});

  @override
  State<Compras> createState() => _ComprasState();
}

class _ComprasState extends State<Compras> {
  String _filter = "";
  DateTimeRange? _selectedDateRange; 

  late List<Map<String, dynamic>> compras = [];
  List<Map<String, dynamic>> filteredCompras = [];
  TextEditingController searchController = TextEditingController();
    TextEditingController inputValue = TextEditingController();

  String input = "";
  int? searchValue;

      Future<void> _loadCompras() async {
        final comprasData = await getAllOrdersWithVendorsNames(); // Cambiar a la función de obtener ventas

            print("Esto es la venta Data $comprasData");

            setState(() {
              compras = comprasData;
              filteredCompras = comprasData;
            });
      }

  @override
  void initState() {
    _loadCompras();
    super.initState();
  }

  double parseNumberToDouble(String number) {
  number = number.replaceAll('.', '').replaceAll(',', '.');
  return double.parse(number);
}


void _filterByMaxPrice(double maxPrice) {
  setState(() {
      filteredCompras = compras.where((venta) {
    double monto = parseNumberToDouble(venta['monto']);
    return monto <= maxPrice;
  }).toList();

  filteredCompras.sort((a, b) {
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
        start: DateTime.now().subtract(const Duration(days: 7)), // Default to past week
        end: DateTime.now(),
      ),
      firstDate: DateTime(2010), // Adjust minimum year based on your requirements
      lastDate: DateTime.now().add(const Duration(days: 365)), // Extend to a year from now
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
    filteredCompras = compras.where((venta) {
      final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
          try {
            if (venta['fecha'] != null && venta['fecha'] != '') {
              print("ventas  ${venta['fecha']}");
              final ventaDate = dateFormat.parse(venta['fecha']);
              return ventaDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
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
      print("FItered Ventas $filteredCompras " );
    // Ordena las ventas dentro del rango de fechas seleccionado
        filteredCompras.sort((a, b) {
          final DateFormat inputFormat = DateFormat('dd/MM/yyyy');
          final DateTime dateA = inputFormat.parse(a['fecha']);
          final DateTime dateB = inputFormat.parse(b['fecha']);
          
          // Formatea las fechas como "yyyy-mm-dd" antes de compararlas
          final String formattedDateA = '${dateA.year}-${dateA.month.toString().padLeft(2, '0')}-${dateA.day.toString().padLeft(2, '0')}';
          final String formattedDateB = '${dateB.year}-${dateB.month.toString().padLeft(2, '0')}-${dateB.day.toString().padLeft(2, '0')}';
          
          return formattedDateA.compareTo(formattedDateB);
        });
    
      });
}

void _showMaxPriceDialog(BuildContext context, mediaScreen) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Ingrese el monto máximo'),
        content: Container(
            width: mediaScreen,
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
            keyboardType: TextInputType.number, // Teclado numérico para ingresar el monto
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(10),
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(width: 1, color: Colors.white)),
              hintText: 'Ingrese el monto máximo'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              inputValue.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar', style: TextStyle(fontFamily: 'Poppins SemiBold', color: Colors.red),),
          ),
          TextButton(
            onPressed: () {
              // Obtener el valor ingresado por el usuario
              
              final double maxPrice = double.tryParse(inputValue.text) ?? 0.0; // Convertir a double
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


void _showFilterOptions(BuildContext context, mediaScreen) {
  final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;

  showMenu(
    
    context: context,
    shape: RoundedRectangleBorder(
          // Redondear los bordes del menú emergente
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            width: 5,
            color: Colors.grey.withOpacity(
                0.5), // Establece el color transparente como punto inicial del gradiente
          )),
    position: RelativeRect.fromRect(
      
      Rect.fromPoints(
        const Offset(25, 250), // Punto de inicio en la esquina superior izquierda
        const Offset(160, 240), // Punto de fin en la esquina superior izquierda
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
              const Text('Filtrar Por el monto Mayor'),
            ],
          ),
          onTap: () {
            Navigator.pop(context);
            _showMaxPriceDialog(context, mediaScreen);
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
              const Text('Ordenar por un rango de fecha'),
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

    return GestureDetector(
      onTap: () {

          FocusScope.of(context).requestFocus(FocusNode());

      },
      child: Scaffold(
      
        appBar:  PreferredSize(
          preferredSize: const Size.fromHeight(170),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const AppBars(labelText : 'Compras'),
      
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
                            filteredCompras = compras.where((compra) {
                            final numeroReferencia = compra['ruc'].toString();
                            final nombreProveedor = compra['nombre_proveedor'].toString().toLowerCase();
                            final orderSale = compra['documentno'].toString();
                            return numeroReferencia.contains(value) || nombreProveedor.contains(value.toLowerCase()) || orderSale.contains(value) ;
                          }).toList();
                          });
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 3.0, horizontal: 20.0),
                          hintText: 'Buscar por número de documento o nombre',
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
          )) ,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const SizedBox(height: 25,),
      
                  
                      IconButton(
                        icon: Image.asset(
                          'lib/assets/filtro@3x.png',
                          width: 25,
                          height: 35,
                        ),
                        onPressed: () {
                          _showFilterOptions(context, screenMax);
                        },
                      ),
              
                  const SizedBox(height: 10 ,),
      
                   Expanded(
                      child: ListView.builder(
                        itemCount: filteredCompras.length,
                        itemBuilder: (context, index) {
                          final compra = filteredCompras[index];
      
                          print('Estas son las compras $compra');
      
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
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
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
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.2),
                                                      spreadRadius: 2,
                                                      blurRadius: 5,
                                                      offset: const Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(15.0),
                                                  child: Text(
                                                    compra['documentno'] == ''
                                                        ? 'N° ${compra['ruc'].toString()}'
                                                        : 'N° ${compra['documentno'].toString()}',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: 'Poppins Bold',
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 55,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: SizedBox(
                                                  width: screenMax * 1,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const Text(
                                                                'Nombre: ',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Poppins SemiBold'),
                                                              ),
                                                              SizedBox(
                                                                  width:
                                                                      screenMax *
                                                                          0.40,
                                                                  child: Text(
                                                                    '${compra['nombre_proveedor']}',
                                                                    style: const TextStyle(
                                                                        fontFamily:
                                                                            'Poppins Regular'),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ))
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              const Text(
                                                                'Fecha: ',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Poppins SemiBold'),
                                                              ),
                                                              SizedBox(
                                                                  width:
                                                                      screenMax *
                                                                          0.40,
                                                                  child: Text(
                                                                    '${compra['fecha']}',
                                                                    style: const TextStyle(
                                                                        fontFamily:
                                                                            'Poppins Regular'),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  )),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              const Text(
                                                                'Monto: ',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Poppins SemiBold'),
                                                              ),
                                                              SizedBox(
                                                                  width:
                                                                      screenMax *
                                                                          0.40,
                                                                  child: Text(
                                                                    '${compra['monto']}\$',
                                                                    style: const TextStyle(
                                                                        fontFamily:
                                                                            'Poppins Regular'),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ))
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              const Text(
                                                                'Descripción: ',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Poppins SemiBold'),
                                                              ),
                                                              SizedBox(
                                                                  width:
                                                                      screenMax *
                                                                          0.40,
                                                                  child: Text(
                                                                    compra['description']
                                                                        .toString(),
                                                                    style: const TextStyle(
                                                                        fontFamily:
                                                                            'Poppins Regular'),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ))
                                                            ],
                                                          ),
                                                        ],
                                                      ),
      
                                                       GestureDetector(
                                                        onTap: () {
                                             Navigator.of(context).push(
                                              MaterialPageRoute(
                                                      builder: (context) => ComprasDetails(compraId: compra['id'], nameProveedor: compra['nombre_proveedor'], emailProveedor: compra['email'],phoneProveedor: compra['phone'].toString(),rucProveedor:compra['ruc'].toString(),),
                                                    ),
                                                  );
                                                },
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const Text('Ver',
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF7531FF))),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Image.asset(
                                                                'lib/assets/Lupa-2@2x.png',
                                                                width: 25),
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
        ),
      ),
    );
  }

}
