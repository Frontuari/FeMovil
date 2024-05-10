import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:femovil/config/app_bar_sampler.dart';
import 'package:femovil/config/getPosProperties.dart';
import 'package:femovil/config/get_users.dart';
import 'package:femovil/database/create_database.dart';
import 'package:femovil/database/insert_database.dart';
import 'package:femovil/presentation/orden_venta/product_selection.dart';
import 'package:femovil/presentation/perfil/perfil_http.dart';
import 'package:femovil/presentation/screen/home/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart'; // Importa la librería de formateo de fechas


class OrdenDeVentaScreen extends StatefulWidget {
  final int clientId;
  final String clientName;
  final int cBPartnerId; 
  final int cBPartnerLocationId;
  final String rucCbpartner;
  final String emailCustomer;
  final String phoneCustomer;

  const OrdenDeVentaScreen({super.key, required this.clientId, required this.clientName, required this.cBPartnerId, required this.cBPartnerLocationId, required this.rucCbpartner, required this.emailCustomer, required this.phoneCustomer});

  @override
  _OrdenDeVentaScreenState createState() => _OrdenDeVentaScreenState();
}

class _OrdenDeVentaScreenState extends State<OrdenDeVentaScreen> {
  TextEditingController numeroReferenciaController = TextEditingController();
  TextEditingController fechaController = TextEditingController();
  TextEditingController fechaIdempiereController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  TextEditingController montoController = TextEditingController();
  TextEditingController saldoNetoController = TextEditingController();
  List<Map<String, dynamic>> selectedProducts = [];
  bool _validateDescription = false;
   DateTime selectedDate = DateTime.now();
  double? saldoNeto;
  double? totalImpuesto;
  Map<String, dynamic> infoUserForOrder = {};
    bool isDragging = false;


     double calcularMontoTotal() {
    double total = 0;
    double totalNeto = 0;
    double suma = 0;

    for (var product in selectedProducts) {
        total += product['price'] * product['quantity']*(product['impuesto']/100);
        totalNeto += product['price'] * product['quantity'];

    }
    saldoNetoController.text = '\$${totalNeto.toString()}';
    suma = total + totalNeto;

    print('productos totales $selectedProducts');

    return suma;

  }
double calcularSaldoTotalProducts(String price, dynamic quantity) {
  double prices = double.parse(price);
  double quantitys;

  // Verificar si quantity es un String
  if (quantity is String) {
    // Intentar convertir el String a un número
    try {
      quantitys = double.parse(quantity);
    } catch (e) {
      print('Error al convertir quantity a double: $e');
      // Si hay un error, establecer quantitys como 0
      quantitys = 0.0;
    }
  } else {
    // Si quantity no es un String, asumir que es numérico
    quantitys = quantity.toDouble();
  }

  double sum = prices * quantitys;
  print('price $price & quantity is $quantity');
  print('Suma es $sum');
  return sum;
}


  double calcularSaldoNetoProducto(cantidadProducts, price){
      

        double multi = (cantidadProducts as num).toDouble() *  (price as num).toDouble();

        
          saldoNeto = multi;
      

      return multi;
  }
  double calcularMontoImpuesto(impuesto, monto){

      double montoImpuesto =  monto * impuesto/100;

            totalImpuesto = montoImpuesto;

            print('El monto $monto y el impuesto $impuesto y el monto impuesto seria $montoImpuesto');
    return montoImpuesto;
  }

Future<void> _selectDate(BuildContext context) async {
  final DateTime currentDate = DateTime.now();
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: currentDate,
    firstDate: currentDate,
    lastDate: currentDate,
  );

  if (pickedDate != null) {
    setState(() {
      selectedDate = pickedDate;
      fechaController.text = DateFormat('dd/MM/yyyy').format(selectedDate); // Formato día/mes/año
    });
  }
  
}

