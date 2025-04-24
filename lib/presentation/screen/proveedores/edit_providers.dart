import 'package:femovil/config/app_bar_sampler.dart';
import 'package:femovil/database/create_database.dart';
import 'package:femovil/database/gets_database.dart';
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

  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _codePostalController = TextEditingController();

  // List
  final List<Map<String, dynamic>> _groupVendorList     = [];
  final List<Map<String, dynamic>> _idTypeVendorList    = [];
  final List<Map<String, dynamic>> _countryVendorList   = [];
  final List<Map<String, dynamic>> _taxPayerList        = [];
  final List<Map<String, dynamic>> _typePersonList      = [];
  final List<Map<String, dynamic>> _ciiuActivitiesList  = [];
  List<Map<String, dynamic>> _provinceList              = [];
  List<Map<String, dynamic>> _cityList                  = [];

  //SELECTED
  int _selectedGroupIndex       = 0;
  int _selectedIdTypeIndex      = 0;
  int _selectedCountryIndex     = 0;
  int _selectedTaxPayerIndex    = 0;
  int _selectedPersonTypeIndex  = 0;
  int _selectedCiiuCode         = 0;
  int _selectedProvinceIndex    = 0;
  int _selectedCityIndex        = 0;

  //Text o String

  String _groupTextVendor     = '';
  String _idTypeText          = '';
  String _countryTex          = '';
  String _taxPayerText        = '';
  String _personTypeText      = '';
  String _ciiuActivitiesText  = '';
  String _provinceText        = '';
  String _cityText            = '';
  int? _idMaxlength;

  loadList() async {  
    List<Map<String, dynamic>> getGroupVendor = await listarTypeGroupVendor();
    List<Map<String, dynamic>> getIdTypeVendor = await listarTaxType();
    List<Map<String, dynamic>> getCountryVendor = await listarCountries();
    List<Map<String, dynamic>> getTaxPayerVendor = await listarTaxPayer();
    List<Map<String, dynamic>> getTypePerson = await listarPersonTypeVendors();
    List<Map<String, dynamic>> getCiiuActivitesCodes = await getCiiuActivities();

    print('Value de getGroupVendor $getGroupVendor ');
    print('Value de getIdTypeVendor $getIdTypeVendor');

    _groupVendorList.add({
      'c_bp_group_id': 0, 
      'groupbpname': 'Selecciona un Grupo'
    });
    _idTypeVendorList.add({
      'lco_tax_id_type_id': 0,
      'tax_id_type_name': 'Selecciona un tipo de identificación'
    });
    _taxPayerList.add({
      'lco_tax_payer_type_id': 0,
      'tax_payer_type_name'  : 'Selecciona un tipo de contribuyente'
    });
    _typePersonList.add({
      'lve_person_type_id': 0,
      'person_type_name': 'Selecciona un tipo de persona'
    });
    _ciiuActivitiesList.add({
      'lco_isic_id': 0, 
      'name': 'Selecciona un CIIU'
    });
    _countryVendorList.add({
      'c_country_id': 0, 
      'country'     : 'Selecciona un país'
    });
    _provinceList.add({
      'c_region_id': 0, 
      'region'     : 'Selecciona una provincia'
    });
    _cityList.add({
      'c_city_id': 0, 
      'city'     : 'Selecciona una ciudad'
    });

    setState(() {
      _groupVendorList.addAll(getGroupVendor);
      _idTypeVendorList.addAll(getIdTypeVendor);
      _countryVendorList.addAll(getCountryVendor);
      _taxPayerList.addAll(getTaxPayerVendor);
      _typePersonList.addAll(getTypePerson);
      _ciiuActivitiesList.addAll(getCiiuActivitesCodes);
    });
    
    if (getCountryVendor.isNotEmpty && widget.provider['c_country_id'] != 0) {
      List<Map<String, dynamic>> provinceListByCountry = await listarRegions(widget.provider['c_country_id']);
      List<Map<String, dynamic>> cityListByProvince = await listarCities(widget.provider['c_region_id']);

      setState(() {
        _provinceList.addAll(provinceListByCountry);
        _selectedProvinceIndex  = widget.provider['c_region_id'].toString() != '{@nil=true}' && widget.provider['c_region_id'].toString() != 'null' 
          ? widget.provider['c_region_id'] 
          : '';
        _cityList.addAll(cityListByProvince);
        _selectedCityIndex      = widget.provider['c_city_id'].toString() != '{@nil=true}' && widget.provider['c_city_id'].toString() != 'null'
          ? widget.provider['c_city_id'] 
          : '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadList();
    print(
        'Esto es el provider tax payer ${widget.provider['lco_taxt_payer_type_id']}');
    print('Esto es el country de provider ${widget.provider['c_country_id']}');
    // Initialize controllers with existing product details
    _nameController.text        = widget.provider['bpname'].toString();
    _rucController.text         = widget.provider['tax_id'].toString();
    _correoController.text      = widget.provider['email'].toString() != '{@nil=true}' ? widget.provider['email'].toString() : '';
    _telefonoController.text    = widget.provider['phone'].toString() != '{@nil=true}' ? widget.provider['phone'].toString() : '';
    _groupTextVendor            = widget.provider['groupbpname'].toString();
    _taxPayerText               = widget.provider['tax_payer_type_name'].toString();
    _idTypeText                 = widget.provider['tax_id_type_name'].toString();
    // _personTypeText = widget.provider['person_type_name'].toString();
    _countryTex                 = widget.provider['country_name'].toString();
    _selectedGroupIndex         = widget.provider['c_bp_group_id'];
    _selectedIdTypeIndex        = widget.provider['lco_tax_id_type_id'] != '{@nil=true}' ? widget.provider['lco_tax_id_type_id'] : 0;
    _selectedTaxPayerIndex      = widget.provider['lco_taxt_payer_type_id'] != '{@nil=true}' ? widget.provider['lco_taxt_payer_type_id'] : 0;
    // _selectedPersonTypeIndex = widget.provider['lve_person_type_id'];
    _selectedCountryIndex       = widget.provider['c_country_id'].toString() != 'null' ? widget.provider['c_country_id'] : 0;
    // _provinceController.text    = widget.provider['province'].toString() != '{@nil=true}' ? widget.provider['province'].toString() : '';
    // _cityController.text = widget.provider['city'].toString() != '{@nil=true}' ? widget.provider['city'] : '';
    _addressController.text     = widget.provider['address'].toString() != '{@nil=true}' ? widget.provider['address'].toString() : '';
    _codePostalController.text  = widget.provider['postal'].toString() != '{@nil=true}' ? widget.provider['postal'].toString() : '';
    _ciiuActivitiesText         = widget.provider['ciiu_tagname'].toString();
    _selectedCiiuCode           = widget.provider['ciiu_id'] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final mediaScreen = MediaQuery.of(context).size.width * 0.8;
    final mediaHeight = MediaQuery.of(context).size.height * 1;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: const PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: AppBarSample(label: 'Editar Proveedor')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 5),
                    ContainerBlue(label: 'Detalles', mediaScreen: mediaScreen),
                    const SizedBox(height: 10),

                    // TIPO DE IDENTIFICACION
                    CustomDropdownButtonFormFieldVendor(
                      identifier: 'idTypeVendor',
                      selectedIndex: _selectedIdTypeIndex,
                      dataList: _idTypeVendorList,
                      text: _idTypeText,
                      onSelected: (newValue, idTypeText) {
                        setState(() {
                          _selectedIdTypeIndex = newValue ?? 0;
                          _idTypeText = (newValue != 0) ? idTypeText : "";

                          if (idTypeText == 'C CEDULA' || idTypeText == 'P PASAPORTE') {
                            _idMaxlength = 10;
                          } else if (idTypeText == 'R RUC PERSONAL' || idTypeText == 'R RUC JURIDICO') {
                            _idMaxlength = 12;
                          }
                        });
                      },
                      readOnly: true,
                    ),
                    SizedBox(height: mediaHeight * 0.020),

                    _buildTextFormField('Identificador', _rucController, 1, mediaScreen, _idMaxlength, true),
                    _buildTextFormField('Razón Social o Nombre Completo', _nameController, 1, mediaScreen),
                    _buildTextFormField('Correo', _correoController, 1, mediaScreen),
                    _buildTextFormField('Telefono', _telefonoController, 1, mediaScreen),
                    SizedBox(height: mediaHeight * 0.010),

                    // GRUPO
                    CustomDropdownButtonFormFieldVendor(
                      identifier: 'groupTypeVendor',
                      selectedIndex: _selectedGroupIndex,
                      dataList: _groupVendorList,
                      text: _groupTextVendor,
                      onSelected: (newValue, groupText) {
                        setState(() {
                          _selectedGroupIndex = newValue ?? 0;
                          _groupTextVendor = (newValue != 0) ? groupText : "";
                        });
                      },
                    ),
                    SizedBox(height: mediaHeight * 0.020),   

                    // CIIU
                    CustomDropdownButtonFormFieldVendor(
                      identifier: 'ciiuTypeActivities',
                      selectedIndex: _selectedCiiuCode,
                      dataList: _ciiuActivitiesList,
                      text: _ciiuActivitiesText,
                      onSelected: (newValue, ciiuText) {
                        setState(() {
                          _selectedCiiuCode = newValue ?? 0;
                          _ciiuActivitiesText = (newValue != 0) ? ciiuText : "";
                        });
                      },
                    ),
                    SizedBox(height: mediaHeight * 0.020),                  

                    // TIPO DE CONTRIBUYENTE
                    CustomDropdownButtonFormFieldVendor(
                      identifier: 'taxPayerVendor',
                      selectedIndex: _selectedTaxPayerIndex,
                      dataList: _taxPayerList,
                      text: _taxPayerText,
                      onSelected: (newValue, taxPayerText) {
                        setState(() {
                          _selectedTaxPayerIndex = newValue ?? 0;
                          _taxPayerText = (newValue != 0) ? taxPayerText : "";
                        });
                      },
                    ),
                    SizedBox(height: mediaHeight * 0.02),

                    //  const SizedBox(height: 10,),
                    // CustomDropdownButtonFormFieldVendor(identifier: 'typePersonVendor', selectedIndex: _selectedPersonTypeIndex, dataList:_typePersonList, text: _personTypeText, onSelected: (newValue, personTypeText) {

                    //     setState(() {

                    //         _selectedPersonTypeIndex = newValue ?? 0;
                    //         _personTypeText = personTypeText;

                    //     });

                    // },),
                    
                    ContainerBlue(
                      label: 'Domicilio Fiscal',
                      mediaScreen: mediaScreen,
                    ),
                    const SizedBox(height: 10),

                    // PAIS
                    CustomDropdownButtonFormFieldVendor(
                      identifier: 'countryVendor',
                      selectedIndex: _selectedCountryIndex,
                      dataList: _countryVendorList,
                      text: _countryTex,
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
                          _countryTex             = countryName;
                          _provinceList           = newProvinceList;                          
                          _selectedProvinceIndex  = 0;
                          _cityList               = newCityList;                          
                          _selectedCityIndex      = 0;
                        });
                      },
                    ),
                    SizedBox(height: mediaHeight * 0.02),

                    // PROVINCIA
                    CustomDropdownButtonFormFieldVendor(
                        identifier: 'provinceVendor',
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
                        },
                      ),
                    SizedBox(height: mediaHeight * 0.02),

                    // CIUDAD
                    CustomDropdownButtonFormFieldVendor(
                        identifier: 'cityVendor',
                        selectedIndex: _selectedCityIndex,
                        dataList: _cityList,
                        text: _cityText,
                        onSelected: (newValue, newText) {
                          setState(() {
                            _selectedCityIndex  = newValue ?? 0;
                            _cityText           = newText;
                          });
                        },
                    ),
                    SizedBox(height: mediaHeight * 0.01),

                    // _buildTextFormField('Provincia', _provinceController, 1, mediaScreen),
                    // _buildTextFormField('Ciudad', _cityController, 1, mediaScreen),
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
                                  spreadRadius: 2)
                            ]),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // Guarda el producto en la base de datos Sqflite

                              String newName = _nameController.text;
                              String newRuc = _rucController.text;
                              String newCorreo = _correoController.text;
                              String newTelefono = _telefonoController.text;
                              String addressD = _addressController.text;
                              String provincia = _provinceController.text;
                              String ciudad = _cityController.text;
                              String codigoPostal = _codePostalController.text;

                              //Selected Id
                              int selectGroupId = _selectedGroupIndex;
                              int selectTaxId = _selectedIdTypeIndex;
                              int selectCountry = _selectedCountryIndex;
                              int selectProvince = _selectedProvinceIndex;
                              int selectCity = _selectedCityIndex;
                              int selectTaxPayerId = _selectedTaxPayerIndex;
                              int selectTypePerson = _selectedPersonTypeIndex;
                              int selectCiiuId = _selectedCiiuCode;
                              //Strings
                              String groupText = _groupTextVendor;
                              String typeTaxText = _idTypeText;
                              String countryText = _countryTex;
                              String taxPayerText = _taxPayerText;
                              String typePersonText = _personTypeText;
                              String ciiuText = _ciiuActivitiesText;

                              // Crear un mapa con los datos actualizados del producto
                              Map<String, dynamic> updatedprovider = {
                                'id': widget.provider[
                                    'id'], // Asegúrate de incluir el ID del producto
                                'c_bpartner_id':
                                    widget.provider['c_bpartner_id'],
                                'c_code_id': widget.provider['c_code_id'],
                                'bpname': newName,
                                'email': newCorreo,
                                'c_bp_group_id': selectGroupId,
                                'groupbpname': groupText,
                                'tax_id': newRuc,
                                'is_vendor': widget.provider['is_vendor'],
                                'lco_tax_id_type_id': selectTaxId,
                                'tax_id_type_name': typeTaxText,
                                'c_bpartner_location_id':
                                    widget.provider['c_bpartner_location_id'],
                                'is_bill_to': widget.provider['is_bill_to'],
                                'phone': newTelefono,
                                'c_location_id':
                                    widget.provider['c_location_id'],
                                'address': addressD,                                
                                'city': ciudad,
                                'country_name': countryText,
                                'postal': codigoPostal,
                                'c_country_id': selectCountry,
                                'c_region_id': selectProvince,
                                'c_city_id': selectCity,
                                'lco_taxt_payer_type_id': selectTaxPayerId,
                                'tax_payer_type_name': taxPayerText,
                                'lve_person_type_id': selectTypePerson,
                                'person_type_name': typePersonText,
                                'province': provincia,
                                'ciiu_id': selectCiiuId,
                                'ciiu_tagname': ciiuText,
                              };

                              // Actualizar el producto en la base de datos
                              await updateProvider(updatedprovider);

                              showDialog(
                                context: context,
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
                                        const Text('Proveedor editado correctamente', style: TextStyle(fontFamily: 'Poppins Bold')),
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
                          child: const Text(
                            'Actualizar',
                            style: TextStyle(
                                fontFamily: 'Poppins SemiBold', fontSize: 15),
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
    );
  }

  Widget _buildTextFormField(String label, TextEditingController controller, int lines, double mediaScreen, [int? maxLength, bool readOnly = false]) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: mediaScreen,
        height: lines == 2 ? mediaScreen * 0.35 : mediaScreen * 0.20,
        decoration: BoxDecoration(
            color: readOnly ? Colors.grey.shade300 : Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 7,
                  spreadRadius: 2)
            ]),
        child: TextFormField(
          controller: controller,
          maxLength: maxLength,
          readOnly: readOnly,
          decoration: InputDecoration(
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15.0)), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              borderSide: BorderSide(color: readOnly ? Colors.grey.shade300 : Colors.white, width: 25), // Color del borde cuando está enfocado
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              borderSide: BorderSide(color: readOnly ? Colors.grey.shade300 : Colors.white, width: 25), // Color del borde cuando no está enfocado
            ),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(width: 1, color: Colors.red)),
            labelText: label,
            contentPadding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
            filled: readOnly,
            fillColor: readOnly ? Colors.grey.shade300 : Colors.white,
          ),
          maxLines: lines,
          validator: (value) {
            if (value!.isEmpty && label != "Direccion") {
              return "El campo de $label no puede estar vacio";
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
