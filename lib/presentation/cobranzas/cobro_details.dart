import 'package:femovil/config/app_bar_sampler.dart';
import 'package:flutter/material.dart';




class CobroDetails extends StatelessWidget {
  final Map<String, dynamic> cobro;
  const CobroDetails({super.key, required this.cobro});

  



  @override
  Widget build(BuildContext context) {
    final mediaScreen = MediaQuery.of(context).size.width * 0.8;
    final heightScreen = MediaQuery.of(context).size.height * 1;
    print(  'Esto es el cobro en detalles $cobro');
    return Scaffold(

          appBar: PreferredSize(
              preferredSize: Size.fromHeight(50),
            child: AppBarSample(label: 'Detalles del Cobro')),
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children:  [

            
                SizedBox(height: heightScreen * 0.02,),
              Container( 
                width: mediaScreen,
                height: heightScreen *0.50 ,
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
                  
            
                ) ,
                child: Column(
                  children: [
                    
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: Row(
                            children: [
                          
                                SizedBox(
                                  width: mediaScreen * 0.88,
                                  height: heightScreen * 0.10,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Monto', style: TextStyle(fontFamily:'Poppins Bold', fontSize: 18 ),),
                                      Flexible(child: Text('\$${cobro['pay_amt']}', style: TextStyle(

                                        fontFamily: 'Poppins SemiBold', color: Colors.green, fontSize: 17),))
                                    ],
                                  ),
                                ),
                               
                          
                            ],
                          ),
                        ),
                         Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                          child: Row(
                            children: [
                          
                                SizedBox(
                                  width: mediaScreen * 0.88,
                                  height: heightScreen * 0.07,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Fecha', style: TextStyle(fontFamily:'Poppins Bold', fontSize: 18 ),),
                                      Flexible(child: Text('${cobro['date']}', style: TextStyle(fontFamily: 'Poppins Regular'),))
                                    ],
                                  ),
                                ),
                               
                          
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: SizedBox(
                          width: mediaScreen,
                          child: Text('Detalles', style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 18), textAlign: TextAlign.start,)),
                      ),

                          Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                       child: SizedBox(
                        width: double.infinity,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'N° Documento: ',
                                style: TextStyle(
                                  fontFamily: 'Poppins SemiBold',
                                ),
                              ),
                              TextSpan(
                                text: '${cobro['documentno']}',
                                style: TextStyle(
                                  fontFamily: 'Poppins Regular',
                                  overflow: TextOverflow.ellipsis,
                              
                                ),
                              ),
                            ],
                          ),
                        ),
                       ),
                     ),
            
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                       child: SizedBox(
                        width: double.infinity,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Cuenta Bancaria: ',
                                style: TextStyle(
                                  fontFamily: 'Poppins SemiBold',
                                ),
                              ),
                              TextSpan(
                                text: '${cobro['c_bankaccount_name']}',
                                style: TextStyle(
                                  fontFamily: 'Poppins Regular',
                                  overflow: TextOverflow.ellipsis,
                              
                                ),
                              ),
                            ],
                          ),
                        ),
                       ),
                     ),
                     
            
                       Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                       child: SizedBox(
                        width: mediaScreen ,
                
                        child: Text.rich(
                          
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Tipo de cambio: ',
                                style: TextStyle(
                                  fontFamily: 'Poppins SemiBold',
                                ),
                              ),
                              TextSpan(
                                text: '${cobro['c_currency_iso']}',
                                style: TextStyle(
                                  fontFamily: 'Poppins Regular',
                                  overflow: TextOverflow.ellipsis,
                              
                                ),
                              ),
                            ],
                          ),
                        ),
                       ),
                     ),
            
                       Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                       child: SizedBox(
                        width: mediaScreen ,
                        child: Text.rich(
                          
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Tipo de Pago: ',
                                style: TextStyle(
                                  fontFamily: 'Poppins SemiBold',
                                ),
                              ),
                              TextSpan(
                                text: '${cobro['tender_type_name']}',
                                style: TextStyle(
                                  fontFamily: 'Poppins Regular',
                                  overflow: TextOverflow.ellipsis,
                              
                                ),
                              ),
                            ],
                          ),
                        ),
                       ),
                     ),
                      Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                       child: SizedBox(
                        width: mediaScreen ,
                        // height: heightScreen * 0.056 ,
                        child: Text.rich(
                          
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Descripción: ',
                                style: TextStyle(
                                  fontFamily: 'Poppins SemiBold',
                                ),
                              ),
                              TextSpan(
                                text: '${cobro['description']}',
                                style: TextStyle(
                                  fontFamily: 'Poppins Regular',
                                  overflow: TextOverflow.ellipsis,
                              
                                ),
                              ),
                            ],
                          ),
                        ),
                       ),
                     )                         
            
            
            
                ],) ,
            
              ),
            
            ],
            
                    ),
          ) ,

    );
  }



}

