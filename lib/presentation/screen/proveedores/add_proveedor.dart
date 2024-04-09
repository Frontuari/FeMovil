import 'package:femovil/database/create_database.dart';
import 'package:femovil/database/list_database.dart';
import 'package:femovil/infrastructure/models/clients.dart';
import 'package:femovil/infrastructure/models/providers.dart';
import 'package:femovil/infrastructure/models/vendors.dart';
import 'package:femovil/presentation/screen/proveedores/select_vendor.dart';
import 'package:flutter/material.dart';





class AddProvidersForm extends StatefulWidget {
  const AddProvidersForm({super.key});

  @override
  _AddProvidersFormState createState() => _AddProvidersFormState();
}

class _AddProvidersFormState extends State<AddProvidersForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rucController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _grupoController = TextEditingController();


  // List
  final List<Map<String, dynamic>> _groupVendorList = [];
  final List<Map<String, dynamic>> _taxTypeVendorList = [];
  

  //SELECTED 
   int _selectedGroupIndex = 0;
   int _selectedTaxIndexType = 0;

  //Text o String

   String _groupTextVendor = '';
   String _taxTypeText = '';



    loadList() async {

        List<Map<String, dynamic>> getGroupVendor = await  listarTypeGroupVendor();
        List<Map<String, dynamic>> getTaxTypeVendor = await listarTypeTaxVendor();

          print('Value de getGroupVendor $getGroupVendor ');
          print('Value de getTaxTypeVendor $getTaxTypeVendor');

          _groupVendorList.add({'c_bp_group_id': 0, 'groupbpname': 'Selecciona un Grupo'});
          _taxTypeVendorList.add({'lco_tax_id_type_id': 0, 'tax_id_type_name': 'Selecciona un tipo de impuesto'});


        setState(() {
          
          _groupVendorList.addAll(getGroupVendor);
          _taxTypeVendorList.addAll(getTaxTypeVendor);

        });

    }




@override
  void initState() {

      loadList();

    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 247, 255),
      appBar: AppBar(title: const Text("Agregar Proveedor", style: TextStyle(
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                   const ContainerBlue(label:'Datos Personales',),

                const SizedBox(height: 15),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre del Proveedor', filled: true, fillColor: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el nombre del Proveedor';
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
                        return 'Por favor ingresa un Ruc Valido';
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
                        return 'Por favor ingresa el telefono del Proveedor';
                      }
                      return null;
                    },
                  ),
                   const SizedBox(height: 10,),
                CustomDropdownButtonFormFieldVendor(identifier: 'groupTypeVendor', selectedIndex: _selectedGroupIndex, dataList: _groupVendorList, text: _groupTextVendor, onSelected: (newValue, groupText) {

                    setState(() {

                        _selectedGroupIndex = newValue ?? 0;
                        _groupTextVendor = groupText;

                    });

                },),
                const SizedBox(height: 10,),
                CustomDropdownButtonFormFieldVendor(identifier: 'taxTypeVendor', selectedIndex: _selectedTaxIndexType, dataList:_taxTypeVendorList, text: _taxTypeText, onSelected: (newValue, taxTex) {

                    setState(() {

                        _selectedTaxIndexType = newValue ?? 0;
                        _taxTypeText = taxTex;

                    });

                },),
                const SizedBox(height: 10,),

           
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

      Vendor provider = Vendor(
        cBPartnerId: 1, 
        cCodeId: 1, 
        bPName: "Elias", 
        email: "email", 
        cBPGroupId: 1, 
        groupBPName: "groupBPName", 
        taxId: 1, 
        isVendor: 'Y', 
        lcoTaxIdTypeId: 1, 
        taxIdTypeName: 'taxIdTypeName', 
        cBPartnerLocationId: 1, 
        isBillTo: 'Y', 
        phone: "0414556887", 
        cLocationId: 1, 
        address: "Las palmas", 
        city: "Araure", 
        countryName: "Venezuela", 
        postal: 3303, 
        cCityId: 1, 
        cCountryId: 1);

    // Llama a un método para guardar el producto en Sqflite
    await saveProviderToDatabase(provider);

    // Limpia los controladores de texto después de guardar el producto
    _nameController.clear();
    _rucController.clear();
    _correoController .clear();
    _telefonoController.clear();
    _grupoController.clear();

    // Muestra un mensaje de éxito o realiza cualquier otra acción necesaria
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Proveedor guardado correctamente'),
    ));



  }

  Future<void> saveProviderToDatabase(Vendor provider) async {
    final db = await DatabaseHelper.instance.database;
    if (db != null) {
      int result = await db.insert('providers', provider.toMap());

      if (result != -1) {
        print('El providers se ha guardado correctamente en la base de datos con el id: $result');
      } else {
        print('Error al guardar el providers en la base de datos');
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

class ContainerBlue extends StatelessWidget {
   final String label;
  const ContainerBlue({
    super.key, required this.label,
      
  });

  @override
  Widget build(BuildContext context) {
    return Container(
     width: 200 ,
     decoration: BoxDecoration(
       color: Colors.blue,
       borderRadius: BorderRadius.circular(8), // Establece el radio de los bordes
     ),
     child:  Text(label, style:  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                      );
  }
}









































