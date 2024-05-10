import 'package:femovil/config/app_bar_sampler.dart';
import 'package:femovil/presentation/clients/edit_clients.dart';
import 'package:femovil/presentation/orden_venta/orden_venta.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ClientDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> client;


  const ClientDetailsScreen({super.key, required this.client});

  @override
  Widget build(BuildContext context) {

    final mediaScreen = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBarSample(label: 'Detalles del Cliente')),      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Align(
            alignment: Alignment.center,
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox( height: 10,),
                    Container(
                        height: mediaScreen * 1.55,
                        width: mediaScreen,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 7,
                              spreadRadius: 2
                            )
                          ] 
                        ),
            
                        child:  Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Nombre",
                                textAlign: TextAlign.start,
                                style:  TextStyle(color: Colors.black, fontFamily: 'Poppins Bold', fontSize: 18,),
                                
                              ),
                              SizedBox(height: mediaScreen * 0.05 ,),
                              Flexible(child: Text(client['bp_name'], style: const TextStyle(fontFamily: 'Poppins Regular') ,)),
                              SizedBox(height: mediaScreen * 0.05 ,),
                               const Text(
                                "Ruc/DNI",
                                textAlign: TextAlign.start,
                                style:  TextStyle(color: Colors.black, fontFamily: 'Poppins Bold', fontSize: 18,),
                                
                              ),
                              SizedBox(height: mediaScreen * 0.05 ,),
                              Flexible(child: Text(client['ruc'], style: const TextStyle(fontFamily: 'Poppins Regular'),),),
                              SizedBox(height: mediaScreen * 0.05 ,),
                               const Text(
                                "Detalles",
                                textAlign: TextAlign.start,
                                style:  TextStyle(color: Colors.black, fontFamily: 'Poppins Bold', fontSize: 18,),
                                
                              ),
                              SizedBox(height: mediaScreen * 0.05 ,),
            
                              Row(
                                children: [
                                  const Text('Correo: ', style: TextStyle(color: Colors.black, fontFamily: 'Poppins SemiBold') ,),
                                  Flexible(child: Text('${client['email'] != '{@nil: true}' ? client['email'] : '' }', style: const TextStyle(fontFamily: 'Poppins Regular'),))
                                ],
                              ),
            
                              Row(
                                children: [
                                  const Text('Telefono: ', style: TextStyle(color: Colors.black, fontFamily: 'Poppins SemiBold') ,),
                                  Flexible(child: Text(client['phone'] != '{@nil: true}' ? client['phone'].toString() : '', style: const TextStyle(fontFamily: 'Poppins Regular'),))
                                ],
                              ),
                               Row(
                                children: [
                                  const Text('Grupo del tercero: ', style: TextStyle(color: Colors.black, fontFamily: 'Poppins SemiBold') ,),
                                  Flexible(child: Text(client['group_bp_name'] != '{@nil: true}' ? client['group_bp_name'].toString() : '', style: const TextStyle(fontFamily: 'Poppins Regular'),))
                                ],
                              ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Tipo de Cont: ', style: TextStyle(color: Colors.black, fontFamily: 'Poppins SemiBold') ,),
                                  Flexible(child: Text(client['tax_payer_type_name'] != '{@nil: true}' ? client['tax_payer_type_name'].toString() : '', style:const TextStyle(fontFamily: 'Poppins Regular') ,overflow: TextOverflow.ellipsis,))
                                ],
                              ),
                              SizedBox(height: mediaScreen * 0.05 ,),
            
                              const Text(
                                "Domicilio Fiscal",
                                textAlign: TextAlign.start,
                                style:  TextStyle(color: Colors.black, fontFamily: 'Poppins Bold', fontSize: 18,),
                                
                              ),
                              SizedBox(height: mediaScreen * 0.05 ,),
                                        Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Dirección: ',
                                  style: TextStyle(fontFamily: 'Poppins SemiBold'),
                                  textAlign: TextAlign.start,
                                ),
                                Text(
                                  client['address'].toString() != '{@nil: true}' ? 
                                    (client['address'].toString().length > 50 ?
                                      '${client['address'].toString().substring(0, 60)}...' :
                                      client['address'].toString()
                                    ) : 
                                    '',
                                  style: const TextStyle(fontFamily: 'Poppins Regular'),
                                  textAlign: TextAlign.justify,
                                
                                ),
                              ],
                            ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('País: ', style: TextStyle(fontFamily: 'Poppins SemiBold',),textAlign: TextAlign.start,),
                                  Flexible(child: Text(client['country'] != '{@nil: true}' ? client['country'] : '', style: const TextStyle(fontFamily: 'Poppins Regular') ,))
                                ],
                              ),
                                Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Ciudad: ', style: TextStyle(fontFamily: 'Poppins SemiBold',),textAlign: TextAlign.start,),
                                  Flexible(child: Text(client['city'] != '{@nil: true}' ? client['city'].toString() : '', style: const TextStyle(fontFamily: 'Poppins Regular') ,))
                                ],
                              ),
                                Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Codigo Postal: ', style: TextStyle(fontFamily: 'Poppins SemiBold',),textAlign: TextAlign.start,),
                                  Flexible(child: Text(client['code_postal'] != '{@nil=true}' ? client['code_postal'].toString() : '', style: const TextStyle(fontFamily: 'Poppins Regular') , overflow: TextOverflow.ellipsis,))
                                ],
                              ),
            
                            ],
                          ),
                        ),
                      ),
               
                  const SizedBox(height: 29,),
                 Container(
                  width: mediaScreen,
                  decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 7,
                              spreadRadius: 2 
                            )
                          ]

                  ) ,
                  child: ElevatedButton(
                    
                    onPressed: () {
                      // Aquí puedes manejar la acción de agregar orden
                      // Por ejemplo, puedes navegar a una pantalla de agregar orden
                     Navigator.push(context,MaterialPageRoute(builder: (context) => OrdenDeVentaScreen(clientId: client["id"] ,clientName: client["bp_name"], cBPartnerId: client['c_bpartner_id'], cBPartnerLocationId: client['c_bpartner_location_id'],rucCbpartner: client['ruc'], emailCustomer: client['email'].toString(), phoneCustomer: client['phone'].toString())),
                    );
            
                    },
                    style:  ButtonStyle(
                      
                      backgroundColor: const MaterialStatePropertyAll<Color>(Color(0xFFA5F52B)),
                      foregroundColor: const MaterialStatePropertyAll<Color>(Colors.black),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // Aquí establece el radio de borde
                        ),
                      ),
                    ) ,
                    child: const Text('Agregar Orden', style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 15),),
            
                  ),
                ),
                SizedBox(height: mediaScreen * 0.02,),
                Container(
                  width: mediaScreen,
                 
                  child: ElevatedButton(
                    
                    onPressed: () {
                      // Aquí puedes manejar la acción de agregar orden
                      // Por ejemplo, puedes navegar a una pantalla de agregar orden
                     Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditClientScreen(client: client)),
                      );
                        
                    },
                    style:  ButtonStyle(
                      
                      backgroundColor: const MaterialStatePropertyAll<Color>(Color(0xFF7531FF)),
                      foregroundColor: const MaterialStatePropertyAll<Color>(Colors.white),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // Aquí establece el radio de borde
                        ),
                      ),
                    ) ,
                    child: const Text('Editar', style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 15),),
            
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
