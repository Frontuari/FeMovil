import 'package:femovil/config/app_bar_sampler.dart';
import 'package:femovil/database/gets_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CobrosList extends StatefulWidget {
  const CobrosList({super.key});

  @override
  State<CobrosList> createState() => _CobrosListState();
}

class _CobrosListState extends State<CobrosList> {
  late Future<List<Map<String, dynamic>>> _cobrosFuture;
  List<Map<String, dynamic>> cobros = [];
  List<Map<String, dynamic>> filteredCobros = [];
  List<Map<String, dynamic>> filteredCobroCopy = [];
  final int _pageSize = 20; // Tamaño de cada página
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  final TextEditingController _searchController = TextEditingController();
  TextEditingController inputValue = TextEditingController();
  DateTimeRange? _selectedDateRange; 


  @override
  void initState() {
    super.initState();
   _scrollController.addListener(_onScroll);

    _cobrosFuture = getCobros(page: cobros.length ~/ _pageSize + 1, pageSize: _pageSize);
    _cobrosFuture.then((data) {
      setState(() {
        cobros = data;
        filteredCobros = cobros;
      });
    });
  }

  Future<void> _loadMoreCobros() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final newData = await getCobros(page: cobros.length ~/ _pageSize + 1, pageSize: _pageSize);
      setState(() {
        cobros.addAll(newData);
        filteredCobros = cobros;
        filteredCobroCopy = cobros;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    print('Entre aqui ');
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      _loadMoreCobros();
    }
  }

  void _filterCobros(String query) {
    final filtered = cobros.where((cobro) {
      final clientName = cobro['client_name'].toString().toLowerCase();
      final orderNumber = cobro['orden_venta_nro'].toString();
      final documentNo = cobro['documentno'].toString();
      final searchQuery = query.toLowerCase(); 
      return clientName.contains(searchQuery) || orderNumber.contains(searchQuery) || documentNo.contains(searchQuery) ;
    }).toList();

    setState(() {
      filteredCobros = filtered;
      filteredCobroCopy = filtered;
    });
  }

  double parseNumberToDouble(String number) {
  number = number.replaceAll('.', '').replaceAll(',', '.');
  return double.parse(number);
  }

