import 'package:femovil/presentation/orden_venta/product_selection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importa la librería de formateo de fechas


class OrdenDeVentaScreen extends StatefulWidget {
  final int clientId;
  final String clientName;

  const OrdenDeVentaScreen({super.key, required this.clientId, required this.clientName});

  @override
  _OrdenDeVentaScreenState createState() => _OrdenDeVentaScreenState();
}

class _OrdenDeVentaScreenState extends State<OrdenDeVentaScreen> {
  TextEditingController numeroReferenciaController = TextEditingController();
  TextEditingController fechaController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  TextEditingController montoController = TextEditingController();

  List<Map<String, dynamic>> selectedProducts = [];
   DateTime selectedDate = DateTime.now();

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

@override
void initState() {
  
    print("Esto es el id ${widget.clientId}");
     print("Esto es el name ${widget.clientName}");
    super.initState();
  
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orden de Venta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: numeroReferenciaController,
              decoration: InputDecoration(labelText: 'Número de Referencia'),
            ),
           TextField(
              controller: fechaController,
              decoration: InputDecoration(
                labelText: 'Fecha',
                suffixIcon: IconButton(
                  onPressed: () => _selectDate(context),
                  icon: Icon(Icons.calendar_today),
                ),
              ),
              readOnly: true,
            ),
                        TextFormField(
              readOnly: true,
              controller: TextEditingController(text: widget.clientName),
              decoration: InputDecoration(labelText: 'Nombre del Cliente'),
            ),
            TextField(
              controller: descripcionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
          
            SizedBox(height: 20),
            Text(
              'Productos:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: selectedProducts.length,
                itemBuilder: (context, index) {
                  final product = selectedProducts[index];
                  return ListTile(
                    title: Text(product['name']),
                    subtitle: Text('Precio: ${product['price']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          selectedProducts.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
              TextField(
                readOnly: true,
              controller: montoController,
              decoration: InputDecoration(labelText: 'Monto'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () async {
                // Aquí puedes mostrar un diálogo o pantalla para seleccionar productos y agregarlos a la orden de venta
                // Puedes usar Navigator.push para navegar a una pantalla de selección de productos
                // y agregar los productos seleccionados a la lista selectedProducts
                // Por ejemplo:
                final  selectedProductsResult = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductSelectionScreen()),
                );
                if (selectedProductsResult != null) {
                  setState(() {
                    selectedProducts = selectedProductsResult;
                  });
                }
              },
              child: Text('Agregar Productos'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aquí puedes realizar la transacción y guardar la orden de venta en la base de datos
                // con los datos proporcionados
                // Por ejemplo:
                // final order = {
                //   'cliente_id': widget.clientId,
                //   'numero_referencia': numeroReferenciaController.text,
                //   'fecha': fechaController.text,
                //   'descripcion': descripcionController.text,
                //   'monto': double.parse(montoController.text),
                //   'productos': selectedProducts, // Esta lista contendría los detalles de los productos seleccionados
                // };
                // // Luego puedes guardar la orden de venta en la base de datos o enviarla al servidor
                // // DatabaseHelper.instance.insertOrder(order);
                // // Notificar al usuario que la orden se ha guardado exitosamente
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content: Text('Orden de venta guardada correctamente'),
                //   ),
                // );
              },
              child: Text('Agregar Orden'),
            ),
          ],
        ),
      ),
    );
  }
}
