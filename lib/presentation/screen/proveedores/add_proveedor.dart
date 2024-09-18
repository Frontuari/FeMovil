import 'package:femovil/config/app_bar_sampler.dart';
import 'package:femovil/database/create_database.dart';
import 'package:femovil/database/gets_database.dart';
import 'package:femovil/database/list_database.dart';
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
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _codePostalController = TextEditingController();
  final TextEditingController _provinceContoller = TextEditingController();
  // List
  final List<Map<String, dynamic>> _groupVendorList = [];
  final List<Map<String, dynamic>> _taxTypeVendorList = [];
  final List<Map<String, dynamic>> _countryVendorList = [];
  final List<Map<String, dynamic>> _taxPayerList = [];
  final List<Map<String, dynamic>> _typePersonList = [];
  final List<Map<String, dynamic>> _ciiuActivitiesList =[];

  //SELECTED
  int _selectedGroupIndex = 0;
  int _selectedTaxIndexType = 0;
  int _selectedCountryIndex = 0;
  int _selectedTaxPayerIndex = 0;
  int _selectedPersonTypeIndex = 0;
  int _selectedCiiuCode = 0;
 
  //Text o String

  String _groupTextVendor = '';
  String _taxTypeText = '';
  String _countryTex = '';
  String _taxPayerText = '';
  String _personTypeText = '';
  String _ciiuActivitiesText = '';

  loadList() async {
    List<Map<String, dynamic>> getGroupVendor = await listarTypeGroupVendor();
    List<Map<String, dynamic>> getTaxTypeVendor = await listarTypeTaxVendor();
    List<Map<String, dynamic>> getCountryVendor = await listarCountryVendor();
    List<Map<String, dynamic>> getTaxPayerVendor =
        await listarTaxPayerVendors();
    List<Map<String, dynamic>> getTypePerson = await listarPersonTypeVendors();
    List<Map<String, dynamic>> getCiiuActivitesCodes = await getCiiuActivities();

    print('Value de ciuu $getCiiuActivitesCodes');

    print('Value de getGroupVendor $getGroupVendor ');
    print('Value de getTaxTypeVendor $getTaxTypeVendor');

    _ciiuActivitiesList.add({'lco_isic_id':0, 'name':'Selecciona un CIIU'});
    _groupVendorList
        .add({'c_bp_group_id': 0, 'groupbpname': 'Selecciona un Grupo'});
    _taxTypeVendorList.add({
      'lco_tax_id_type_id': 0,
      'tax_id_type_name': 'Selecciona un tipo de impuesto'
    });
    _countryVendorList
        .add({'c_country_id': 0, 'country_name': 'Selecciona un Pais'});
    _taxPayerList.add({
      'lco_taxt_payer_type_id': 0,
      'tax_payer_type_name': 'Selecciona un tipo de contribuyente'
    });
    _typePersonList.add({
      'lve_person_type_id': 0,
      'person_type_name': 'Selecciona un tipo de persona'
    });

    setState(() {
      _ciiuActivitiesList.addAll(getCiiuActivitesCodes);
      _groupVendorList.addAll(getGroupVendor);
      _taxTypeVendorList.addAll(getTaxTypeVendor);
      _countryVendorList.addAll(getCountryVendor);
      _taxPayerList.addAll(getTaxPayerVendor);
      _typePersonList.addAll(getTypePerson);
    });
  }

  @override
  void initState() {
    loadList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double mediaScreen = MediaQuery.of(context).size.width * 0.9;
    final double screenHeight = MediaQuery.of(context).size.height * 0.9;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: const PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: AppBarSample(label: 'Agregar Proveedor')),
        body: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: mediaScreen,
            child: SizedBox(
              width: mediaScreen * 0.8,
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKey,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: screenHeight * 0.023),
                      ContainerBlue(
                        label: 'Datos Del Proveedor',
                        mediaScreen: mediaScreen,
                      ),
                      SizedBox(height: screenHeight * 0.023),

                      Container(
                        width: mediaScreen * 0.88,
                        height: mediaScreen * 0.20,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 7,
                                  spreadRadius: 2)
                            ]),
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 20),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide(
                                      width: 25, color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide(
                                      width: 25, color: Colors.white)),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide.none),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.red)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.red)),
                              labelText: 'Nombre del Proveedor',
                              filled: true,
                              fillColor: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa el nombre del Proveedor';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                        ),
                      ),

                      const SizedBox(height: 10),
                      Container(
                        width: mediaScreen * 0.88,
                        height: mediaScreen * 0.20,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 7,
                                  spreadRadius: 2)
                            ]),
                        child: TextFormField(
                          controller: _rucController,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 20),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide(
                                      width: 25, color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide(
                                      width: 25, color: Colors.white)),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide.none),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.red)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.red)),
                              labelText: 'RUC/DNI',
                              filled: true,
                              fillColor: Colors.white),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa un RUC Valido';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: mediaScreen * 0.88,
                        height: mediaScreen * 0.20,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 7,
                                  spreadRadius: 2)
                            ]),
                        child: TextFormField(
                          controller: _correoController,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 20),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide(
                                      width: 25, color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide(
                                      width: 25, color: Colors.white)),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide.none),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.red)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.red)),
                              labelText: 'Correo',
                              filled: true,
                              fillColor: Colors.white),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa un correo';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: mediaScreen * 0.88,
                        height: mediaScreen * 0.20,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 7,
                                  spreadRadius: 2)
                            ]),
                        child: TextFormField(
                          controller: _telefonoController,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 20),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide(
                                      width: 25, color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide(
                                      width: 25, color: Colors.white)),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide.none),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.red)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.red)),
                              labelText: 'Telefono',
                              filled: true,
                              fillColor: Colors.white),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa el telefono del Proveedor';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomDropdownButtonFormFieldVendor(
                        identifier: 'groupTypeVendor',
                        selectedIndex: _selectedGroupIndex,
                        dataList: _groupVendorList,
                        text: _groupTextVendor,
                        onSelected: (newValue, groupText) {
                          setState(() {
                            _selectedGroupIndex = newValue ?? 0;
                            _groupTextVendor = groupText;
                          });
                        },
                      ),
                            const SizedBox(
                        height: 10,
                      ),
                      CustomDropdownButtonFormFieldVendor(
                        identifier: 'ciiuTypeActivities',
                        selectedIndex: _selectedCiiuCode,
                        dataList: _ciiuActivitiesList,
                        text: _ciiuActivitiesText,
                        onSelected: (newValue, ciiuText) {
                          setState(() {
                            _selectedCiiuCode = newValue ?? 0;
                            _ciiuActivitiesText = ciiuText;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomDropdownButtonFormFieldVendor(
                        identifier: 'taxTypeVendor',
                        selectedIndex: _selectedTaxIndexType,
                        dataList: _taxTypeVendorList,
                        text: _taxTypeText,
                        onSelected: (newValue, taxTex) {
                          setState(() {
                            _selectedTaxIndexType = newValue ?? 0;
                            _taxTypeText = taxTex;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomDropdownButtonFormFieldVendor(
                        identifier: 'taxPayerVendor',
                        selectedIndex: _selectedTaxPayerIndex,
                        dataList: _taxPayerList,
                        text: _taxPayerText,
                        onSelected: (newValue, taxPayerText) {
                          setState(() {
                            _selectedTaxPayerIndex = newValue ?? 0;
                            _taxPayerText = taxPayerText;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      // CustomDropdownButtonFormFieldVendor(identifier: 'typePersonVendor', selectedIndex: _selectedPersonTypeIndex, dataList:_typePersonList, text: _personTypeText, onSelected: (newValue, personTypeText) {

                      //     setState(() {

                      //         _selectedPersonTypeIndex = newValue ?? 0;
                      //         _personTypeText = personTypeText;

                      //     });

                      // },),
                      const SizedBox(
                        height: 15,
                      ),
                      ContainerBlue(
                        label: 'Domicilio Fiscal',
                        mediaScreen: mediaScreen,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      CustomDropdownButtonFormFieldVendor(
                        identifier: 'countryVendor',
                        selectedIndex: _selectedCountryIndex,
                        dataList: _countryVendorList,
                        text: _countryTex,
                        onSelected: (newValue, countryText) {
                          setState(() {
                            _selectedCountryIndex = newValue ?? 0;
                            _countryTex = countryText;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: mediaScreen * 0.88,
                        height: mediaScreen * 0.20,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 7,
                                  spreadRadius: 2)
                            ]),
                        child: TextFormField(
                          controller: _provinceContoller,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 20),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide(
                                      width: 25, color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide(
                                      width: 25, color: Colors.white)),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide.none),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.red)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.red)),
                              labelText: 'Provincia',
                              filled: true,
                              fillColor: Colors.white),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingresa una Provincia';
                            }
                            return null;
                          },
                        ),
                      ),

                       const SizedBox(
                        height: 10,
                      ),
                      
                      Container(
                        width: mediaScreen * 0.88,
                        height: mediaScreen * 0.20,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 7,
                                  spreadRadius: 2)
                            ]),
                        child: TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 20),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide(
                                      width: 25, color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide(
                                      width: 25, color: Colors.white)),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide.none),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.red)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.red)),
                              labelText: 'Ciudad',
                              filled: true,
                              fillColor: Colors.white),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingresa la ciudad del proveedor';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: mediaScreen * 0.88,
                        height: mediaScreen * 0.30,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 7,
                                  spreadRadius: 2)
                            ]),
                        child: TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 20),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide(
                                      width: 25, color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide(
                                      width: 25, color: Colors.white)),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide.none),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.red)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.red)),
                              labelText: 'Dirección',
                              filled: true,
                              fillColor: Colors.white),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa una dirección del Proveedor';
                            }
                            return null;
                          },
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: mediaScreen * 0.88,
                        height: mediaScreen * 0.20,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 7,
                                  spreadRadius: 2)
                            ]),
                        child: TextFormField(
                          controller: _codePostalController,
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 20),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide(
                                      width: 25, color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide(
                                      width: 25, color: Colors.white)),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide.none),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.red)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.red)),
                              labelText: 'Codigo Postal',
                              filled: true,
                              fillColor: Colors.white),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa el codigo postal del Proveedor';
                            }
                            return null;
                          },
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Container(
                          width: mediaScreen * 0.88,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 7)
                              ]),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Guarda el producto en la base de datos Sqflite
                                _saveProduct();
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
                              'Crear Proveedor',
                              style: TextStyle(fontFamily: 'Poppins Bold'),
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

  void _saveProduct() async {
    // Obtén los valores del formulario
    String bpName = _nameController.text;
    String taxId = _rucController.text;
    String email = _correoController.text;
    int phone = int.parse(_telefonoController.text);
    String address = _addressController.text;
    String city = _cityController.text;
    String codePostal = _codePostalController.text;
    String province = _provinceContoller.text;
    // ID
    int idGroup = _selectedGroupIndex;
    int taxTypeId = _selectedTaxIndexType;
    int countryId = _selectedCountryIndex;
    int taxPayerVendorId = _selectedTaxPayerIndex;
    int personTypeId = _selectedPersonTypeIndex;
    int ciiuId = _selectedCiiuCode;
    // Strings
    String groupText = _groupTextVendor;
    String taxIdText = _taxTypeText;
    String countryName = _countryTex;
    String taxPayerName = _taxPayerText;
    String personTypeName = _personTypeText;
    String ciiuTagText = _ciiuActivitiesText;
    // Crea una instancia del producto

   bool ifExists = await proveedorExists(taxId);

if (ifExists) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Proveedor ya registrado',
          style: TextStyle(
            fontFamily: 'Poppins SemiBold',
            fontSize: 18,
          ),
        ),
        content: Text(
          'El proveedor con el ID fiscal proporcionado ya está registrado en el sistema.',
          style: TextStyle(
            fontFamily: 'Poppins Regular',
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              'Aceptar',
              style: TextStyle(
                fontFamily: 'Poppins SemiBold',
                fontSize: 16,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );

  return;
}


    Vendor provider = Vendor(
        cBPartnerId: 0,
        cCodeId: 0,
        bPName: bpName,
        email: email,
        cBPGroupId: idGroup,
        groupBPName: groupText,
        taxId: taxId,
        isVendor: 'Y',
        lcoTaxIdTypeId: taxTypeId,
        taxIdTypeName: taxIdText,
        cBPartnerLocationId: 0,
        isBillTo: 'Y',
        phone: phone,
        cLocationId: 0,
        address: address,
        city: city,
        countryName: countryName,
        postal: codePostal,
        cCityId: 0,
        cCountryId: countryId,
        lcoTaxtPayerTypeId: taxPayerVendorId,
        taxPayerTypeName: taxPayerName,
        lvePersonTypeId: personTypeId,
        personTypeName: personTypeName,
        ciiuId: ciiuId,
        ciiuTagName: ciiuTagText,
        province: province
        );

    // Llama a un método para guardar el producto en Sqflite
    await saveProviderToDatabase(provider);

    // Limpia los controladores de texto después de guardar el producto
    _nameController.clear();
    _rucController.clear();
    _correoController.clear();
    _telefonoController.clear();
    _addressController.clear();
    _cityController.clear();
    _codePostalController.clear();
    _provinceContoller.clear();

    setState(() {
      _selectedCiiuCode = 0;
      _selectedGroupIndex = 0;
      _selectedTaxIndexType = 0;
      _selectedCountryIndex = 0;
      _selectedPersonTypeIndex = 0;
      _selectedTaxPayerIndex = 0;
    });

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
        print(
            'El providers se ha guardado correctamente en la base de datos con el id: $result');
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

    super.dispose();
  }
}

class ContainerBlue extends StatelessWidget {
  final String label;
  final double mediaScreen;
  const ContainerBlue(
      {super.key, required this.label, required this.mediaScreen});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: mediaScreen * 0.88,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(8), // Establece el radio de los bordes
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.black, fontFamily: 'Poppins Bold', fontSize: 18),
        textAlign: TextAlign.start,
      ),
    );
  }
}
