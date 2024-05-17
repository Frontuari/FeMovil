import 'package:femovil/config/app_bar_sampler.dart';
import 'package:femovil/database/create_database.dart';
import 'package:femovil/database/list_database.dart';
import 'package:femovil/database/update_database.dart';
import 'package:femovil/presentation/screen/proveedores/add_proveedor.dart';
import 'package:femovil/presentation/screen/proveedores/select_vendor.dart';
import 'package:flutter/material.dart';

class EditProviderScreen extends StatefulWidget {
  final Map<String, dynamic> provider;

  const EditProviderScreen({super.key, required this.provider});

  @override
  _EditProviderScreenState createState() => _EditProviderScreenState();
}

class _EditProviderScreenState extends State<EditProviderScreen> {
  final _nameController = TextEditingController();
  final _rucController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _codePostalController = TextEditingController();

   // List
  final List<Map<String, dynamic>> _groupVendorList = [];
  final List<Map<String, dynamic>> _taxTypeVendorList = [];
  final List<Map<String, dynamic>> _countryVendorList = [];
  final List<Map<String, dynamic>> _taxPayerList = [];
  final List<Map<String, dynamic>> _typePersonList = [];

  //SELECTED 
   int _selectedGroupIndex = 0;
   int _selectedTaxIndexType = 0;
   int _selectedCountryIndex = 0;
   int _selectedTaxPayerIndex = 0;
   int _selectedPersonTypeIndex = 0;

  //Text o String

   String _groupTextVendor = '';
   String _taxTypeText = '';
   String _countryTex = '';
   String _taxPayerText = '';
   String _personTypeText = '';


    loadList() async {
      

        List<Map<String, dynamic>> getGroupVendor = await  listarTypeGroupVendor();
        List<Map<String, dynamic>> getTaxTypeVendor = await listarTypeTaxVendor();
        List<Map<String, dynamic>> getCountryVendor = await listarCountryVendor();
        List<Map<String, dynamic>> getTaxPayerVendor = await listarTaxPayerVendors();
        List<Map<String, dynamic>> getTypePerson = await listarPersonTypeVendors();

          print('Value de getGroupVendor $getGroupVendor ');
          print('Value de getTaxTypeVendor $getTaxTypeVendor');

          _groupVendorList.add({'c_bp_group_id': 0, 'groupbpname': 'Selecciona un Grupo'});
          _taxTypeVendorList.add({'lco_tax_id_type_id': 0, 'tax_id_type_name': 'Selecciona un tipo de impuesto'});
          _countryVendorList.add({'c_country_id': 0, 'country_name': 'Selecciona un Pais'});
          _taxPayerList.add({'lco_taxt_payer_type_id': 0, 'tax_payer_type_name': 'Selecciona un tipo de contribuyente' });
          _typePersonList.add({'lve_person_type_id': 0, 'person_type_name': 'Selecciona un tipo de persona'});


        setState(() {
          
          _groupVendorList.addAll(getGroupVendor);
          _taxTypeVendorList.addAll(getTaxTypeVendor);
          _countryVendorList.addAll(getCountryVendor);
          _taxPayerList.addAll(getTaxPayerVendor);
          _typePersonList.addAll(getTypePerson);
        });

    }


