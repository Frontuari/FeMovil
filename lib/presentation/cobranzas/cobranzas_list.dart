import 'package:femovil/config/app_bar_femovil.dart';
import 'package:femovil/database/gets_database.dart';
import 'package:femovil/presentation/cobranzas/cobro.dart';
import 'package:femovil/presentation/cobranzas/cobros_list.dart';
import 'package:flutter/material.dart';

class Cobranzas extends StatefulWidget {
  const Cobranzas({super.key});

  @override
  State<Cobranzas> createState() => _CobranzasState();
}

class _CobranzasState extends State<Cobranzas> {
  String _filter = "";
  DateTimeRange? _selectedDateRange; // Declare and initialize to null

  late List<Map<String, dynamic>> Cobranzas = [];
  List<Map<String, dynamic>> filteredCobranzas = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController inputValue = TextEditingController();

  String input = "";
  int? searchValue;

  Future<void> _loadCobranzas() async {
    final CobranzasData =
        await getAllOrdersWithClientNames(); // Cambiar a la función de obtener Cobranzas

    // ______________________________________________

    print("Esto es la venta Data $CobranzasData");

    setState(() {
      Cobranzas = CobranzasData;
      // filteredCobranzas = CobranzasData;
      filteredCobranzas =
          Cobranzas.where((venta) => venta['saldo_total'] > 0).toList();
    });
  }

  @override
  void initState() {
    _loadCobranzas();
    super.initState();
  }

  void _showFilterOptions(BuildContext context) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final screenMax = MediaQuery.of(context).size.width * 0.8;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          const Offset(
              20, 240), // Punto de inicio en la esquina superior izquierda
          const Offset(
              180, 250), // Punto de fin en la esquina superior izquierda
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
                  color: const Color(0xFF7531FF),
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                    width: screenMax * 0.6,
                    child: const Text(
                      'Ordenes con saldo abierto',
                      style: TextStyle(overflow: TextOverflow.ellipsis),
                    )),
              ],
            ),
            onTap: () {
              Navigator.pop(context);

              setState(() {
                filteredCobranzas =
                    Cobranzas.where((venta) => venta['saldo_total'] > 0)
                        .toList();
              });
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
                  color: const Color(0xFF7531FF),
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                    width: screenMax * 0.6,
                    child: const Text(
                      'Ordenes con saldo pagado',
                      style: TextStyle(overflow: TextOverflow.ellipsis),
                    )),
              ],
            ),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                filteredCobranzas =
                    Cobranzas.where((venta) => venta['saldo_total'] == 0)
                        .toList();
              });
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
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(170),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const AppBars(labelText: 'Cobranzas'),
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
                            offset: const Offset(
                                0, 2), // Desplazamiento de la sombra
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
                            filteredCobranzas = Cobranzas.where((venta) {
                              final numeroReferencia =
                                  venta['ruc'].toString().toLowerCase();
                              final nombreCliente = venta['nombre_cliente']
                                  .toString()
                                  .toLowerCase();
                              return numeroReferencia
                                      .contains(value.toLowerCase()) ||
                                  nombreCliente.contains(value.toLowerCase());
                            }).toList();
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 3.0, horizontal: 20.0),
                          hintText: 'Buscar por número de RUC o nombre',
                          labelStyle: const TextStyle(
                              color: Colors.black,
                              fontFamily: 'Poppins Regular'),
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CobrosList()));
                      },
                      icon: const Icon(
                        Icons.list_alt_outlined,
                        color: Color(0xff7531ff),
                      ))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredCobranzas.length,
                  itemBuilder: (context, index) {
                    final venta = filteredCobranzas[index];

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
                                  height: 170,
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
                                            padding: const EdgeInsets.all(10.0),
                                            child: Text(
                                              "N° ${venta['documentno'] != "" ? venta['documentno'] : venta['ruc']}",
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
                                                            width: screenMax *
                                                                0.45,
                                                            child: Text(
                                                              '${venta['nombre_cliente']}',
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
                                                            width: screenMax *
                                                                0.45,
                                                            child: Text(
                                                              venta['fecha'],
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
                                                            width: screenMax *
                                                                0.45,
                                                            child: Text(
                                                              '${venta['monto'].toString()}\$',
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
                                                            width: screenMax *
                                                                0.40,
                                                            child: Text(
                                                              venta['descripcion']
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
                                                        builder: (context) =>
                                                            Cobro(
                                                          orderId: venta['id'],
                                                          cOrderId: venta[
                                                              'c_order_id'],
                                                          documentNo: venta[
                                                              'documentno'],
                                                          idFactura: venta[
                                                              'id_factura'],
                                                        ),
                                                      ),
                                                    );
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
      ),
    );
  }
}
