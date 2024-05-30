import 'package:femovil/config/app_bar_femovil.dart';
import 'package:femovil/database/create_database.dart';
import 'package:femovil/database/gets_database.dart';
import 'package:femovil/presentation/screen/proveedores/add_proveedor.dart';
import 'package:femovil/presentation/screen/proveedores/filter_dialog_providers.dart';
import 'package:femovil/presentation/screen/proveedores/providers_details.dart';

import 'package:flutter/material.dart';

class Providers extends StatefulWidget {
  const Providers({super.key});

  @override
  State<Providers> createState() => _ProvidersState();
}

class _ProvidersState extends State<Providers> {
  String _filter = "";
  late List<Map<String, dynamic>> providers = [];
  List<Map<String, dynamic>> searchProvider = [];
  TextEditingController searchController = TextEditingController();
  String input = "";
  late ScrollController _scrollController;
  bool _showAddButton = true;

  Future<void> _loadProviders() async {
    final proveedores = await getProviders(); // Obtener todos los productos

    print("Estoy obteniendo proveedores $proveedores");
    setState(() {
      providers = proveedores;
      searchProvider = proveedores;
    });
  }

  void _scrollListener() {
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

  void _showFilterOptions(BuildContext context) async {
    final selectedFilter = await showDialog<String>(
      context: context,
      builder: (context) => FilterGroupsProviders(
        providers: providers,
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
    _loadProviders();
    _scrollController = ScrollController();

    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (input == "") {
      searchProvider = providers.toList();
    }

    if (_filter != "" && input == "") {
      setState(() {
        if (_filter == "Todos") {
          print("entre aqui");
          searchController.clear();
          input = "";

          searchProvider = providers.toList();
        } else {
          searchProvider = providers
              .where((provider) => provider['groupbpname'] == _filter)
              .toList();
          print("Este es el searchProvider $searchProvider");
        }
        input = ""; // Limpiar el campo de búsqueda al filtrar por categoría
      });
    } else if (input != "") {
      print("Estoy entrando en el input cuando no esta vacio ");
      setState(() {
        searchProvider = providers.where((provider) {
          final name = provider['bpname'].toString().toLowerCase();
          final ruc = provider['tax_id'].toString().toLowerCase();
          final inputLower = input.toLowerCase();
          return name.contains(inputLower) || ruc.contains(inputLower);
        }).toList();
        print("Estos son los proveedores por grupo $searchProvider $input");
      });
    }

    if (_filter != "" && _filter != "Todos") {
      searchProvider = providers
          .where((provider) => provider['groupbpname'] == _filter)
          .toList();
      searchController.clear();
      input = "";
    } else if (_filter == "Todos") {
      searchController.clear();
      input = "";

      searchProvider = providers.toList();
    }

    final screenMax = MediaQuery.of(context).size.width * 0.8;
    final screenHeight = MediaQuery.of(context).size.height * 0.8;

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
                const AppBars(labelText: 'Proveedores'),
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
                            input = value;
                            searchProvider = providers.where((provider) {
                              final valueLower = value.toLowerCase();
                              if (int.tryParse(valueLower) != null) {
                                // Si el valor se puede convertir a un número entero, buscar por ruc
                                final ruc =
                                    provider['tax_id'].toString().toLowerCase();
                                return ruc.contains(valueLower);
                              } else {
                                // Si no se puede convertir a un número entero, buscar por nombre
                                final name =
                                    provider['bpname'].toString().toLowerCase();
                                final result = name.contains(valueLower);
      
                                print('Esto es name $result');
      
                                return name.contains(valueLower);
                              }
                            }).toList();
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 3.0, horizontal: 20.0),
                          hintText: 'Buscar por nombre o Ruc',
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: screenMax * 0.1,
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
                      IconButton(
                          onPressed: () {
                            _loadProviders();
                          },
                          icon: const Icon(
                            Icons.refresh,
                            color: Color(0xff7531ff),
                          ))
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: searchProvider.length,
                      itemBuilder: (context, index) {
                        final provider = searchProvider[index];
        
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
                                      height: 130,
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
                                                  provider['bpname'].toString(),
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
                                                width: screenMax * 0.9,
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
                                                              'RUC/DNI: ',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins SemiBold'),
                                                            ),
                                                            SizedBox(
                                                                width:
                                                                    screenMax *
                                                                        0.45,
                                                                child: Text(
                                                                  '${provider['tax_id']}',
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
                                                              'Correo: ',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins SemiBold'),
                                                            ),
                                                            SizedBox(
                                                                width:
                                                                    screenMax *
                                                                        0.45,
                                                                child: Text(
                                                                  provider['email'] !=
                                                                              '{@nil=true}' &&
                                                                          provider['email'].toString().contains(
                                                                              '@')
                                                                      ? provider[
                                                                              'email']
                                                                          .toString()
                                                                      : '',
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
                                                              'Teléfono: ',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins SemiBold'),
                                                            ),
                                                            SizedBox(
                                                                width:
                                                                    screenMax *
                                                                        0.45,
                                                                child: Text(
                                                                  '${provider['phone'] != '{@nil=true}' ? provider['phone'] : 0}',
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
                                                        _verMasprovider(
                                                            '${provider['id']}');
                                                      },
                                                      child: Row(
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
            if (_showAddButton)
              Positioned(
                  top: screenHeight * 0.75,
                  right: screenMax * 0.05,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddProvidersForm()),
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

  void _verMasprovider(String providerId) async {
    final db = await DatabaseHelper.instance.database;
    if (db != null) {
      final provider = await db.query(
        'providers',
        where: 'id = ?',
        whereArgs: [int.parse(providerId)],
      );
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ProvidersDetailsScreen(provider: provider.first)),
      );
    } else {
      print('Error: db is null');
    }
  }
}
