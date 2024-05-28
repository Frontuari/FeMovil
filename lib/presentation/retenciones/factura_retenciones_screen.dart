import 'package:femovil/assets/nav_bottom_menu.dart';
import 'package:femovil/config/app_bar_femovil.dart';
import 'package:femovil/config/app_bar_sampler.dart';
import 'package:femovil/database/gets_database.dart';
import 'package:femovil/presentation/retenciones/crear_factura_retencion.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';





class Retenciones extends StatefulWidget {

  const Retenciones({super.key});

  @override
  State<Retenciones> createState() => _RetencionesState();
  
}




class _RetencionesState extends State<Retenciones> {
      bool _isLoading = false;
      TextEditingController searchController = TextEditingController();
        List<Map<String, dynamic>> filteredRetenciones = [];
        List<Map<String, dynamic>> retentions = [];
        DateTimeRange? _selectedDateRange; 
            TextEditingController inputValue = TextEditingController();

            Future<void>  _loadWithholdings() async{ 

                    List<Map<String, dynamic>> taxes = await getTaxs();

                      List<Map<String, dynamic>> retenciones = await getRetencionesWithProveedorNames();

                  setState(() {
                  filteredRetenciones = retenciones;
                  retentions = retenciones;
                    
                  }); 

                  print('Estos son los taxes agregados $taxes');

                  print('Estos son las retenciones $retenciones');
            }     


          @override
  void initState() {


      _loadWithholdings();
    super.initState();
  }

void _filterByMaxPrice(double maxPrice) {
  setState(() {
      filteredRetenciones = retentions.where((venta) {
    double monto = venta['monto'];
    return monto <= maxPrice;
  }).toList();

  filteredRetenciones.sort((a, b) {
    double montoA = a['monto'];
    double montoB = b['monto'];
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
    
    filteredRetenciones = retentions.where((retenciones) {
      final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
          try {
            if (retenciones['date'] != null && retenciones['date'] != '') {
              print("ventas  ${retenciones['date']}");
              final retencionDate = dateFormat.parse(retenciones['date']);
              return retencionDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
                    retencionDate.isBefore(endDate.add(const Duration(days: 1)));
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
      print("Filtered retenciones $filteredRetenciones " );
    // Ordena las ventas dentro del rango de fechas seleccionado
        filteredRetenciones.sort((a, b) {
          final DateFormat inputFormat = DateFormat('dd/MM/yyyy');
          final DateTime dateA = inputFormat.parse(a['date']);
          final DateTime dateB = inputFormat.parse(b['date']);
          
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
  void dispose(){
    searchController.clear();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
      final screenSize = MediaQuery.of(context).size.width * 0.8;
      final screenHeight = MediaQuery.of(context).size.height * 1;

    return Scaffold(
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(170),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AppBars(labelText: 'Retenciones'),

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

                              if (searchController.text.isNotEmpty) {
                                  setState(() {
                                filteredRetenciones = retentions.where((retencion) {
                                final numeroReferencia = retencion['documentno'].toString().toLowerCase();
                                final nombreCliente = retencion['nombre_proveedor'].toString().toLowerCase();
                                return numeroReferencia.contains(value.toLowerCase()) || nombreCliente.contains(value.toLowerCase());
                              }).toList();
                              });
                                
                                  }else{
                                    setState(() {
                                      
                                    filteredRetenciones = retentions;
                                    });
                                  }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 3.0, horizontal: 20.0),
                        hintText: 'Numero de documento, Proveedor',
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
            body: GestureDetector(
              onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());

              },
              child:  Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(


                      
                      children: [

                  const SizedBox(
                    height: 30,
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
                              _showFilterOptions(context,screenSize);
                            },
                          ),
                          IconButton(
                              onPressed: () {
                                  
                                _loadWithholdings();
                                
                              },
                              icon: const Icon(
                                Icons.refresh,
                                color: Color(0xFF7531ff),
                              ))
                        ],
                      ),
                      SizedBox(height:  screenHeight * 0.04 ),


                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredRetenciones.length,
                      itemBuilder: (context, index) {
                        if (index >= filteredRetenciones.length) {
                          return _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : const SizedBox();
                        }

                        final facturaCxP = filteredRetenciones[index];

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: screenSize,
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
                                      height: screenHeight * 0.22,
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
                                              width: screenSize,
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
                                                  'N° ${facturaCxP['documentno'].toString()}',
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
                                                width: screenSize * 0.9,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const Text(
                                                              'Proveedor: ',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins SemiBold'),
                                                            ),
                                                            SizedBox(
                                                                width:
                                                                    screenSize *
                                                                        0.60,
                                                                child: Text(
                                                                  '${facturaCxP['nombre_proveedor'].toString()}',
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
                                                              'RUC: ',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins SemiBold'),
                                                            ),
                                                            SizedBox(
                                                                width:
                                                                    screenSize *
                                                                        0.45,
                                                                child: Text(
                                                                  facturaCxP['ruc'].toString(),
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
                                                              'Fecha: ',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins SemiBold'),
                                                            ),
                                                            SizedBox(
                                                                width:
                                                                    screenSize *
                                                                        0.45,
                                                                child: Text(
                                                                  facturaCxP['date'].toString(),
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
                                                              'Monto: ',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins SemiBold'),
                                                            ),
                                                            SizedBox(
                                                                width:
                                                                    screenSize *
                                                                        0.45,
                                                                child: Text(
                                                                  '\$${facturaCxP['monto'].toString()}',
                                                                  style: const TextStyle(
                                                                      fontFamily:
                                                                          'Poppins Regular', color: Color(
                                                                      0xFF7531FF) ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ))
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  
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
                   Positioned(
                  top: screenHeight * 0.58,
                  right: screenHeight * 0.02,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CrearRetenciones()),
                    ),
                    child: Image.asset(
                      'lib/assets/Agregar@3x.png',
                      width: 80,
                    ),
                  )),

                ],
              ),
            ),
     
      );  
  }
}