  @override
  void initState() {
    super.initState();
    loadList();
    print('Esto es el provider tax payer ${widget.provider['lco_taxt_payer_type_id']}');
    print('Esto es el country de provider ${widget.provider['c_country_id']}');
    // Initialize controllers with existing product details
    _nameController.text = widget.provider['bpname'].toString();
    _rucController.text = widget.provider['tax_id'].toString();
    _correoController.text = widget.provider['email'].toString() != '{@nil=true}' ? widget.provider['email'].toString() : '' ;
    _telefonoController.text = widget.provider['phone'].toString() != '{@nil=true}' ? widget.provider['phone'].toString() : '' ;
    _groupTextVendor = widget.provider['groupbpname'].toString();
    _taxPayerText = widget.provider['tax_payer_type_name'].toString();
    _taxTypeText = widget.provider['tax_id_type_name'].toString();
    // _personTypeText = widget.provider['person_type_name'].toString();
    _countryTex = widget.provider['country_name'].toString();
    _selectedGroupIndex = widget.provider['c_bp_group_id'];
    _selectedTaxIndexType = widget.provider['lco_tax_id_type_id'] != '{@nil=true}' ? widget.provider['lco_tax_id_type_id'] : 0 ;
    _selectedTaxPayerIndex = widget.provider['lco_taxt_payer_type_id'] != '{@nil=true}' ? widget.provider['lco_taxt_payer_type_id'] : 0;
    // _selectedPersonTypeIndex = widget.provider['lve_person_type_id'];
    _selectedCountryIndex = widget.provider['c_country_id'].toString() != '{@nil=true}' ? widget.provider['c_country_id']: 0;
    _addressController.text = widget.provider['address'].toString() != '{@nil=true}' ? widget.provider['address'].toString(): '';
    _cityController.text = widget.provider['city'].toString() != '{@nil=true}' ? widget.provider['city']  : '';
    _codePostalController.text = widget.provider['postal'].toString() != '{@nil=true}' ? widget.provider['postal'].toString(): '';
 
  }


  @override
  Widget build(BuildContext context) {
    
    final mediaScreen = MediaQuery.of(context).size.width * 0.8;

    return GestureDetector(
      onTap: () {

       FocusScope.of(context).requestFocus(FocusNode());

      },
      child: Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(50),
          child:  AppBarSample(label: 'Editar Proveedor')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction ,
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 5),
                     ContainerBlue(label: 'Detalles', mediaScreen: mediaScreen),
                    const SizedBox(height: 10,),
                    _buildTextFormField('Nombre', _nameController,1, mediaScreen),
                    _buildTextFormField('Ruc', _rucController,1, mediaScreen),
                    _buildTextFormField('Correo', _correoController, 1, mediaScreen),
                    _buildTextFormField('Telefono', _telefonoController,1, mediaScreen),
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
                  CustomDropdownButtonFormFieldVendor(identifier: 'taxPayerVendor', selectedIndex: _selectedTaxPayerIndex, dataList:_taxPayerList, text: _taxPayerText, onSelected: (newValue, taxPayerText) {
              
                      setState(() {
              
                          _selectedTaxPayerIndex = newValue ?? 0;
                          _taxPayerText = taxPayerText;
              
                      });
              
                  },),
                    //  const SizedBox(height: 10,),
                  // CustomDropdownButtonFormFieldVendor(identifier: 'typePersonVendor', selectedIndex: _selectedPersonTypeIndex, dataList:_typePersonList, text: _personTypeText, onSelected: (newValue, personTypeText) {
              
                  //     setState(() {
              
                  //         _selectedPersonTypeIndex = newValue ?? 0;
                  //         _personTypeText = personTypeText;
              
                  //     });
              
                  // },),
                const SizedBox(height: 10,),
              
                   ContainerBlue(label: 'Domicilio Fiscal', mediaScreen: mediaScreen,),
                 const SizedBox(height: 10,),
                  CustomDropdownButtonFormFieldVendor(identifier: 'countryVendor', selectedIndex: _selectedCountryIndex, dataList:_countryVendorList, text: _countryTex, onSelected: (newValue, countryText) {
              
                    setState(() {
              
                        _selectedCountryIndex = newValue ?? 0;
                        _countryTex = countryText;
              
                    });
              
                },),
                  const SizedBox(height: 10,),
                 _buildTextFormField('Ciudad', _cityController, 1 , mediaScreen),
                _buildTextFormField('Direccion', _addressController, 2, mediaScreen),
                _buildTextFormField('Codigo Postal', _codePostalController, 1, mediaScreen),
                
                Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Container(
                        width: mediaScreen * 0.95,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 7,
                              spreadRadius: 2
                            )
                          ]
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // Guarda el producto en la base de datos Sqflite

