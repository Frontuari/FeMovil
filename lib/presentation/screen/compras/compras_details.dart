import 'dart:async';

import 'package:femovil/config/app_bar_sampler.dart';
import 'package:femovil/database/gets_database.dart';
import 'package:femovil/database/update_database.dart';
import 'package:femovil/presentation/screen/compras/idempiere/create_order_purchase.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ComprasDetails extends StatefulWidget {
  final int compraId;
  final String nameProveedor;
  final String rucProveedor;
  final String phoneProveedor;
  final String emailProveedor;
  const ComprasDetails({super.key, required this.compraId, required this.nameProveedor, required this.rucProveedor, required this.phoneProveedor, required this.emailProveedor });

  @override
  State<ComprasDetails> createState() => _ComprasDetailsState();
}

class _ComprasDetailsState extends State<ComprasDetails> {
  late Future<Map<String, dynamic>> _compraData;
  dynamic comprasDate = {};
  bool bottonEnable = true;


  initComprasDatas() async {

      dynamic respuesta = await _loadComprasForId();

      print('Esta es la respuesta $respuesta');

  }

  @override
  void initState() {
    super.initState();
    _compraData = _loadComprasForId();

    print('Este es el id de la orden ${widget.compraId} && este es el nombre del proveedor ${widget.nameProveedor}');

    initComprasDatas();

    _loadOrdenesConLineas();

  }

  _updateAndCreateOrders() async {

   dynamic isTrue = await createOrdenPurchaseIdempiere(comprasDate);

              if(isTrue == false){
                return false;
              }else{
                return true;
              }
                            
  }


  String calcularSaldoTotalProducts(dynamic price, dynamic quantity) {

      print('Este es el precio $price');

    double prices;
    double quantitys;

      final formatter = NumberFormat('#,##0.00', 'es_ES');


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

    String numParsedFormatter = formatter.format(sum); 

    print('price $price & quantity is $quantity');
    print('Suma es $sum');
    return numParsedFormatter;
  }



   _loadOrdenesConLineas() async {

     dynamic response = await obtenerOrdenDeCompraConLineasPorId(widget.compraId);

                setState(() {

                    comprasDate = response;

                });

        print('Estas son las ordenes de ventas con sus respectivas lineas $response');
        
      
  }


  Future<Map<String, dynamic>> _loadComprasForId() async {
  
    return await getOrderPurchaseWithProducts(widget.compraId);
  
  }

