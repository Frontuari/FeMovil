import 'package:femovil/config/app_bar_femovil.dart';
import 'package:femovil/database/create_database.dart';
import 'package:femovil/database/gets_database.dart';
import 'package:femovil/database/update_database.dart';
import 'package:femovil/infrastructure/models/clients.dart';
import 'package:femovil/presentation/clients/add_clients.dart';
import 'package:femovil/presentation/clients/clients_details.dart';
import 'package:femovil/presentation/clients/filter_dialog_clients.dart';
import 'package:femovil/presentation/clients/idempiere/clients_send_sync.dart';
import 'package:femovil/presentation/clients/idempiere/create_customer.dart';
import 'package:femovil/utils/alerts_messages.dart';
import 'package:femovil/utils/searck_key_idempiere.dart';
import 'package:femovil/utils/snackbar_messages.dart';
import 'package:flutter/material.dart';

class Clients extends StatefulWidget {
  const Clients({super.key});

  @override
  State<Clients> createState() => _ClientsState();
}

class _ClientsState extends State<Clients> {
  String _filter = "";
  late ScrollController _scrollController;
  bool _showAddButton = true;
  late List<Map<String, dynamic>> clients = [];
  List<Map<String, dynamic>> searchClient = [];
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredClients = [];
  final int _pageSize = 25;
  String input = "";
  bool _isLoading = false;
  bool _hasMoreProducts = true;
  late List<Map<String, dynamic>> clientsNoSync = [];
  int countClientSync = 0;
  List<Customer> customersSend = [];

  Future<void> _loadClients() async {
    final clientes = await getClientsScreen(page: 1, pageSize: _pageSize);

    print("Estoy obteniendo Clientes $clientes");
    setState(() {
      clients = clientes;
      searchClient = clientes;
    });
  }

  Future<void> anyNoSyncClient() async {
    final clientsNoSync = await getBPartnerNoSync();

    print("Estoy obteniendo Clientes No Sincronizados $clientsNoSync");

    setState(() {
      this.clientsNoSync = clientsNoSync;
      countClientSync = clientsNoSync.length;
    });

    print("Estoy obteniendo Clientes $clientsNoSync");
    print('Cantidades no Sincronizados $countClientSync');
    if (countClientSync > 0) {
          showWarningSnackbar(context, 'Clientes Por Enviar Datos: $countClientSync');
    }
  }

  Future<void> sendClientIdempiereScreen() async {

    showLoadingDialog(context, message: 'Sincronizando clientes...');
    final clientSyncService = ClientSyncService();

    int syncedCount = await clientSyncService.syncClients();

    print('Se sincronizaron $syncedCount clientes con iDempiere');
    
    Navigator.of(context).pop(); // Cerrar el diálogo de carga

    await SuccesMessages.showSuccesMessagesDialog(context, 'Se sincronizaron $syncedCount clientes con iDempiere');

    await anyNoSyncClient();
  }

  Future<void> _loadMoreClients() async {
    if (_isLoading || !_hasMoreProducts) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final List<Map<String, dynamic>> newData = await getClientsScreen(
          page: (clients.length ~/ _pageSize) + 1, pageSize: _pageSize);

      print('New data $newData');

      if (newData.isNotEmpty) {
        setState(() {
          for (var client in newData) {
            bool exists = clients
                .any((existingClient) => existingClient['id'] == client['id']);
            print('esto es exist $exists');
            if (!exists) {
              clients = [...clients, client];
            }
          }
          _hasMoreProducts = newData.length == _pageSize;
        });
      } else {
        setState(() {
          _hasMoreProducts = false;
        });
      }
      print(
          "esto es el valor de clientes despues de agrgarle el siguiente $clients");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _loadMoreClients();
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

  void _showFilterOptions(BuildContext context) async {
    final selectedFilter = await showDialog<String>(
      context: context,
      builder: (context) => FilterGroups(
        clients: searchClient,
      ),
    );

    print("Esto es el valor del select $selectedFilter");

    if (selectedFilter != null) {
      setState(() {
        _filter = selectedFilter;
        _applyFilter();
        print("Esto es el filter $_filter");
      });
    }
  }

  Future<void> _searchAndFilterClients(String input) async {
    print("Estoy entrando en el input cuando no está vacío");
    List<Map<String, dynamic>> dbResults = await getClientsByNameOrRUC(input);

    setState(() {
      searchClient = dbResults;
      print("Estos son los clientes por grupo $clients $input");
      _applyFilter();
    });
  }

  void _applyFilter() {
    if (_filter.isNotEmpty && _filter != "Todos") {
      searchClient = searchClient
          .where((client) => client['group_bp_name'] == _filter)
          .toList();
      print("Este es el searchClient $_filter $searchClient");
    } else if (_filter == 'Todos') {
      searchController.text = '';
      searchClient = clients;
    }
  }

  @override
  void initState() {
    // print("Esto es la variable global ${variablesG[0]['m_pricelist_id']}");
    _loadClients();
    anyNoSyncClient();
    _scrollController = ScrollController();

    _scrollController.addListener(_scrollListener);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (input == "") {
      searchClient = clients.toList();
    }

    final screenMax = MediaQuery.of(context).size.width * 0.8;
    final screenHight = MediaQuery.of(context).size.height * 0.8;

    return GestureDetector(
      onTap: () {
        if (MediaQuery.of(context).viewInsets.bottom > 0) {
          // Verificar si hay un teclado visible
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(170),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const AppBars(labelText: 'Clientes'),
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
                        if (value.isNotEmpty) {
                          _filter = '';
                        }

                        setState(() {
                          input = value;
                          _searchAndFilterClients(value);
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 3.0, horizontal: 20.0),
                        hintText: 'Nombre del Cliente o RUC',
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
                      if (countClientSync > 0)
                        ElevatedButton.icon(
                          onPressed: () {
                            sendClientIdempiereScreen();
                          },
                          icon: const Icon(Icons.sync),
                          label: const Text('Enviar Datos de Cliente'),
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
                            _loadClients();
                          },
                          icon: const Icon(
                            Icons.refresh,
                            color: Color(0xff7531ff),
                          ))
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: searchClient.length,
                      itemBuilder: (context, index) {
                        final client = searchClient[index];

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
                                    ]),
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
                                                    const EdgeInsets.all(10.0),
                                                child: Text(
                                                  client['bp_name'].toString(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Poppins Bold',
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                  ),
                                                  textAlign: TextAlign.start,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                                  '${client['ruc']}',
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
                                                                  '${!client['email'].toString().contains('{@nil: true}') ? client['email'] : 'Sin Registro'}',
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
                                                                  '${client['phone'] is int ? client['phone'] : ''}',
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
                                                        _verMasClient(
                                                            client['id']
                                                                .toString());
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
                  top: screenHight * 0.75,
                  right: screenMax * 0.05,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddClientsForm()),
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

  void _verMasClient(String clientId) async {
    final db = await DatabaseHelper.instance.database;
    if (db != null) {
      final client = await db.rawQuery(
        '''
          SELECT 
            cli.*,
            c.name country,
            r.name region, 
            cty.name city
          FROM clients cli
          LEFT JOIN countries c USING(c_country_id)
          LEFT JOIN regions r USING(c_region_id)
          LEFT JOIN cities cty USING(c_city_id)
          WHERE cli.id = ?
        ''',
        [int.parse(clientId)],
      );
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ClientDetailsScreen(client: client.first)),
      );
    } else {
      print('Error: db is null');
    }
  }
}
