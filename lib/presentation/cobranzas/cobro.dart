import 'package:femovil/config/app_bar_sampler.dart';
import 'package:femovil/config/getPosProperties.dart';
import 'package:femovil/database/gets_database.dart';
import 'package:femovil/database/insert_database.dart';
import 'package:femovil/database/update_database.dart';
import 'package:femovil/presentation/clients/select_customer.dart';
import 'package:femovil/presentation/cobranzas/cobranzas_list.dart';
import 'package:femovil/presentation/cobranzas/idempiere/create_cobro.dart';
import 'package:femovil/presentation/screen/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



  



class Cobro extends StatefulWidget {
  final int orderId;
  final dynamic cOrderId; 
  final dynamic documentNo;
  final dynamic idFactura;
  
  const Cobro({super.key, required this.orderId, required this.cOrderId, required this.documentNo, required this.idFactura});

  @override
  State<Cobro> createState() => _CobroState();
}


class _CobroState extends State<Cobro> {
  late Future<Map<String, dynamic>> _ordenVenta;
  TextEditingController numRefController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController montoController = TextEditingController();
  TextEditingController observacionController = TextEditingController();
  final TextEditingController _fechaIdempiereController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic> orderData = {}; 
  String? paymentTypeValue = 'Efectivo';
  String? coinValue = "\$";
  String? typeDocumentValue = "Cobro";
  dynamic cBPartnerIds = 0;
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> bankAccountsList = [];
    List<Map<String, dynamic>> typeCoinsList = [];
  List<Map<String, dynamic>> cobrosList = [];
  late Future<void> _bankAccFuture;
  bool enabledButton = true;
  // Selecteds 

  int _selectsBankAccountId =  0; 
  String _selectTypePayment = "X";
  dynamic _selectTypeCoins = 0;
   int _selectCurrencyId = 0;
  //Texts

  String _bankAccountText = "";
   String _currencyText = "";

List<Map<String, dynamic>> uniqueISOsAndCurrencyId = [];

 double parseFormattedNumber(dynamic formattedNumber) {
    if (formattedNumber is String) {
      // Eliminar puntos (separador de miles) y cambiar comas a puntos (separador decimal)
      String cleanedNumber = formattedNumber.replaceAll('.', '').replaceAll(',', '.');
      return double.parse(cleanedNumber.replaceAll('\$', '')); // Elimina el signo de moneda si está presente
    } else if (formattedNumber is int) {
      return formattedNumber.toDouble();
    } else if (formattedNumber is double) {
      return formattedNumber;
    } else {
      throw ArgumentError('Tipo no soportado para el saldo total');
    }
  }

void _loadCurrentDate() {
  final now = DateTime.now();
  final formattedDate = DateFormat('dd/MM/yyyy').format(now);

  dateController.text = formattedDate; // Asigna la fecha actual al controlador del campo de texto
}


 Future<void> _getBankAcc() async {


    print('Entre aqui... ${widget.orderId}');
    List<Map<String, dynamic>> bankAccounts = await getBankAccounts();
     List<Map<String, dynamic>> cobros = await getCobrosByOrderId(widget.orderId);

      cobrosList.addAll(cobros);

      print('Cobros unicos $cobros'); 
      
      bankAccountsList
        .add({'c_bank_id': 0, 'bank_name': 'Selecciona una Cuenta Bancaria'});

        uniqueISOsAndCurrencyId.add({'c_currency_id': 0, 'iso_code': 'Selecciona un tipo de moneda'});

          for (var account in bankAccounts) {

          if (!uniqueISOsAndCurrencyId.any((element) => element['iso_code'] == account['iso_code'])) {
            setState(() {
              
            uniqueISOsAndCurrencyId.add({
              'iso_code': account['iso_code'],
              'c_currency_id': account['c_currency_id']
            });
            });
          }
          
        }



    setState(() {

      bankAccountsList.addAll(bankAccounts);

    });


    print("estos son las cuentas agregadas desde la base de datos $bankAccounts");
}