  @override
  Widget build(BuildContext context) {
            final screenMax = MediaQuery.of(context).size.width * 0.8;
            final heightScreen = MediaQuery.of(context).size.height * 0.9;

    return Scaffold(
      appBar:const PreferredSize(
          preferredSize: Size.fromHeight(50),
        child:  AppBarSample(label: 'Orden de Compra')),
      body: Align(
        alignment: Alignment.topCenter,
        child: FutureBuilder(
          future: _compraData,
          builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final compraData = snapshot.data!['order'];
              final productsData = snapshot.data!['products'];
              print("Esto es lo que hay productsData ${snapshot.data}");
              print("esto es ventas data $compraData");
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      
                      SizedBox(height: heightScreen * 0.015,),

                      Container(
                        width: screenMax ,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8), // Establece el radio de los bordes
                        ),
                        child: const Text('Datos Del Cliente', style:  TextStyle(fontFamily: 'Poppins Bold', fontSize: 18), textAlign: TextAlign.start,),
                      ),

                      SizedBox(height: heightScreen * 0.05,),

                         Container(
                    width: screenMax,
                    height: screenMax * 0.7,
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
                                width: screenMax * 0.5,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Nombre',
                                        style: TextStyle(
                                            fontFamily: 'Poppins Bold',
                                            fontSize: 18),
                                      ),
                                      Text(widget.nameProveedor.length > 25
                                          ? widget.nameProveedor.substring(0, 25)
                                          : widget.nameProveedor)
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: screenMax * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Ruc/DNI',
                                        style: TextStyle(
                                            fontFamily: 'Poppins Bold',
                                            fontSize: 18),
                                      ),
                                      Text(widget.rucProveedor.length > 15
                                          ? widget.rucProveedor.substring(0, 15)
                                          : widget.rucProveedor),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            width: screenMax,
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
                              const Text(
                                'Correo: ',
                                style:
                                    TextStyle(fontFamily: 'Poppins SemiBold'),
                              ),
                              Text(
                                widget.emailProveedor == '{@nil: true}'
                                    ? ''
                                    : widget.emailProveedor,
                                style: const TextStyle(
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
                              const Text(
                                'Telefono: ',
                                style:
                                    TextStyle(fontFamily: 'Poppins SemiBold'),
                              ),
                              Text(
                                widget.phoneProveedor == '{@nil: true}'
                                    ? ''
                                    : widget.phoneProveedor,
                                style: const TextStyle(
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

                                        SizedBox(height: heightScreen * 0.05,),
              
                    Container(
                            width: screenMax ,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.all(Radius.circular(15)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 7,
                                  spreadRadius: 2
                                )
                              ]
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Orden N°", style: TextStyle(fontFamily: 'Poppins Regular'),),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    compraData['documentno'] != ''
                                        ? compraData['documentno'].toString()
                                        : compraData['id'].toString(),
                                    textAlign: TextAlign.start,
                            
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: heightScreen * 0.025,),

                           Container(
                            width: screenMax ,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.all(Radius.circular(15)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 7,
                                  spreadRadius: 2
                                )
                              ]
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Fecha", style: TextStyle(fontFamily: 'Poppins Regular'),),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    compraData['fecha'].toString(),
                                    textAlign: TextAlign.start,
                            
                                  ),
                                ],
                              ),
                            ),
                          ),
                           SizedBox(height: heightScreen * 0.025,),
                                          Container(
                            width: screenMax ,
                            height: screenMax * 0.25,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.all(Radius.circular(15)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 7,
                                  spreadRadius: 2
                                )
                              ]
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Descripción", style: TextStyle(fontFamily: 'Poppins Regular'),),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    compraData['description'].toString(),
                                    textAlign: TextAlign.start,
                            
                                  ),
                                ],
                              ),
                            ),
                          ),
                               SizedBox(height: heightScreen * 0.025,),
                          SizedBox(
                            width: screenMax,
                            child: const Text(
                              "Productos",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Poppins Bold',
                                  fontSize: 18),
                            ),
                          ),
                            SizedBox(height: heightScreen * 0.025,),
                        Container(
                    width: screenMax,
                    height: screenMax * 0.5,
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
                             Padding(
                               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                               child: Container(
                                 width: 400,
                                 decoration: const BoxDecoration(
                                   borderRadius: BorderRadius.all(Radius.circular(15)),
                             
                                 ),
                                 child: const Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: [
                                     Text(
                                       'Nombre',
                                       style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 15),
                                     ),
                                     Text(
                                       'Cant.',
                                       style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 15),
                                     ),
                                     Text(
                                       'Precio',
                                                   style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 15),
                                                 ),
                                                 
                                               ],
                                             ),
                                           ),
                                         ),
                        
                            Expanded(
                              child: ListView.builder(                   
                                
                                itemCount: productsData.length,
                                itemBuilder: (context, index) {
                                  final product = productsData[index];
                        
                                  return Column(children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 0),
                                      child: SizedBox(
                                        width: screenMax * 0.95,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                             Image.asset('lib/assets/Check.png'),
                                             const SizedBox(width: 10 ,),
                                              SizedBox(
                                                  width: 50,
                                                  child: Text(product['name'])),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.14,
                                              ),
                                          
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(product['qty_entered']
                                                    .toString()),
                                              ),
                                             
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.20,
                                              ),
                                              SizedBox(
                                                width: screenMax * 0.35,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                        child: Text(
                                                            '\$${calcularSaldoTotalProducts(product['price_actual'].toString(), product['qty_entered'].toString())}')),
                                                   
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
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                     
                    
                  
                
                      const SizedBox(height: 10,),
                    
                      Container(
                          width: screenMax,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                8), // Establece el radio de los bordes
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              children: [
              
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Total',
                                        style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 17)),
                                    Text(
                                        ' \$ ${compraData['monto'].toString()}', style: const TextStyle(fontFamily: 'Poppins Bold', fontSize: 18),),
                                  ],
                                ),
                              ],
                            ),
                          )),
    
                const SizedBox(height: 15,),
                 compraData['status_sincronized'] == 'Borrador' ?  Container(
                  width: screenMax,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: compraData['status_sincronized'] == 'Borrador' && bottonEnable == true ? const Color(0xFF7531FF):Colors.grey, // Color verde para el fondo del botón
                  ),
                  child: ElevatedButton(
                    onPressed:compraData['status_sincronized'] == 'Borrador' && bottonEnable == true ? ()  async{
                      
                      setState(() {
                        bottonEnable = false;
                      });

                        Timer(const Duration(seconds: 3), () {
                            setState(() {
                              bottonEnable = true;
                            });
                          });

                     dynamic isTrue =  await _updateAndCreateOrders();


                            if(isTrue != false){
                              String newValue = 'Enviado';
                              updateOrderePurchaseForStatusSincronzed(compraData['id'], newValue );

                            }else{
                              String newValue = 'Por Enviar';

                              updateOrderePurchaseForStatusSincronzed(compraData['id'], newValue );


                            }

                        if(mounted){

                        setState(() {
                          
                          _compraData =  _loadComprasForId();

                        });

                        }


                    }: null,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent), // Hace que el color de fondo del botón sea transparente
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        'Comp y Enviar',
                        style: TextStyle(
                          color: Colors.white, // Texto blanco para que se destaque sobre el fondo verde
                          fontFamily: 'Poppins Bold'
                        ),
                      ),
                    ),
                  ),
                ): Container(),
                const SizedBox(height: 15,),
                 compraData['status_sincronized'] == 'Por Enviar'  ?    Container(
                  width: screenMax,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color:  compraData['status_sincronized'] == 'Por Enviar'  ? const Color(0xFF7531FF):Colors.grey, // Color verde para el fondo del botón
                  ),
                  child: ElevatedButton(
                    onPressed: compraData['status_sincronized'] == 'Por Enviar'  ? () async {
                        
                       dynamic isTrue =  await _updateAndCreateOrders();

                           setState(() {
                            bottonEnable = false;
                          });

                            Timer(const Duration(seconds: 3), () {
                              setState(() {
                                bottonEnable = true;
                              });
                            });

                          if(isTrue != false){

                        String newValue = 'Enviado';
                        updateOrderePurchaseForStatusSincronzed(compraData['id'], newValue );
                        
                          }else{

                               String newValue = 'Por Enviar';
                        updateOrderePurchaseForStatusSincronzed(compraData['id'], newValue );
                        

                          } 

                          if(mounted){

                        setState(() {
                          
                         _compraData =  _loadComprasForId();

                        });

                        }


                    }: null,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent), // Hace que el color de fondo del botón sea transparente
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        'Enviar',
                        style: TextStyle(
                          color: Colors.white, // Texto blanco para que se destaque sobre el fondo verde
                          fontFamily: 'Poppins Bold'
                        ),
                      ),
                    ),
                  ),
                ): Container(),
                const SizedBox(height: 15,),
                // Container(
                //   width: screenMax,
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(8),
                //     color:  compraData['status_sincronized'] == 'Completado' || compraData['status_sincronized'] == 'Enviado' ? Colors.green: Colors.grey, // Color verde para el fondo del botón
                //   ),
                //   child: ElevatedButton(
                //     onPressed: compraData['status_sincronized'] == 'Completado' || compraData['status_sincronized'] == 'Enviado' ? () {

                //         // Navigator.of(context).push(
                //         //  MaterialPageRoute(
                //         //     builder: (context) =>  Cobro(orderId: compraData['id'],saldoTotal:, loadCobranzas: _loadVentasForId),
                //         //   ),
                //         //  );

                //     }: null,
                //     style: ButtonStyle(
                //       backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent), // Hace que el color de fondo del botón sea transparente
                //       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                //         RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(8),
                //         ),
                //       ),
                //     ),
                //     child: const Padding(
                //       padding: EdgeInsets.all(15.0),
                //       child: Text(
                //         'Cobrar',
                //         style: TextStyle(
                //           color: Colors.white, // Texto blanco para que se destaque sobre el fondo verde
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
