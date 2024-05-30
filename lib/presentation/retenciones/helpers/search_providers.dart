import 'package:femovil/database/gets_database.dart';
import 'package:flutter/material.dart';

class TercerosFutureBuilder extends StatefulWidget {

                                                                  
  final Function(String, String, String, String, bool) onSelected;


  const TercerosFutureBuilder({super.key, required this.onSelected});

  @override
  State<TercerosFutureBuilder> createState() => _TercerosFutureBuilderState();
}

class _TercerosFutureBuilderState extends State<TercerosFutureBuilder> {
  Future? _terceros;
  List<dynamic>? filteredTerceros;
  bool _hasError = false;
  final TextEditingController _searchDialogController = TextEditingController();
  final TextEditingController _textTerceroController = TextEditingController();  
  final TextEditingController _cbPartnerIdController = TextEditingController();
  final TextEditingController _cbPartnerLocationIdController = TextEditingController();
  final TextEditingController _providerIdController = TextEditingController();
  


    @override
  void initState() {
    setState(() {
             _terceros = getProviders();
 
    
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
final screenMedia = MediaQuery.of(context).size.width * 0.8;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return FutureBuilder<dynamic>(
                      future:
                          _terceros, // Tu Future que devuelve un AsyncSnapshot<dynamic>
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Text('Error al cargar los datos');
                        } else {
                          List<dynamic> tercerosData = snapshot
                              .data; // Accedemos a los datos del snapshot

                          filteredTerceros ??= tercerosData;

                          return Container(
                            width: screenMedia * 0.97,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      blurRadius: 7,
                                      spreadRadius: 2)
                                ]),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: _hasError == true
                                          ? screenHeight * 0.18
                                          : screenHeight * 0.11,
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              bottomLeft: Radius.circular(2)),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                blurRadius: 7,
                                                spreadRadius: 2,
                                                offset: Offset(-2, 0))
                                          ]),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.search,
                                          color: _hasError
                                              ? Color(0XFFA5F52B)
                                              : Color(0XFF7531FF),
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return GestureDetector(
                                                onTap: () {
                                                  if (MediaQuery.of(context)
                                                          .viewInsets
                                                          .bottom >
                                                      0) {
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            FocusNode());
                                                  }
                                                },
                                                child: StatefulBuilder(
                                                  builder: (context,
                                                      setStateDialog) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                        'Buscar Proveedor',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Poppins Semibold',
                                                        ),
                                                      ),
                                                      content:
                                                          SingleChildScrollView(
                                                        child: Column(
                                                          children: [
                                                            SizedBox(
                                                              height:
                                                                  screenHeight *
                                                                      0.03,
                                                            ),
                                                            Container(
                                                              width:
                                                                  screenMedia *
                                                                      0.80,
                                                              height:
                                                                  screenHeight *
                                                                      0.09,
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(8),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                        color: Colors
                                                                            .grey
                                                                            .withOpacity(
                                                                                0.3),
                                                                        blurRadius:
                                                                            7,
                                                                        spreadRadius:
                                                                            2)
                                                                  ]),
                                                              child: TextField(
                                                                controller:
                                                                    _searchDialogController,
                                                                decoration:
                                                                    const InputDecoration(
                                                                  border: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(Radius.circular(
                                                                              15)),
                                                                      borderSide:
                                                                          BorderSide
                                                                              .none),
                                                                  focusedBorder: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(Radius.circular(
                                                                              15)),
                                                                      borderSide: BorderSide(
                                                                          width:
                                                                              25,
                                                                          color:
                                                                              Colors.white)),
                                                                  contentPadding:
                                                                      EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              25,
                                                                          vertical:
                                                                              20),
                                                                  labelText:
                                                                      'Buscar',
                                                                  prefixIcon:
                                                                      Icon(Icons
                                                                          .search),
                                                                ),
                                                                onChanged:
                                                                    (value) {
                                                                  if (mounted) {
                                                                    setStateDialog(
                                                                        () {
                                                                      filteredTerceros = tercerosData
                                                                          .where((tercero) =>
                                                                              tercero['bpname'].toLowerCase().contains(value.toLowerCase()) ||
                                                                              tercero['tax_id'].contains(value))
                                                                          .toList();
                                                                    });
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 16),
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.9,
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.5,
                                                              child: ListView
                                                                  .builder(
                                                                shrinkWrap:
                                                                    true,
                                                                itemCount:
                                                                    filteredTerceros!
                                                                        .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  print(
                                                                      'Estos son los filteredTerceros $filteredTerceros');

                                                                  String
                                                                      bpName =
                                                                      filteredTerceros![
                                                                              index]
                                                                          [
                                                                          'bpname'];
                                                                  int providerId =
                                                                      filteredTerceros![
                                                                              index]
                                                                          [
                                                                          'id'];
                                                                  int cBPartnerID =
                                                                      filteredTerceros![
                                                                              index]
                                                                          [
                                                                          'c_bpartner_id'];
                                                                  dynamic
                                                                      cBPartnerLocationID =
                                                                      filteredTerceros![
                                                                              index]
                                                                          [
                                                                          'c_bpartner_location_id'];
                                                                  String ruc =
                                                                      filteredTerceros![
                                                                              index]
                                                                          [
                                                                          'tax_id'];

                                                                  String
                                                                      displayBpName =
                                                                      "${bpName} ";
                                                                  String
                                                                      displayRuc =
                                                                      ruc;
                                                                  return ListTile(
                                                                    title:
                                                                        Container(
                                                                      decoration: BoxDecoration(
                                                                          color:
                                                                              Colors.white,
                                                                          borderRadius: BorderRadius.circular(8),
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                                color: Colors.grey.withOpacity(0.3),
                                                                                blurRadius: 7,
                                                                                spreadRadius: 2)
                                                                          ]),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            SizedBox(
                                                                              width: screenMedia,
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                                                                child: Text(
                                                                                  displayBpName,
                                                                                  textAlign: TextAlign.start,
                                                                                  style: TextStyle(fontFamily: 'Poppins Bold'),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              width: screenMedia,
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                                                                child: Text(
                                                                                  displayRuc,
                                                                                  textAlign: TextAlign.start,
                                                                                  style: TextStyle(fontFamily: 'Poppins Regular'),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    onTap: () {
                                                                      setState(
                                                                        () {
                                                                          _hasError =
                                                                              false;
                                                                        },
                                                                      );

                                                                      setStateDialog(
                                                                        () {

                                                                      _textTerceroController
                                                                              .text =
                                                                          bpName
                                                                              .toString();
                                                                      _cbPartnerIdController
                                                                              .text =
                                                                          cBPartnerID
                                                                              .toString();
                                                                      _cbPartnerLocationIdController
                                                                              .text =
                                                                          cBPartnerLocationID
                                                                              .toString();
                                                                      _providerIdController
                                                                              .text =
                                                                          providerId
                                                                              .toString();
                                                                        
                                                                        widget.onSelected(_textTerceroController.text, _cbPartnerIdController.text, _cbPartnerLocationIdController.text, _providerIdController.text, _hasError );

                                                                        },
                                                                      );
                                                                      
                                                                      print(
                                                                          'este es el tercero que se elijio  $bpName este es el cbpartnerId ${_cbPartnerIdController.text} y este es el cbpartnerLocationId $cBPartnerLocationID');
                                                                      // Aquí puedes manejar la selección del tercero
                                                                      // Por ejemplo, cerrar el diálogo y usar el tercero seleccionado.
                                                                      Navigator
                                                                          .of(
                                                                        context,
                                                                      ).pop();
                                                                      // Puedes acceder al tercero seleccionado con filteredTerceros[index]
                                                                    },
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                            'Cancelar',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Poppins SemiBold',
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.02,
                                    ),
                                    SizedBox(
                                      width: screenMedia * 0.75,
                                      child: TextFormField(
                                        readOnly: true,
                                        decoration: const InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                    vertical: 25),
                                            disabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                borderSide: BorderSide(
                                                    width: 25,
                                                    color: Colors.white)),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                borderSide: BorderSide(
                                                    width: 25,
                                                    color: Colors.white)),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                borderSide:
                                                    BorderSide(width: 25, color: Colors.white)),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)), borderSide: BorderSide.none),
                                            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide(width: 1, color: Colors.red)),
                                            label: Text('Proveedor'),
                                            errorStyle: TextStyle(fontFamily: 'Poppins Regular')),
                                        controller: _textTerceroController,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            _hasError = true;

                                            return "Debe seleccionar un proveedor";
                                          }

                                          return null;
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    );
  }
}