                              String newName = _nameController.text;
                              String newRuc = _rucController.text;
                              String newCorreo = _correoController.text;
                              String newTelefono = _telefonoController.text;
                              String addressD = _addressController.text;
                              String ciudad = _cityController.text;
                              String codigoPostal = _codePostalController.text;

                              //Selected Id 
                              int selectGroupId = _selectedGroupIndex;
                              int selectTaxId = _selectedTaxIndexType;
                              int selectCountry = _selectedCountryIndex;
                              int selectTaxPayerId = _selectedTaxPayerIndex;
                              int selectTypePerson= _selectedPersonTypeIndex;
                              //Strings
                              String groupText = _groupTextVendor;
                              String typeTaxText = _taxTypeText;
                              String countryText = _countryTex;
                              String taxPayerText = _taxPayerText;
                              String typePersonText = _personTypeText;

                              // Crear un mapa con los datos actualizados del producto
                              Map<String, dynamic> updatedprovider = {
                                'id': widget.provider['id'], // Asegúrate de incluir el ID del producto
                                'c_bpartner_id': widget.provider['c_bpartner_id'],
                                'c_code_id': widget.provider['c_code_id'],
                                'bpname': newName,
                                'email': newCorreo,
                                'c_bp_group_id': selectGroupId,
                                'groupbpname': groupText,
                                'tax_id': newRuc,
                                'is_vendor': widget.provider['is_vendor'],
                                'lco_tax_id_type_id': selectTaxId,
                                'tax_id_type_name': typeTaxText,
                                'c_bpartner_location_id': widget.provider['c_bpartner_location_id'],
                                'is_bill_to' : widget.provider['is_bill_to'],
                                'phone': newTelefono,
                                'c_location_id': widget.provider['c_location_id'],
                                'address': addressD,
                                'city': ciudad,
                                'country_name': countryText,
                                'postal': codigoPostal,
                                'c_city_id' : widget.provider['c_city_id'],
                                'c_country_id': selectCountry,
                                'lco_taxt_payer_type_id': selectTaxPayerId,
                                'tax_payer_type_name': taxPayerText,
                                'lve_person_type_id': selectTypePerson,
                                'person_type_name': typePersonText,
                              };

                              // Actualizar el producto en la base de datos
                              await updateProvider(updatedprovider);
                              
                   
                              showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 20),
                                  backgroundColor: Colors.white,
                                  // Center the title, content, and actions using a Column
                                  content: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize
                                        .min, // Wrap content vertically
                                    children: [
                                      Image.asset('lib/assets/Check@2x.png',
                                          width: 50,
                                          height:
                                              50), // Adjust width and height
                                      const Text('Proveedor Editado correctamente',
                                          style: TextStyle(
                                              fontFamily: 'Poppins Bold')),
                                      TextButton(
                                        onPressed: () => {
                                          Navigator.pop(context),
                                          Navigator.pop(context)

                                        },
                                        child: const Text('Volver'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );


                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff7531FF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Text('Actualizar', style: TextStyle(fontFamily: 'Poppins SemiBold', fontSize: 15),),
                        ),
                      ),
                    ),
              
                  ],
              
                ),
              ),
            ),
          ),
        ),
        
      ),
    );
  }

  Widget _buildTextFormField(String label, TextEditingController controller, int lines, double mediaScreen) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: mediaScreen,
        height: lines == 2 ?  mediaScreen * 0.35 : mediaScreen * 0.20,
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
        
          controller: controller,
          decoration: InputDecoration(
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
                            labelText: label,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
          ),
          maxLines: lines,
          validator: (value) {

              if(value!.isEmpty && label != "Direccion"){

                  return "El campo de $label no puede estar vacio";

              }

          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    _nameController.dispose();
    _rucController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }
}
