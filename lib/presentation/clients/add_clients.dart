import 'package:femovil/database/create_database.dart';
import 'package:femovil/infrastructure/models/clients.dart';
import 'package:femovil/infrastructure/models/products.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';





class AddClientsForm extends StatefulWidget {
  const AddClientsForm({super.key});

  @override
  _AddClientsFormState createState() => _AddClientsFormState();
}

class _AddClientsFormState extends State<AddClientsForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rucController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _grupoController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 247, 255),
      appBar: AppBar(title: const Text("Agregar Cliente", style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Color.fromARGB(255, 105, 102, 102),
          ),),
             backgroundColor: const Color.fromARGB(255, 236, 247, 255),
             iconTheme: const IconThemeData(color: Color.fromARGB(255, 105, 102, 102)),
    
           ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          
          width: 250,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                const SizedBox(height: 15),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre del Cliente', filled: true, fillColor: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el nombre del Cliente';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _rucController,
                    decoration: const InputDecoration(labelText: 'Ruc/Dni', filled: true, fillColor: Colors.white),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un Ruc/Dni Valido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10,),
                  TextFormField(
                    controller: _correoController,
                    decoration: const InputDecoration(labelText: 'Correo', filled: true, fillColor: Colors.white),
                    keyboardType: TextInputType.number,
                     validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un correo';
                      }
                      return null;
                    },
                  ),
                   const SizedBox(height: 10,),
                  TextFormField(
                    controller: _telefonoController,
                    decoration: const InputDecoration(labelText: 'Telefono', filled: true, fillColor: Colors.white),
                    keyboardType: TextInputType.number,
                     validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el telefono del cliente';
                      }
                      return null;
                    },
                  ),
                   const SizedBox(height: 10,),
                  TextFormField(
                    controller: _grupoController,
                    decoration: const InputDecoration(labelText: 'Grupo', filled: true, fillColor: Colors.white),
                    keyboardType: TextInputType.number,
                     validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el grupo del cliente';
                      }
                      return null;
                    },
                  ),
           
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Guarda el producto en la base de datos Sqflite
                            _saveProduct();
                          }
                        },
                         style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                         shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(10.0), 
                        ),
                         ),
                        child: const Text('Guardar'),
                      ),
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

  void _saveProduct() async {
    // Obtén los valores del formulario
    String name = _nameController.text;
    double ruc = double.parse(_rucController.text);
    String correo = _correoController.text;
    int telefono = int.parse(_telefonoController.text);
    String grupo = _grupoController.text;

    // Crea una instancia del producto
    Cliente client = Cliente(
        name: name,
        ruc:ruc,
        correo: correo,
        telefono: telefono,
        grupo: grupo,
    );

    // Llama a un método para guardar el producto en Sqflite
    await saveClientToDatabase(client);

    // Limpia los controladores de texto después de guardar el producto
    _nameController.clear();
    _rucController.clear();
    _correoController .clear();
    _telefonoController.clear();
    _grupoController.clear();

    // Muestra un mensaje de éxito o realiza cualquier otra acción necesaria
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Cliente guardado correctamente'),
    ));



  }

  Future<void> saveClientToDatabase(Cliente product) async {
    final db = await DatabaseHelper.instance.database;
    if (db != null) {
      int result = await db.insert('clients', product.toMap());

      if (result != -1) {
        print('El Cliente se ha guardado correctamente en la base de datos con el id: $result');
      } else {
        print('Error al guardar el Cliente en la base de datos');
      }
    } else {
      // Manejar el caso en el que db sea null, por ejemplo, lanzar una excepción o mostrar un mensaje de error
      print('Error: db is null');
    }
  }

  @override
  void dispose() {
    // Limpia los controladores de texto cuando el widget se elimina del árbol

    _nameController.dispose();
    _rucController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _grupoController.dispose();

    super.dispose();
  }
}









