  void _filterByMaxPrice(double maxPrice) {
  setState(() {
      filteredCobros = cobros.where((cobro) {
  double monto = parseNumberToDouble(cobro['pay_amt']);
  return monto <= maxPrice;
  }).toList();

  filteredCobros.sort((a, b) {
    double montoA = parseNumberToDouble(a['pay_amt']);
    double montoB = parseNumberToDouble(b['pay_amt']);
    return montoB.compareTo(montoA);
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

  void _sortByDateRange(DateTime start, DateTime end) {
    // Guardar start y end en variables locales
    final startDate = start;
    final endDate = end;

    print("fecha start $start y fecha end $end");
    setState(() {
      filteredCobros = filteredCobroCopy.where((cobro) {
        print('el cobro es $cobro');
        final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
        try {
          if (cobro['date'] != null && cobro['date'] != '') {
            print("ventas  ${cobro['date']}");
            final ventaDate = dateFormat.parse(cobro['date']);
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
      print("FItered Ventas $filteredCobros ");
      // Ordena las ventas dentro del rango de fechas seleccionado
      filteredCobros.sort((a, b) {
        final DateFormat inputFormat = DateFormat('dd/MM/yyyy');
        final DateTime dateA = inputFormat.parse(a['date']);
        final DateTime dateB = inputFormat.parse(b['date']);

        // Formatea las fechas como "yyyy-mm-dd" antes de compararlas
        final String formattedDateA =
            '${dateA.year}-${dateA.month.toString().padLeft(2, '0')}-${dateA.day.toString().padLeft(2, '0')}';
        final String formattedDateB =
            '${dateB.year}-${dateB.month.toString().padLeft(2, '0')}-${dateB.day.toString().padLeft(2, '0')}';

        return formattedDateA.compareTo(formattedDateB);
      });
    });
  }


   void _showDateRangePicker(BuildContext context) async {
    // Enhanced user experience with custom date range and better initial selection
    final picked = await showDateRangePicker(
      context: context,
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



  void _showFilterOptions(BuildContext context, screenMax) {
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
              _cobrosFuture = getCobros(page: cobros.length ~/ _pageSize + 1, pageSize: _pageSize);
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
    final screenHeight = MediaQuery.of(context).size.height * 1;

    return GestureDetector(
      onTap: () {

        FocusScope.of(context).unfocus();

      },
      child: Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBarSample(label: 'Lista de Cobros'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.035,),
            Container(
              width: screenMax,
              height: screenMax * 0.18,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 7,
                    spreadRadius: 2,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterCobros,
                decoration: InputDecoration(
                  labelStyle: const TextStyle(
                    fontFamily: 'Poppins Regular',
                    color: Colors.black,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 25,
                    horizontal: 20,
                  ),
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
                  labelText: 'Buscar por nombre o numero de orden',
                  suffixIcon: Image.asset('lib/assets/Lupa.png'),
                ),
                style: const TextStyle(fontFamily: 'Poppins Regular'),
              ),
            ),
             SizedBox(height: screenHeight * 0.035,),
      
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
                        _showFilterOptions(context, screenMax);
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
            

            Expanded(
              child: FutureBuilder(
                future: _cobrosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: filteredCobros.length + 1,
                      itemBuilder: (context, index) {
                         if (index == filteredCobros.length) {
                          return _isLoading ? const Center(child: CircularProgressIndicator()) : const SizedBox();
                        }
                        
                        
                        final cobro = filteredCobros[index];
                        
                        print('esto es el snapshotData ${snapshot.data}');

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: screenMax,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
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
                                      height: 170,
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
                                                padding: const EdgeInsets.all(10.0),
                                                child: Text(
                                                  "N° ${cobro['orden_venta_nro'] != "" ? cobro['orden_venta_nro'] : ''}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Poppins Bold',
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                  ),
                                                  textAlign: TextAlign.start,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 55,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: SizedBox(
                                                width: screenMax * 0.9,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const Text(
                                                              'Nombre: ',
                                                              style: TextStyle(
                                                                fontFamily: 'Poppins SemiBold',
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: screenMax * 0.45,
                                                              child: Text(
                                                                cobro['client_name'].toString(),
                                                                style: const TextStyle(
                                                                  fontFamily: 'Poppins Regular',
                                                                ),
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Text(
                                                              'Fecha: ',
                                                              style: TextStyle(
                                                                fontFamily: 'Poppins SemiBold',
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: screenMax * 0.45,
                                                              child: Text(
                                                                cobro['date'],
                                                                style: const TextStyle(
                                                                  fontFamily: 'Poppins Regular',
                                                                ),
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Text(
                                                              'Monto: ',
                                                              style: TextStyle(
                                                                fontFamily: 'Poppins SemiBold',
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: screenMax * 0.45,
                                                              child: Text(
                                                                '${cobro['pay_amt'].toString()}\$',
                                                                style: const TextStyle(
                                                                  fontFamily: 'Poppins Regular',
                                                                ),
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                           Row(
                                                          children: [
                                                            const Text(
                                                              'N° Documento: ',
                                                              style: TextStyle(
                                                                fontFamily: 'Poppins SemiBold',
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: screenMax * 0.30,
                                                              child: Text(
                                                                cobro['documentno'].toString(),
                                                                style: const TextStyle(
                                                                  fontFamily: 'Poppins Regular',
                                                                ),
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Text(
                                                              'Descripción: ',
                                                              style: TextStyle(
                                                                fontFamily: 'Poppins SemiBold',
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: screenMax * 0.40,
                                                              child: Text(
                                                                cobro['description'].toString(),
                                                                style: const TextStyle(
                                                                  fontFamily: 'Poppins Regular',
                                                                ),
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {},
                                                      child: Row(
                                                        children: [
                                                          const Text(
                                                            'Ver',
                                                            style: TextStyle(
                                                              color: Color(0xFF7531FF),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Image.asset(
                                                            'lib/assets/Lupa-2@2x.png',
                                                            width: 25,
                                                          ),
                                                        ],
                                                      ),
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
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
