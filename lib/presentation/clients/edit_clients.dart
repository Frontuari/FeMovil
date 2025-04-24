import 'package:femovil/config/app_bar_sampler.dart';
import 'package:femovil/database/list_database.dart';
import 'package:femovil/database/update_database.dart';
import 'package:femovil/presentation/clients/idempiere/update_customer.dart';
import 'package:femovil/presentation/clients/select_customer.dart';
import 'package:femovil/utils/alerts_messages.dart';
import 'package:flutter/material.dart';

class EditClientScreen extends StatefulWidget {
  final Map<String, dynamic> client;

  const EditClientScreen({super.key, required this.client});

  @override
  _EditClientScreenState createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  final _nameController = TextEditingController();
  final _rucController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _provinceController = TextEditingController();
  final _cityController = TextEditingController();
  final _codePostalController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  BuildContext? currentContext;
  //List
  List<Map<String, dynamic>> _countryList     = [];
  List<Map<String, dynamic>> _groupList       = [];
  List<Map<String, dynamic>> _idTypeList      = [];
  List<Map<String, dynamic>> _taxPayerList    = [];
  List<Map<String, dynamic>> _typePersonList  = [];
  List<Map<String, dynamic>> _provinceList    = [];
  List<Map<String, dynamic>> _cityList        = [];

  // SELECTED
  int _selectedCountryIndex   = 0;
  int _selectedGroupIndex     = 0;
  int _selectedIdType         = 0;
  int _selectedTaxPayer       = 0;
  int _seletectedTypePerson   = 0;
  int _selectedProvinceIndex  = 0;
  int _selectedCityIndex      = 0;
// Text

  String _countryText     = '';
  String _groupText       = '';
  String _idTypeText      = '';
  String _taxPayerText    = '';
  String _typePersonText  = '';
  String _provinceText    = '';
  String _cityText        = '';
  int? _idMaxlength;
  