    initV() async {

        if (variablesG.isEmpty) {

          List<Map<String, dynamic>> response = await getPosPropertiesV();
          setState(() { 
            variablesG = response;
          });

        }
      }


@override
void initState() {

      initV();
    _ordenVenta =  _loadOrdenVentasForId();
    // numRefController.text = cobrosList[0]['documentno'];
    setState(() {
      
       montoController.text = "0";
    });
      _loadCurrentDate();
_bankAccFuture = _getBankAcc();

    _fechaIdempiereController.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate);

  super.initState();


}

 Future<Map<String, dynamic>> _loadOrdenVentasForId() async {
    return await getOrderWithProducts(widget.orderId);
    
  }


  @override
  Widget build(BuildContext context) {
           final screenMax = MediaQuery.of(context).size.width * 0.9;
           final heightScreen = MediaQuery.of(context).size.height * 1;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
      
            appBar: const PreferredSize(
              preferredSize: Size.fromHeight(50),
              child:  AppBarSample(label: 'Cobro')),
      
            body: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: FutureBuilder(
                      future: _ordenVenta,
                      builder: (context,  AsyncSnapshot<Map<String, dynamic>> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child:  CircularProgressIndicator());
                    
                            } else if (snapshot.hasError) {
                              
                              return Text('Error: ${snapshot.error}');
                    
                            }else{
              
                                 final clientData = snapshot.data!['client'][0];
                                 orderData = snapshot.data!['order'];
                                 print("Esto es snapshot data ${snapshot.data}");
              
                                 cBPartnerIds = orderData['c_bpartner_id']; 
              
                             return  Padding(
                               padding: const EdgeInsets.all(16.0),
                               child: Align(
                                  alignment: Alignment.topCenter,
                                 child: SingleChildScrollView(  
                                   child: SizedBox(
                                    width: screenMax,
                                     child: Column(
                                        crossAxisAlignment:  CrossAxisAlignment.center,
                                      children: [
                                      Container(
                                          width: screenMax * 0.85 ,
                                          decoration: BoxDecoration(
                                          
                                            borderRadius: BorderRadius.circular(8), // Establece el radio de los bordes
                                          ),
                                          child: const Text('Datos Del Cliente', style:  TextStyle(fontFamily: 'Poppins Bold', fontSize: 18 ), textAlign: TextAlign.start,),
                                        ),
                                      const SizedBox(height: 10,),
                                     
                                       Container(
                                        width: screenMax * 0.85,
                                        height: heightScreen * 0.35,
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
                                          padding: const EdgeInsets.symmetric(horizontal:10, vertical: 15),
                                          child:  Column(
                                            
                                            children: [
                                          
                                                Row(
                                                  children:  [
                                                    SizedBox(
                                                      width: screenMax * 0.40,
                                                      height: heightScreen * 0.15,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                           
                                                             const Text('Nombre', style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 18), textAlign: TextAlign.start,),
                                                              SizedBox(height: heightScreen * 0.02,),
              
                                                              Flexible(child: Text('${clientData['bp_name']}', style: const TextStyle(fontFamily: 'Poppins Regular'),))
                                                      
                                                        ],
                                                      ),
                                                    ),
                                          
                                                    
                                                    SizedBox(
                                                      width: screenMax * 0.35,
                                                      height: heightScreen * 0.15,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text('Ruc/DNI', style:  TextStyle(fontFamily: 'Poppins Bold', fontSize: 18),),
                                                          SizedBox(height: heightScreen * 0.02,),
              
                                                           Flexible(child: Text(clientData['ruc'], style: const TextStyle(fontFamily: 'Poppins Regular'),))
                                                       
                                                        ],
                                                      ))
              
                                                  ],
                                                ),
              
              
                                                SizedBox(
                                                  width: screenMax,
                                                  child: const Text('Detalles', style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 18),textAlign: TextAlign.left,)),
              
                                                  SizedBox(height: heightScreen * 0.02,),
                                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(fontFamily: 'Poppins SemiBold', color: Colors.black),
                                          children: [
                                            const TextSpan(text: 'Correo: '),
                                            TextSpan(
                                              text: clientData['email'] != '{@nil: true}' ? clientData['email']: "",
                                              style: const TextStyle(fontFamily: 'Poppins Regular'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                     Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(fontFamily: 'Poppins SemiBold', color: Colors.black),
                                          children: [
                                            const TextSpan(text: 'Telefono: '),
                                            TextSpan(
                                              text: clientData['phone'] != '{@nil: true}'? clientData['phone'].toString(): '',
                                              style: const TextStyle(fontFamily: 'Poppins Regular'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),  
                                  Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(fontFamily: 'Poppins SemiBold', color: Colors.black),
                                          children: [
                                            const TextSpan(text: 'Saldo: '),
                                            TextSpan(
                                              text: orderData['saldo_total'] != '{@nil: true}'? '\$${orderData['saldo_total'].toString()}': '',
                                              style: const TextStyle(fontFamily: 'Poppins Regular'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )         
                              ],
                            ),
                          ),
                        ),
              
                                      SizedBox(height: heightScreen * 0.02,),
              
                            SizedBox(
                              width: screenMax * 0.85,
                              child: const Text('Detalles de Orden', style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 18),textAlign: TextAlign.start,)),
                                    
                                     SizedBox(height: heightScreen * 0.02,),
  
                                   CustomTextInfo(
                                      label: "Orden N°",
                                      value: orderData['documentno'].toString() != "" ? orderData['documentno'].toString() : "",
                                      mediaScreen: screenMax,
                                      heightScreen: heightScreen,
                                    ),

                                   orderData['documentno_factura'] != null ? SizedBox(height: heightScreen * 0.02,) : Container(),
                                    
                                     orderData['documentno_factura'] != null ? CustomTextInfo(
                                      label: "N° Documento, Factura",
                                      value: orderData['documentno_factura'].toString() != "" ? orderData['documentno_factura'].toString() : "",
                                      mediaScreen: screenMax,
                                      heightScreen: heightScreen,
                                    ): Container(),
                                     SizedBox(height: heightScreen * 0.015,),
              
                                      CustomTextInfo(
                                                     label: "Fecha",
                                                     value: orderData['fecha'].toString(),
                                                     mediaScreen: screenMax,
                                                     heightScreen: heightScreen,
                                                   ),
              
                                     SizedBox(height: heightScreen * 0.015,),
              
                                        Column(
                                          children: [
                                          
                                           Container(
                                            width: screenMax * 0.85,
                                            decoration: BoxDecoration(
                                             
                                              borderRadius: BorderRadius.circular(8), // Establece el radio de los bordes
                                            ),
                                            child: const Text('Cobranza', style:  TextStyle(fontFamily: 'Poppins Bold', fontSize: 18), textAlign: TextAlign.start,),
                                           ),
              
                                          SizedBox(height: heightScreen * 0.015,),
              
                                            Container(
                                              width: screenMax,
                                              decoration: BoxDecoration(
                                                  borderRadius:  BorderRadius.circular(8),
                                              ),
                                                child:  Column(
                                                    children: [

                                                Container(
                                                     height: heightScreen * 0.1,
                                                     width: screenMax * 0.85,
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
                                                    child: TextFormField(
                                                      controller: numRefController,
                                                      decoration: const InputDecoration(
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                                          borderSide: BorderSide(width: 25, color: Colors.white )
                                                        ),
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                                          borderSide: BorderSide.none
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                                          borderSide: BorderSide(width: 25, color: Colors.white)
                                                        ),
                                                        errorBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                                          borderSide: BorderSide(width: 1, color: Colors.red)
                                                        ),
                                                        focusedErrorBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                                          borderSide: BorderSide(width: 1, color: Colors.red)
                                                        ),
                                                        labelText: "Numero de Referencia",
                                                        labelStyle: TextStyle(fontFamily: 'Poppins Regular'),
                                                        contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 25),
                                                      ),
                                                      keyboardType: TextInputType.number,                            
                                                    ),
                                                  ),
                                    
                                                      
                                               SizedBox(height: heightScreen * 0.013,),

                                                  FutureBuilder<void>(future: _bankAccFuture, builder: (context, snapshot) {
                                                         
                                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                                        return const Center(child: CircularProgressIndicator());
                                                      } else if (snapshot.hasError) {
                                                        return Text('Error: ${snapshot.error}');
                                                      } else {
                
                                                      return Column(children: [
                                                             CustomDropdownButtonFormField(identifier: 'selectTypeAccountBank', selectedIndex: _selectsBankAccountId , dataList: bankAccountsList, text: _bankAccountText, onSelected: (newValue, bankAccText) {
                                                          setState(() {
                                                              _selectsBankAccountId = newValue ?? 0;
                                                              _bankAccountText = bankAccText;
                                                          });
                                                      },),
                                                  SizedBox(height: heightScreen * 0.013,),
              
              
                                                  CustomDropdownButtonFormField(identifier: 'selectTypeCoins', selectedIndex: _selectCurrencyId , dataList: uniqueISOsAndCurrencyId, text: _currencyText, onSelected: (newValue, currectText) {
                                                          setState(() {
                                                              _selectCurrencyId = newValue ?? 0;
                                                              _currencyText = currectText;
                                                          });
                                                      },)
                                                      
              
                                                      ],);
                                                    }
                                                  }
                                                  ),
              
              
              
              
                                               
                                                SizedBox(height: heightScreen * 0.013,),
              
              
                                     
                                                  Container(
                                                     height: heightScreen * 0.1,
                                                      width: screenMax * 0.85,
                                                      decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(15),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            blurRadius: 7,
                                                            spreadRadius: 2,
                                                            color: Colors.grey.withOpacity(0.5))
                                                      ],
                                                    ),
                                                    child: DropdownButtonFormField<String>(
                                                    value: paymentTypeValue,
                                                    onChanged: (String? newValue) {
                                                      setState(() {
                                                        paymentTypeValue = newValue;
                                                                                       
                                                                                       
                                                      });
                                                                                       
                                                      if(newValue == 'Depósito Directo'){
                                                                                       
                                                          setState(() {
                                                            _selectTypePayment = 'A';
                                                          });
                                                                                       
                                                      }else if(newValue == 'Tarjeta de Crédito'){
                                                                                       
                                                          setState(() {
                                                            _selectTypePayment = 'C';
                                                          });
                                                                                       
                                                      }else if(newValue == "Cheque"){
                                                                                       
                                                          setState(() {
                                                            _selectTypePayment = 'K';
                                                          });
                                                                                       
                                                      }else if(newValue == "Cuenta"){
                                                                                       
                                                          setState(() {
                                                            _selectTypePayment = 'T';
                                                          });
                                                                                       
                                                      }else if(newValue == 'Efectivo' ){
                                                                                       
                                                          setState(() {
                                                            _selectTypePayment = 'X';
                                                          });
                                                                                       
                                                      }else if(newValue == 'Débito Directo'){
                                                                                       
                                                          setState(() {
                                                            _selectTypePayment = 'D';
                                                          });
                                                                                       
                                                      }
                                                                                       
                                                      print('Este es el valor de paymentTypeValue $paymentTypeValue && este es el valor de $_selectTypePayment');
                                                    },
                                                    items: <String>['Depósito Directo', 'Tarjeta de Crédito', 'Cheque', 'Cuenta', 'Efectivo', 'Débito Directo' ].map((String value) {
                                                    return DropdownMenuItem<String>(
                                                      value: value,
                                                      child: Text(value, style: const TextStyle(fontFamily: 'Poppins Regular'),),
                                                    );
                                                    }).toList(),
                                                    decoration:  InputDecoration(
                                                        errorStyle: const TextStyle(fontFamily: 'Poppins Regular'),
                                                    contentPadding:
                                                        const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                                                      border: OutlineInputBorder(
                                                      borderSide: BorderSide.none,
                                                      borderRadius: BorderRadius.circular(15),
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(15),
                                                      borderSide: const BorderSide(width: 25, color: Colors.white)
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(15),
                                                      borderSide:  const BorderSide(width: 25, color: Colors.white)
                                                    ),
                                                      labelText: 'Tipo de Pago',
                                                    labelStyle: const TextStyle(fontFamily: 'Poppins Regular'),
                                                    ),
                                                  ),
                                                  ),
                                     
                                                  SizedBox(height: heightScreen * 0.013,),
              
                                                  Container(
                                                     height: heightScreen * 0.1,
                                                     width: screenMax * 0.85,
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
                                                    child: TextFormField(
                                                      readOnly: true,
                                                      controller: dateController,
                                                    
                                                      decoration: const InputDecoration(
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                                          borderSide: BorderSide(width: 25, color: Colors.white )
                                                        ),
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                                          borderSide: BorderSide.none
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                                          borderSide: BorderSide(width: 25, color: Colors.white)
                                                        ),
                                                        labelText: "Fecha",
                                                        contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 25),
                                                      ),
                                                    ),
                                                  ),
                                     
                                                  SizedBox(height: heightScreen * 0.013,),
                                
                                     
                                                  Container(
                                                     height: heightScreen * 0.1,
                                                     width: screenMax * 0.85,
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
                                                    child: TextFormField(
                                                      controller: montoController,
                                                      decoration: const InputDecoration(
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                                          borderSide: BorderSide(width: 25, color: Colors.white )
                                                        ),
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                                          borderSide: BorderSide.none
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                                          borderSide: BorderSide(width: 25, color: Colors.white)
                                                        ),
                                                        errorBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                                          borderSide: BorderSide(width: 1, color: Colors.red)
                                                        ),
                                                        focusedErrorBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                                          borderSide: BorderSide(width: 1, color: Colors.red)
                                                        ),
                                                        labelText: "Monto",
                                                        contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 25),
                                                      ),
                                                      keyboardType: TextInputType.number,
                                                      validator: (value) {

                                                          if(value!.isEmpty || value == '0' ||  value.contains('-') || value.contains(',') ){

                                                              return "El monto tiene caracteres invalidos, esta vacio";
                                                          }

                                                          return null;

                                                      },                             
                                                    ),
                                                  ),
                                     
                                                    SizedBox(height: heightScreen * 0.013,),
              
                                                        Container(
                                                          height: heightScreen * 0.1,
                                                          width: screenMax * 0.85,
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
                                                          child: TextFormField(
                                                            controller: observacionController,
                                                            decoration: const InputDecoration(
                                                               focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                                          borderSide: BorderSide(width: 25, color: Colors.white )
                                                        ),
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                                          borderSide: BorderSide.none
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                                          borderSide: BorderSide(width: 25, color: Colors.white)
                                                        ),
                                                              labelText: "Observacion",
                                                        contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 25),
                                                            ),
                                                          ),
                                                        ),
                                     
                                                 
                                                    ],
                                     
                                                ),
                                     
                                            ),  
                                            SizedBox(height: heightScreen * 0.025),
              
                                            ElevatedButton(
                                              onPressed: orderData['status_sincronized'] == 'Enviado' && orderData['saldo_total'] > 0 && enabledButton ? () async {                                                             
                                     
                                                if (_formKey.currentState!.validate()) {

                                                  setState(() {
                                                    enabledButton = false;
                                                  });
                                                  
                                                  await _createCobro();
              
                                                  setState(() {
                                                    _ordenVenta = _loadOrdenVentasForId();
                                                  });
                                                               
                                                }
                                              } : null,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: (const Color(0xFF7531FF)),
                                                foregroundColor: Colors.white, // Color de fondo verde
                                                minimumSize: Size(screenMax * 0.85, 50), // Ancho máximo y altura de 50
                                              ),
                                              child: Text(
                                                !enabledButton ? 'Procesando...' : 'Crear Cobro',
                                                style: TextStyle(fontSize: 16, fontFamily: 'Poppins Bold'), // Tamaño de fuente 16
                                              ),
                                            ),
                                            SizedBox(height: heightScreen * 0.025),              
                                                                                  
                                          ],
                                        ),
                                                                
                                     ],                        
                                                                     ),
                                   ),
                                 ),
                               ),
                             );
                          }
                   }, 
              ),
            ),
      ),
    );
  }

  Future<void> _createCobro() async {
    final dynamic bankAccountId = _selectsBankAccountId;
    //Tipo del documento de cobro
    final dynamic cDocTypeId = variablesG[0]['c_doctypereceipt_id'];
    final dynamic dateTrx = _fechaIdempiereController.text;
    final dynamic description = observacionController.text;
    final dynamic cBPartnerId = cBPartnerIds;
    final double payAmt = double.parse(montoController.text);
    final dynamic currencyId = _selectTypeCoins;
    final dynamic cOrderId = widget.cOrderId;
    final dynamic cInvoiceId = widget.idFactura;
    final dynamic tenderType = _selectTypePayment;
    final String typeMoney = _currencyText;
    final String bankAccount = _bankAccountText;
    final String tenderTypeT = paymentTypeValue!;

    print('Esto es numRef ${numRefController.text}  es currencyId $currencyId y este es el orderId $cOrderId y este es el id de la factura $cInvoiceId');

    // final int documentNo = int.parse(numRefController.text == 'Sin registro'  ? numRefController.text = '0': numRefController.text);

    final String date = dateController.text;

    final int saleOrderId = widget.orderId;

    // Obtener el saldo total de la orden

    final double saldoTotal;

    if (orderData['saldo_total'] is double) {
      saldoTotal = orderData['saldo_total'];
    } else if (orderData['saldo_total'] is String) {
      saldoTotal = double.parse(orderData['saldo_total']);
    } else {
      // Manejar el caso en el que `saldo_total` no sea ni `double` ni `String`
      throw Exception('El tipo de saldo_total no es ni double ni String');
    }


    if (payAmt > saldoTotal) {
      // Si el monto del cobro es mayor al saldo total, mostrar mensaje de diálogo
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('El cobro no puede ser mayor al saldo total de la orden.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar el diálogo
                },
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
    } 
    else if (payAmt <= 0 || saldoTotal <= 0 ) {

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('El cobro no puede ser menor o igual a 0.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar el diálogo
                },
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
    } 
    else {
      // Si el monto del cobro es menor o igual al saldo total, insertar el cobro en la base de datos
      Map<String, dynamic> cobro = {
        "c_bankaccount_id" : bankAccountId, 
        "c_doctype_id" : cDocTypeId, 
        "date_trx" : dateTrx, 
        "description" : description,
        "c_bpartner_id": cBPartnerId, 
        "pay_amt": payAmt.toStringAsFixed(2), 
        "c_currency_id": _selectCurrencyId,
        "c_order_id":  cOrderId, 
        "c_invoice_id": cInvoiceId,
        "tender_type": tenderType,
        "c_number_ref": numRefController.text     
      };

      int cobroId = await insertCobro(
        cBankAccountId: bankAccountId,
        cDocTypeId: cDocTypeId,
        dateTrx: dateTrx,
        date: date,
        description: description,
        cBPartnerId: cBPartnerId,
        payAmt: payAmt.toStringAsFixed(2),
        cCurrencyId: _selectCurrencyId,
        cOrderId: cOrderId,
        cInvoiceId: cInvoiceId,
        documentNo: 0,
        tenderType: tenderType ,
        saleOrderId: saleOrderId,
        bankAccountT: bankAccount,
        cCurrencyIso: typeMoney,
        tenderTypeName: tenderTypeT ,
      );

      // setState(() {
        // _loadOrdenVentasForId();
      // });

      dynamic response = await createCobroIdempiere(cobro);


      print('Respuesta del cobro $response');

      dynamic numDoc = response['CompositeResponses']['CompositeResponse']['StandardResponse'][0]['outputFields']['outputField'][1]['@value'];
      print('Esto es cobroId $cobroId, y numdoc $numDoc');
    
      await updateDocumentNoCobro(cobroId, numDoc);
      
      print('NumDoc $numDoc');
      print("esto es el cobro $cobro y la respuesta $response" );


      // Limpiar los campos de texto después de insertar el cobro
      numRefController.clear();
      montoController.clear();
      observacionController.clear();
    
      setState(() {
        _selectCurrencyId = 0;
        _selectsBankAccountId = 0;
        enabledButton = true;
      });

      // Mostrar un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cobro creado con éxito')));

      Navigator.push(context, MaterialPageRoute(builder: (context) => Cobranzas()));
    }

    setState(() {
      enabledButton = true;
    });
  }
}




class CustomTextInfo extends StatelessWidget {
  final String label;
  final String value;
  final double mediaScreen;
  final double heightScreen;

  const CustomTextInfo({
    super.key,
    required this.label,
    required this.value,
    required this.mediaScreen,
    required this.heightScreen
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: mediaScreen * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 7,
              spreadRadius: 2 
            )
          ],
          borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5 ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            const SizedBox(height: 5,),
            Text(value, style: const TextStyle(fontFamily: 'Poppins Regular'),),
          ],
        ),
      ),
    );
  }
}