void _addOrUpdateProduct(List<Map<String, dynamic>> products) {
  for (var product in products) {
    int index = selectedProducts.indexWhere((element) => element['name'] == product['name']);
    if (index != -1) {
      // Si el producto ya existe, actualizar la cantidad
      setState(() {
        selectedProducts[index]['quantity'] += product['quantity'];
      });
    } else {
      // Si el producto no existe, verificar la disponibilidad antes de agregarlo
      final availableQuantity = product['quantity_avaible'] ?? 0; // Obtener la cantidad disponible del producto
      final selectedQuantity = product['quantity']; // Obtener la cantidad seleccionada
  
      print("cantidad disponible $availableQuantity");

        

        if (selectedQuantity > availableQuantity) {
        // Si la cantidad seleccionada es mayor que la cantidad disponible, mostrar un mensaje de error
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('No hay suficientes ${product['name']} disponibles.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); 
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Si la cantidad seleccionada es menor o igual que la cantidad disponible, agregar el producto a la lista
        setState(() {
          selectedProducts.add(product);
        });
      }
    }
  }
}


void _removeProduct(int index) {
  setState(() {
    selectedProducts.removeAt(index);
    montoController.text = calcularMontoTotal().toString();
  });
}

 initGetUser()async{
    final info = await getApplicationSupportDirectory();
  print("esta es la ruta ${info.path}");

  final String filePathEnv = '${info.path}/.env';
  final File archivo = File(filePathEnv);
  String contenidoActual = await archivo.readAsString();

    Map<String, dynamic> infoLogin =  await getLogin();
     Map<String, dynamic> jsonData = jsonDecode(contenidoActual);


  var orgId = jsonData["OrgID"];
  var clientId = jsonData["ClientID"];
  var wareHouseId = jsonData["WarehouseID"];

    print('Esto es infologin $infoLogin');

    // Map<String, dynamic> getUser = await getUsers(username, password);

    setState(() {
     infoUserForOrder = {'orgid': orgId, 'clientid': clientId, 'warehouseid': wareHouseId, 'userId': infoLogin['userId'] } ;
    });

print('infouserFororder $infoUserForOrder');

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
void initState()  {
      initV();
      initGetUser();
      print('infouser $variablesG');
     fechaController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
     print("Esto es el id ${widget.clientId}");
     print("Esto es el name ${widget.clientName}");
     fechaIdempiereController.text = DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate);
    super.initState();
}

  @override
  Widget build(BuildContext context)  {
    final mediaScreen = MediaQuery.of(context).size.width *0.8;
    return GestureDetector(
      onTap: () {

          FocusScope.of(context).requestFocus(FocusNode());

      },
      child: Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(50) ,
          child: AppBarSample(label: 'Orden de Venta')) ,
        body: SingleChildScrollView(
            
          child: Center(
            child: SizedBox(
              width: mediaScreen,

              child: Column(
                
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height:mediaScreen * 0.05,),

                  SizedBox(
                      width: mediaScreen,
                      
                      child: const Text(
                        "Datos del Cliente",
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.black, fontFamily: 'Poppins Bold', fontSize:  18),
                        
                      ),
                    ),
                  SizedBox(height:mediaScreen * 0.05,),
                  Container(
                      width: mediaScreen,  
                      height: mediaScreen * 0.6,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 7,
                            spreadRadius: 2,
                            color: Colors.grey.withOpacity(0.5)
                          )
                        ]
                      ) ,

                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                            
                                SizedBox(
                                  width: mediaScreen * 0.5,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Nombre', style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 18),),
                                        Text(widget.clientName.length >25 ? widget.clientName.substring(0,25): widget.clientName)
                                      ],
                                    ),
                                  ),
                                ),
                            
                            
                                SizedBox(
                                  width: mediaScreen * 0.4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Ruc/DNI', style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 18),),
                                        Text(widget.rucCbpartner.length > 15 ? widget.rucCbpartner.substring(0,5): widget.rucCbpartner),
                                      ],
                                    ),
                                  ),
                                ),
                              
                            
                            
                            
                              ],
                            ),
                          ),
                           SizedBox(
                            width: mediaScreen,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Detalles', style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 18),textAlign: TextAlign.start,),
                            )),
                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                             child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Correo: ', style: TextStyle(fontFamily: 'Poppins SemiBold'),),
                                Text(widget.emailCustomer == '{@nil: true}' ? '' : widget.emailCustomer, style: const TextStyle(fontFamily: 'Poppins Regular') ,textAlign: TextAlign.start, overflow: TextOverflow.ellipsis,),
                              ],
                             ),
                           ),
                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                             child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Telefono: ', style: TextStyle(fontFamily: 'Poppins SemiBold'),),
                                Text(widget.phoneCustomer == '{@nil: true}' ? '' : widget.phoneCustomer , style: const TextStyle(fontFamily: 'Poppins Regular') ,textAlign: TextAlign.start, overflow: TextOverflow.ellipsis,),
                              ],
                             ),
                           )

                        ],
                      ) ,

                  ),
                   SizedBox(height:mediaScreen * 0.08,),

                   SizedBox(
                      width: mediaScreen,
                      
                      child: const Text(
                        "Detalles de Orden",
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.black, fontFamily: 'Poppins Bold', fontSize:  18),
                        
                      ),
                    ),
                   SizedBox(height:mediaScreen * 0.05,),
                  Container(
                     width: mediaScreen,  
                      height: mediaScreen * 0.20,
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
                    child: TextField(
                      readOnly: true,
                      controller: numeroReferenciaController,
                      decoration:  const InputDecoration(
                        labelStyle: TextStyle(fontFamily: 'Poppins Regular', color: Colors.black),
                        labelText: 'Orden N°',
                      contentPadding:  EdgeInsets.symmetric(
                                vertical: 25, horizontal: 20),
                                  border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide.none, // Color del borde
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 25,
                              ), // Color del borde cuando está enfocado
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 25,
                              ), // Color del borde cuando no está enfocado
                            ),
                      ),
                      
                      keyboardType: TextInputType.number,
                                  
                    ),
                  ),


                     SizedBox(height:mediaScreen * 0.05,),


                 Container(
                    width: mediaScreen,  
                      height: mediaScreen * 0.20,
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
                   child: TextField(

                      controller: fechaController,
                      decoration: InputDecoration(
                         contentPadding:  const EdgeInsets.symmetric(
                                vertical: 25, horizontal: 20),
                              border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide.none, // Color del borde
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 25,
                              ), // Color del borde cuando está enfocado
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 25,
                              ), // Color del borde cuando no está enfocado
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.red)),
                          labelText: 'Fecha',
                          labelStyle: const TextStyle(fontFamily: 'Poppins Regular', color: Colors.black) ,
                          suffixIcon: IconButton(
                            onPressed: () => _selectDate(context),
                            icon: Image.asset('lib/assets/Calendario.png'),
                          ),
                        
                      ),
                      readOnly: true,

                    ),
                 ),
                SizedBox(height:mediaScreen * 0.05,),
 
                Container(
                    width: mediaScreen,  
                      height: mediaScreen * 0.28,
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
                  child: TextField(
                    maxLines: 2,
                      controller: descripcionController,
                      decoration: const InputDecoration(
                        labelStyle: TextStyle(fontFamily: 'Poppins Regular', color: Colors.black),
                        labelText: 'Descripción', 
                      contentPadding:  EdgeInsets.symmetric(
                                vertical: 25, horizontal: 20),
                              border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide.none, // Color del borde
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 25,
                              ), // Color del borde cuando está enfocado
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 25,
                              ), // Color del borde cuando no está enfocado
                            ),
                      ),
                    ),
                ),
                
                  SizedBox(height:mediaScreen * 0.08,),

                   SizedBox(
                      width: mediaScreen,
                      
                      child: const Text(
                        "Productos",
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.black, fontFamily: 'Poppins Bold', fontSize:  18),
                        
                      ),
                    ),
                  SizedBox(height:mediaScreen * 0.05,),
                  
                Container(
                    width: mediaScreen,  
                    height: mediaScreen * 0.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5) ,
                          blurRadius: 7,
                          spreadRadius: 2
                        )
                      ]
                    ) ,
                    child:  Stack(
                      children: [
                        Column(
                        
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  child: Row(
                                  
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                  
                                        Text('Nombre', style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 15),),
                                        Text('Cant.', style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 15)),
                                        Text('Precio',  style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 15))
                                  
                                  
                                  
                                  ],),
                                ),
                                
                                
                        
                                Expanded(
                                  
                            child: ListView.builder(
                              shrinkWrap: true, // Asegura que el ListView tome solo el espacio que necesita
                              itemCount: selectedProducts.length,
                              itemBuilder: (context, index) {
                              final product = selectedProducts[index];
                        
                        
                                return Column(
                                  children:[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                      child: Container(
                                        width: mediaScreen * 0.95,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 70,
                                                child: Text(product['name'])),
                                                SizedBox(width: MediaQuery.of(context).size.width *0.1,),
                                              GestureDetector(
                                                onTap: () {

                                                    if(product['quantity'] <= 0 ){

                                                        return;


                                                    }

                                                  setState(() {
                                                  product['quantity'] -= 1;
                                                 calcularMontoTotal().toStringAsFixed(2);

                                                  print('Productos ${product['quantity_avaible']}');
                                                  

                                                  });
                                                },
                                                child: Image.asset('lib/assets/menos.png', width: 15,)),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(product['quantity'].toString()),
                                              ),
                                              GestureDetector(
                                                onTap: () {

                                                  if(product['quantity']>= product['quantity_avaible']){

                                                      return;

                                                  }

                                                  setState(() {
                                                  product['quantity'] += 1;
                                                  calcularMontoTotal().toStringAsFixed(2);
                                                    
                                                  });
                                                },
                                                child: Container(
                                                  child: Image.asset('lib/assets/Más-2.png', width: 15,))),
                                              
                                              SizedBox(width: MediaQuery.of(context).size.width *0.13,),
                                              Container(
                                                width: mediaScreen * 0.2,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Flexible(child: Text('\$${calcularSaldoTotalProducts(product['price'], product['quantity'].toString())}')),
                                                                                     
                                                    GestureDetector(
                                                      onTap: () {
                                                         setState(() {
                                                          _removeProduct(index);
                                                        });
                                                      },
                                                      child: Image.asset('lib/assets/Eliminar.png'))
                                                  ],
                                                ),
                                              ),
                                              const Divider()
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ] 
                                );
                              },
                            ),
                          ),
                        
                                    Container(
                                      width: mediaScreen,
                                      height: mediaScreen * 0.13,
                                    )
                        
                          ],
                        ),
                        Positioned(
                          top: 120,
                          left: 150,
                          child: GestureDetector(
                          onTap: () async {

                                  final  selectedProductsResult = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProductSelectionScreen()),
                      );
                      print("Cantidad de productos $selectedProductsResult");
                      if (selectedProductsResult != null) {
                        setState(() {
                      
                            _addOrUpdateProduct(selectedProductsResult);
                            
                      
                          montoController.text = '\$${calcularMontoTotal().toStringAsFixed(2)}';
                          
                        });
                      }

                            },
                            child: Image.asset('lib/assets/Más@3x.png',width: 23, )),
                          
                          )
                      ],
                    ) ,
                ),

                SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: selectedProducts.length,
                      itemBuilder: (context, index) {
                        final product = selectedProducts[index];


                        print('Esto es products $product');
                        return Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Cantidad: ${product["quantity"]}'),
                                  Text('Precio: ${product['price']}'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Impuesto: ${product['impuesto']}%'),
                                  Text(
                                    'Monto Impuesto: ${calcularMontoImpuesto(product['impuesto'], product['quantity'] * product['price'])}',
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Saldo Neto: ${calcularSaldoNetoProducto(product['quantity'], product['price']).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    'Monto Total: ${(calcularSaldoNetoProducto(product['quantity'], product['price']) + calcularMontoImpuesto(product['impuesto'], product['quantity'] * product['price'])).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      _removeProduct(index);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                   TextField(
                      readOnly: true,
                    controller: saldoNetoController,
                    decoration: const InputDecoration(labelText: 'Saldo Neto'),
                    keyboardType: TextInputType.number,
                  ),
                    TextField(
                      readOnly: true,
                    controller: montoController,
                    decoration: const InputDecoration(labelText: 'Monto Total'),
                    keyboardType: TextInputType.number,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Aquí puedes mostrar un diálogo o pantalla para seleccionar productos y agregarlos a la orden de venta
                      // Puedes usar Navigator.push para navegar a una pantalla de selección de productos
                      // y agregar los productos seleccionados a la lista selectedProducts
                      // Por ejemplo:
                      
                                
                    
                    },
                    child: const Text('Agregar Productos'),
                  ),
                      
                  const SizedBox(height: 20),
                      
                  ElevatedButton(
                    onPressed: () {
                      // Aquí puedes realizar la transacción y guardar la orden de venta en la base de datos
                      // con los datos proporcionados
                      // Por ejemplo:
              
              
                              if(infoUserForOrder.isNotEmpty) {
                                
                
              
                                //  if (descripcionController.text.isEmpty) {
                                //           setState(() {
                                //             _validateDescription = true; // Marcar como campo inválido si está vacío
                                //           });
                      
                                //                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:  Text('Por favor ingrese una descripción.')));
                      
                      
                                //           return; // Detener el proceso de agregar la orden si el campo está vacío
                                //     }
                      
                      
                      
                                if (selectedProducts.isEmpty) {
                                // Mostrar un diálogo o mensaje indicando que la orden debe tener productos adjuntos
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Error'),
                                      content: const Text('La orden debe tener productos adjuntos.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context); // Cerrar el diálogo
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                      
                                return;
                              }
                      
              
                      final order = {
                        'cliente_id': widget.clientId,
                        'documentno': numeroReferenciaController.text,
                        'fecha': fechaController.text,
                        'descripcion': descripcionController.text,
                        'monto': double.parse(montoController.text.substring(1)),
                        'saldo_neto': double.parse(saldoNetoController.text.substring(1)),
                        'productos': selectedProducts,
                        'c_bpartner_id': widget.cBPartnerId,
                        'c_bpartner_location_id':widget.cBPartnerLocationId,
                        'c_doctypetarget_id': variablesG[0]['c_doc_type_order_id'],
                        'ad_client_id':infoUserForOrder['clientid'],
                        'ad_org_id':infoUserForOrder['orgid'],
                        'm_warehouse_id': infoUserForOrder['warehouseid'],
                        'paymentrule': 'P',
                        'date_ordered': fechaIdempiereController.text,
                        'salesrep_id': infoUserForOrder['userId'],
                        'usuario_id': infoUserForOrder['userId'],
                        'status_sincronized': 'Borrador',
                      };
                      
                      // Luego puedes guardar la orden de venta en la base de datos o enviarla al servidor
                          insertOrder(order).then((orderId) {
              
                                if (orderId is Map<String, dynamic> && orderId.containsKey('failure')) {
                                  if ( orderId['failure'] == -1) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(orderId['Error'],),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  } 
                                } else {
                                  print('orderId no es un mapa válido o no contiene la propiedad "failure"');
                                }
                      
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Orden de venta guardada correctamente con ID: $orderId'),
                                      ),
                                    );
                                  
                            numeroReferenciaController.clear();
                            descripcionController.clear();
                            montoController.clear();
                            saldoNetoController.clear();
                      
                      // Limpiar la lista de productos seleccionados después de guardar la orden
                      setState(() {
                        selectedProducts.clear();
                      });
                      
                      // Notificar al usuario que la orden se ha guardado exitosamente
                    
                    });
                    }
                    },
                    child: const Text('Agregar Orden'),
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