  loadList() async {
    List<Map<String, dynamic>> getCountryGroup = await listarCountries();
    List<Map<String, dynamic>> getGroupTercero = await listarGroupTercero();
    List<Map<String, dynamic>> getTaxType = await listarTaxType();
    List<Map<String, dynamic>> getTaxPayer = await listarTaxPayer();
    
    // List<Map<String, dynamic>> getTypePerson = await listarTypePerson();
    print('Esta es la respuesta $getCountryGroup');
    print('Esta es la respuesta de getGroupTercero $getGroupTercero');
    print('Esto es getTaxType $getTaxType');
    print('Estos son los taxPayers $getTaxPayer');

  
    // print('Estos son los type person $getTypePerson');

    _groupList.add({
      'c_bp_group_id': 0, 
      'group_bp_name': 'Selecciona un Grupo'
    });
    _idTypeList.add({
      'lco_tax_id_type_id': 0,
      'tax_id_type_name'  : 'Selecciona un tipo de identificación'
    });
    _taxPayerList.add({
      'lco_tax_payer_type_id': 0,
      'tax_payer_type_name'  : 'Selecciona un tipo de contribuyente'
    });
    _countryList.add({
      'c_country_id': 0, 
      'country'     : 'Selecciona un País'
    });
    _provinceList.add({
      'c_region_id': 0,
      'region'     : 'Selecciona una provincia'
    });
    _cityList.add({
      'c_city_id': 0,
      'city'     : 'Selecciona una ciudad'
    });
    // _typePersonList.add({
    //   'lve_person_type_id': 0,
    //   'person_type_name': 'Selecciona un tipo de Persona'
    // });

    

    setState(() {
      _countryList.addAll(getCountryGroup);
      _groupList.addAll(getGroupTercero);
      _idTypeList.addAll(getTaxType);
      _taxPayerList.addAll(getTaxPayer);
      // _typePersonList.addAll(getTypePerson);
    });

    if (widget.client['c_country_id'] != 0) {
   
      _selectedCountryIndex = widget.client['c_country_id'].toString() != '{@nil=true}' ? widget.client['c_country_id'] : 0;
      List<Map<String, dynamic>> provinceListByCountry  = await listarRegions(widget.client['c_country_id']);
      List<Map<String, dynamic>> cityListByProvince     = await listarCities(widget.client['c_region_id']);

      print('provinces by country: $provinceListByCountry');

      setState(() {
        _provinceList.addAll(provinceListByCountry);
        _selectedProvinceIndex  = widget.client['c_region_id'].toString() != '{@nil=true}' && widget.client['c_region_id'].toString() != 'null' 
          ? widget.client['c_region_id'] 
          : 0;
        _cityList.addAll(cityListByProvince);        
        _selectedCityIndex      = widget.client['c_city_id'].toString() != '{@nil=true}' && widget.client['c_city_id'].toString() != 'null' 
          ? widget.client['c_city_id'] 
          : 0;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing product details    
    loadList();
    
    // _seletectedTypePerson = widget.client['lve_person_type_id'];
    // _typePersonText = widget.client['person_type_name'].toString();
    _selectedTaxPayer = widget.client['lco_tax_payer_typeid'] != '{@nil=true}' ?  widget.client['lco_tax_payer_typeid']:0;
    _taxPayerText = widget.client['tax_payer_type_name'].toString() != '{@nil=true}' ? widget.client['tax_payer_type_name'].toString() : '';
    _selectedGroupIndex = widget.client['c_bp_group_id'];
    _groupText = widget.client['group_bp_name'].toString();
    _selectedIdType = widget.client['lco_tax_id_typeid'];
    _idTypeText = widget.client['tax_id_type_name'].toString();
    _nameController.text = widget.client['bp_name'].toString();
    _rucController.text = widget.client['ruc'].toString();
    _correoController.text = widget.client['email'].toString() == '{@nil: true}' ? '' : widget.client['email'].toString();
    _telefonoController.text = widget.client['phone'].toString() == '{@nil: true}' ? '' : widget.client['phone'].toString();
    _direccionController.text = widget.client['address'].toString() == '{@nil: true}' ? '' : widget.client['address'].toString();
    _provinceController.text = widget.client['region'].toString() == '{@nil: true}' ? '' : widget.client['region'].toString();
    _cityController.text = widget.client['city'].toString() == '{@nil: true}' ? '' : widget.client['city'].toString();
    _codePostalController.text = widget.client['code_postal'].toString() == '{@nil=true}' ? '' : widget.client['code_postal'].toString();
  }

  @override
  Widget build(BuildContext context) {
    final mediaScreen = MediaQuery.of(context).size.width *0.8;
  
    setState(() {
      
     currentContext = context;
    });
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBarSample(label: 'Editar Cliente'))  ,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Align(
              alignment: Alignment.center ,
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: SizedBox(
                  width: mediaScreen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 05),
                      SizedBox(
                        width: mediaScreen * 0.95,
                        child: const Text("Datos del Cliente", textAlign: TextAlign.start, style: TextStyle(
                          color: Colors.black, fontFamily: 'Poppins Bold', fontSize: 18
                        )),
                      ),
                      const SizedBox(height: 12),
                      
                      // TIPO DE IDENTIFICACION
                      CustomDropdownButtonFormField(
                        identifier: 'idType',
                        selectedIndex: _selectedIdType,
                        dataList: _idTypeList,
                        text: _idTypeText,
                        onSelected: (newValue, idTypeText) {
                          setState(() {
                            _selectedIdType = newValue ?? 0;
                            _idTypeText = (newValue != 0) ? idTypeText : "";

                            if (idTypeText == 'C CEDULA' || idTypeText == 'P PASAPORTE') {
                              _idMaxlength = 10;
                            } else if (idTypeText == 'R RUC PERSONAL') {
                              _idMaxlength = 12;
                            }
                          });
                        },
                        readOnly: true
                      ),
                      const SizedBox(height: 12),

                      _buildTextFormField('Identificador', _rucController, 1, mediaScreen, _idMaxlength, true),
                      _buildTextFormField('Razón Social o Nombre Completo', _nameController,1, mediaScreen),                      
                      _buildTextFormField('Correo', _correoController, 1, mediaScreen),
                      _buildTextFormField('Telefono', _telefonoController, 1, mediaScreen),
                      const SizedBox(height: 10,),

                      // GRUPO
                      CustomDropdownButtonFormField(
                        identifier: 'groupBp',
                        selectedIndex: _selectedGroupIndex,
                        dataList: _groupList,
                        text: _groupText,
                        onSelected: (newValue, groupText) {
                          setState(() {
                            _selectedGroupIndex = newValue ?? 0;
                            _groupText = (newValue != 0) ? groupText : "";
                          });
                        },
                      ),
                      const SizedBox(height: 15),                      

                      // TIPO DE CONTRIBUYENTE
                      CustomDropdownButtonFormField(
                        identifier: 'taxPayer',
                        selectedIndex: _selectedTaxPayer,
                        dataList: _taxPayerList,
                        text: _taxPayerText,
                        onSelected: (newValue, taxPayerText) {
                          setState(() {
                            _selectedTaxPayer = newValue ?? 0;
                            _taxPayerText = (newValue != 0) ? taxPayerText : "";
                          });
                        },
                      ),
                      const SizedBox(height: 25),
                      // CustomDropdownButtonFormField(
                      //   identifier: 'typePerson',
                      //   selectedIndex: _seletectedTypePerson,
                      //   dataList: _typePersonList,
                      //   text: _typePersonText,
                      //   onSelected: (newValue, tyPersonText) {
                      //     setState(() {
                      //       _seletectedTypePerson = newValue ?? 0;
                      //       _typePersonText = tyPersonText;
                      //     });
                      //   },
                      // ),
                      SizedBox(
                        width: mediaScreen * 0.95,
                        child: const Text("Domicilio Fiscal", textAlign: TextAlign.start, style: TextStyle(color: Colors.black, fontFamily: 'Poppins Bold', fontSize: 18)),
                      ),
                      const SizedBox(height: 10),

                      // PAIS
                      CustomDropdownButtonFormField(
                        identifier: 'selectCountry', 
                        selectedIndex: _selectedCountryIndex, 
                        dataList: _countryList, 
                        text: _countryText, 
                        onSelected: (newValue, newText) async {
                          var countryIndex = newValue ?? 0;
                          var countryName  = (newValue != 0) ? newText : ""; 

                          List<Map<String, dynamic>> newProvinceList = [];
                          newProvinceList.add({
                            'c_region_id': 0,
                            'region'     : 'Selecciona una provincia'
                          });
                          List<Map<String, dynamic>> newCityList = [];
                          newCityList.add({
                            'c_city_id': 0,
                            'city'     : 'Selecciona una ciudad'
                          });
                          if (countryName != "") {
                            dynamic provinceListByCountry = await listarRegions(countryIndex);

                            newProvinceList.addAll(provinceListByCountry);
                          }

                          print('provinces by country: $newProvinceList');

                          setState(() {
                            _selectedCountryIndex   = countryIndex;
                            _countryText            = countryName;
                            _provinceList           = newProvinceList;
                            _selectedProvinceIndex  = 0;
                            _cityList               = newCityList;
                            _selectedCityIndex      = 0;
                          });
                        }
                      ),
                      const SizedBox(height: 15),

                      // PROVINCIA
                      CustomDropdownButtonFormField(
                        identifier: 'selectProvince', 
                        selectedIndex: _selectedProvinceIndex, 
                        dataList: _provinceList, 
                        text: _provinceText, 
                        onSelected: (newValue, newText) async {
                          var provinceIndex = newValue ?? 0;
                          var provinceName  = (newValue != 0) ? newText : ""; 

                          List<Map<String, dynamic>> newCitiesList = [];
                          newCitiesList.add({
                            'c_city_id': 0,
                            'city'     : 'Selecciona una ciudad'
                          });
                          if (provinceName != "") {
                            dynamic citiesListByRegion = await listarCities(provinceIndex);

                            newCitiesList.addAll(citiesListByRegion);
                          }

                          print('cities by province: $newCitiesList');

                          setState(() {
                            _selectedProvinceIndex  = provinceIndex;
                            _provinceText           = provinceName;
                            _cityList               = newCitiesList;
                            _selectedCityIndex      = 0;
                          });
                        }
                      ),
                      const SizedBox(height: 15),

                      // CIUDAD
                      CustomDropdownButtonFormField(
                        identifier: 'selectCity', 
                        selectedIndex: _selectedCityIndex, 
                        dataList: _cityList, 
                        text: _cityText, 
                        onSelected: (newValue, newText) {
                          setState(() {
                            _selectedCityIndex  = newValue ?? 0;
                            _cityText           = (newValue != 0) ? newText : "";
                          });
                        }
                      ),
                      const SizedBox(height: 10),

                      // _buildTextFormField('Provincia', _provinceController, 1, mediaScreen),
                      // _buildTextFormField('Ciudad', _cityController, 1, mediaScreen),
                      _buildTextFormField('Dirección', _direccionController, 2, mediaScreen),                      
                      _buildTextFormField('Codigo Postal', _codePostalController, 1, mediaScreen),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 7,
                                  spreadRadius: 2)
                            ]),
                          width: mediaScreen * 0.95,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              String newName          = _nameController.text;
                              dynamic newRuc          = _rucController.text;
                              String newCorreo        = _correoController.text;
                              dynamic newTelefono     = _telefonoController.text;
                              String newGrupo         = _groupText;
                              String taxType          = _idTypeText;
                              String taxPayer         = _taxPayerText;
                              String personType       = _typePersonText;
                              String newDireccion     = _direccionController.text;
                              String newCity          = _cityController.text;
                              String newCode          = _codePostalController.text;
                              String newCountry       = _countryText;
                              String newProvince      = _provinceController.text; 

                              int selectedGroupId     = _selectedGroupIndex;
                              int selectedTaxId       = _selectedIdType;
                              int selectedTaxPayerId  = _selectedTaxPayer;
                              int selectedPersonType  = _seletectedTypePerson;
                              int selectedCountryId   = _selectedCountryIndex;
                              int selectedProvinceId  = _selectedProvinceIndex;
                              int selectedCityId      = _selectedCityIndex;
                              
                                    
                              // Crear un mapa con los datos actualizados del producto
                              Map<String, dynamic> updatedClient = {
                                'id': widget.client['id'], // Asegúrate de incluir el ID del producto

                                'c_bpartner_id': widget.client['c_bpartner_id'],
                                'bp_name': newName,
                                'ruc': newRuc,
                                'email': newCorreo,
                                'phone': newTelefono,
                                'c_bp_group_id': selectedGroupId,
                                'group_bp_name': newGrupo,
                                'lco_tax_id_typeid': selectedTaxId,
                                'tax_id_type_name': taxType,
                                'lco_tax_payer_typeid': selectedTaxPayerId,
                                'tax_payer_type_name': taxPayer,
                                'lve_person_type_id': selectedPersonType,
                                'person_type_name': personType,
                                'address': newDireccion,
                                'code_postal': newCode,
                                'c_country_id': selectedCountryId,
                                'c_region_id': selectedProvinceId,
                                'c_city_id': selectedCityId,
                                
                              };
                                print('Data que trae el client $updatedClient');

                              print('id updateClient $updatedClient');

                              // Actualizar el producto en la base de datos

                              showLoadingDialog(context, message: 'Guardando');
                              await updateClient(updatedClient);

                              await updateCustomerIdempiere(updatedClient);
                              Navigator.pop(context);


                              showDialog(
                                context: currentContext!,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                    backgroundColor: Colors.white,
                                    // Center the title, content, and actions using a Column
                                    content: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min, // Wrap content vertically
                                      children: [
                                        Image.asset('lib/assets/Check@2x.png', width: 50, height: 50), // Adjust width and height
                                        const Text('Cliente actualizado', style: TextStyle(fontFamily: 'Poppins Bold')),
                                        TextButton(
                                          onPressed: () => {
                                            Navigator.pop(context),
                                            Navigator.pop(context),
                                            Navigator.pop(context)
                                          },
                                          child: const Text('Volver'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(int.parse('0xFF7531FF')),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                          ),
                          child: const Text(
                            'Actualizar',
                            style: TextStyle(fontFamily: 'Poppins SemiBold', fontSize: 15),
                          ),
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
      ),
    );
  }

  Widget _buildTextFormField(String label, TextEditingController controller, int maxLin, double screenMedia, [int? maxLength, bool readOnly = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        height: maxLin == 2 ? screenMedia * 0.35 : screenMedia * 0.20,
        width: screenMedia * 0.95,
        decoration:BoxDecoration(
              color: readOnly ? Colors.grey.shade300 : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [                
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5) ,
                  blurRadius: 7,
                  spreadRadius: 2
                )
              ]
        ) ,
        child: TextFormField(
          controller: controller,
          maxLength: maxLength,
          readOnly: readOnly,
          decoration: InputDecoration(            
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15.0)), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0)), 
              borderSide: BorderSide(color: readOnly ? Colors.grey.shade300 : Colors.white, width: 25)
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0)), 
              borderSide: BorderSide(color: readOnly ? Colors.grey.shade300 : Colors.white, width: 25)
            ),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(width: 1, color: Colors.red)),
            labelText: label,
            errorStyle: const TextStyle(fontFamily: 'Poppins Regular'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
            filled: readOnly,
            fillColor: readOnly ? Colors.grey.shade300 : Colors.white,
          ),
          maxLines: maxLin,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El campo $label no puede ir vacio';
            }
            
            if(label =='Correo' && !value.contains('@')){
              return 'Debe introducir un correo valido';
            }
            
            return null;
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
