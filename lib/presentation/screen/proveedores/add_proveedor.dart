import 'package:femovil/config/app_bar_sampler.dart';
import 'package:femovil/database/create_database.dart';
import 'package:femovil/database/gets_database.dart';
import 'package:femovil/database/list_database.dart';
import 'package:femovil/infrastructure/models/vendors.dart';
import 'package:femovil/presentation/screen/proveedores/select_vendor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  // Focus
  final FocusNode _rucFocusNode = FocusNode();

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
  String _countryText         = 'Ecuador';
  String _taxPayerText        = '';
  String _personTypeText      = '';
  String _ciiuActivitiesText  = '';
  String _provinceText        = '';
  String _cityText            = '';
  int _idMaxlength            = 20;

  loadList() async {
    List<Map<String, dynamic>> getGroupVendor = await listarTypeGroupVendor();
    List<Map<String, dynamic>> getTaxTypeVendor = await listarTaxType();
    List<Map<String, dynamic>> getCountryVendor = await listarCountries();
    List<Map<String, dynamic>> getTaxPayerVendor = await listarTaxPayer();
    List<Map<String, dynamic>> getTypePerson = await listarPersonTypeVendors();
    List<Map<String, dynamic>> getCiiuActivitesCodes = await getCiiuActivities();

    print('Value de ciuu $getCiiuActivitesCodes');
    print('Value de getGroupVendor $getGroupVendor ');
    print('Value de getTaxTypeVendor $getTaxTypeVendor');

    _ciiuActivitiesList.add({
      'lco_isic_id': 0, 
      'name': 'Selecciona un CIIU'
    });
    _groupVendorList.add({
      'c_bp_group_id': 0, 
      'groupbpname': 'Selecciona un Grupo'
    });
    _idTypeVendorList.add({
      'lco_tax_id_type_id': 0,
      'tax_id_type_name'  : 'Selecciona un tipo de identificación'
    });
    _taxPayerList.add({
      'lco_tax_payer_type_id': 0,
      'tax_payer_type_name'  : 'Selecciona un tipo de contribuyente'
    });
    _typePersonList.add({
      'lve_person_type_id': 0,
      'person_type_name': 'Selecciona un tipo de persona'
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
      _ciiuActivitiesList.addAll(getCiiuActivitesCodes);
      _groupVendorList.addAll(getGroupVendor);
      _idTypeVendorList.addAll(getTaxTypeVendor);
      _countryVendorList.addAll(getCountryVendor);
      _taxPayerList.addAll(getTaxPayerVendor);
      _typePersonList.addAll(getTypePerson);
    });

    if (getCountryVendor.isNotEmpty) {
      var defaultCountry = 171;
      List<Map<String, dynamic>> provinceListByCountry = await listarRegions(defaultCountry);

      setState(() {
        _selectedCountryIndex = defaultCountry;
        _provinceList.addAll(provinceListByCountry);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    loadList();

    // SE VALIDA QUE NO EXISTE UN PROVEEDOR CON EL MISMO RUC
    _rucFocusNode.addListener(() async {
      if (!_rucFocusNode.hasFocus) {
        String rucText = _rucController.text.trim(); 
        if (rucText.length == _idMaxlength) {
          bool ifExists = await proveedorExists(rucText);
                    
          if (ifExists) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Proveedor ya registrado', style: TextStyle(fontFamily: 'Poppins SemiBold', fontSize: 18)),
                  content: Text('El proveedor con el ID fiscal \'$rucText\' ya está registrado en el sistema.', style: TextStyle(
                    fontFamily: 'Poppins Regular',
                    fontSize: 16,
                  )),
                  actions: [
                    TextButton(
                      child: Text('Aceptar', style: TextStyle(fontFamily: 'Poppins SemiBold', fontSize: 16)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );

            _rucController.text = '';
          }
        }
      }
    });
  }

  void validateID(String idType, String id) {
    int sum           = 0;
    int res           = 0; 
    int mod           = 11;
    bool pri          = false;
    bool pub          = false;
    bool nat          = false;
    int provincesQty  = 22; 

    int p1 = 0;
    int p2 = 0;
    int p3 = 0;
    int p4 = 0;
    int p5 = 0;
    int p6 = 0;
    int p7 = 0;
    int p8 = 0;
    int p9 = 0;

    /* VALIDAMOS QUE EL CAMPO NO CONTENGA LETRAS */

    /* VALIDAMOS LA LONGITUD DEL IDENTIFICADOR*/
    int maxlength = _idMaxlength;
    if (id.length < maxlength) {
      throw 'Debe contener al menos ${maxlength.toString()} dígitos';
    }

    /* VALIDAMOS LOS DOS PIMEROS DIGITOS QUE CORRESPONDEN AL CODIGO DE PROVINCIA */
    int province = int.parse(id.substring(0, 2));
    if (province < 1 || province > provincesQty) {
      throw 'El código de provincia es inválido';
    }

    /* AQUI ALMACENAMOS LOS DIGITOS DEL IDENTIFICADOR EN VARIABLES */
    int d1  = int.parse(id.substring(0, 1));
    int d2  = int.parse(id.substring(1, 2));
    int d3  = int.parse(id.substring(2, 3));
    int d4  = int.parse(id.substring(3, 4));
    int d5  = int.parse(id.substring(4, 5));
    int d6  = int.parse(id.substring(5, 6));
    int d7  = int.parse(id.substring(6, 7));
    int d8  = int.parse(id.substring(7, 8));
    int d9  = int.parse(id.substring(8, 9));
    int d10 = int.parse(id.substring(9, 10));

    /* El tercer digito es: */                           
    /* 9 para sociedades priadas y extranjeros   */
    /* 6 para sociedades publicas */         
    /* menor que 6 (0,1,2,3,4,5) para personas naturales */ 
    if (d3 == 7 || d3 == 8) {
      throw 'El tercer dígito es inválido';
    }

    if (d3 < 6) {    
      /* Solo para personas naturales (modulo 10) */       
      nat = true;            
      p1 = d1 * 2;  if (p1 >= 10) p1 -= 9;
      p2 = d2 * 1;  if (p2 >= 10) p2 -= 9;
      p3 = d3 * 2;  if (p3 >= 10) p3 -= 9;
      p4 = d4 * 1;  if (p4 >= 10) p4 -= 9;
      p5 = d5 * 2;  if (p5 >= 10) p5 -= 9;
      p6 = d6 * 1;  if (p6 >= 10) p6 -= 9; 
      p7 = d7 * 2;  if (p7 >= 10) p7 -= 9;
      p8 = d8 * 1;  if (p8 >= 10) p8 -= 9;
      p9 = d9 * 2;  if (p9 >= 10) p9 -= 9;             
      mod = 10;
    }
    else if(d3 == 6) {  
      /* Solo para sociedades publicas (modulo 11) */                  
      /* Aqui el digito verficador esta en la posicion 9, en las otras 2 en la pos. 10 */          
      pub = true;             
      p1 = d1 * 3;
      p2 = d2 * 2;
      p3 = d3 * 7;
      p4 = d4 * 6;
      p5 = d5 * 5;
      p6 = d6 * 4;
      p7 = d7 * 3;
      p8 = d8 * 2;            
      p9 = 0;            
    }
    else if(d3 == 9) {   
      /* Solo para entidades privadas (modulo 11) */        
      pri = true;                                   
      p1 = d1 * 4;
      p2 = d2 * 3;
      p3 = d3 * 2;
      p4 = d4 * 7;
      p5 = d5 * 6;
      p6 = d6 * 5;
      p7 = d7 * 4;
      p8 = d8 * 3;
      p9 = d9 * 2;            
    }       

    sum = p1 + p2 + p3 + p4 + p5 + p6 + p7 + p8 + p9;                
    res = sum % mod;                                         

    /* Si residuo=0, dig.ver.=0, caso contrario 10 - residuo*/
    int digitChecker = res == 0 ? 0 : (mod - res);    

    // print('digito verificador: $digitChecker');

    /* ahora comparamos el elemento de la posicion 10 con el dig. ver.*/ 
    // PUBLICO
    if (pub) {
      if (digitChecker != d9) {
        throw 'El RUC del Sector Público es incorrecto';
      }

      if (id.substring(9, 12) == '0001') {
        throw 'El RUC debe terminar en 0001';
      }
    }    

    // PRIVADA
    if (pri) {
      if (digitChecker != d10) {
        throw 'El RUC del Sector Privado es incorrecto';
      }

      if (id.substring(10, 12) == '001') {
        throw 'El RUC debe terminar en 0001';
      }
    }  

    // NATURAL
    if (nat) {
      if (digitChecker != d10) {
        throw 'La cédula de Persona Natural es incorrecta';
      }

      if (id.length > 10 && id.substring(10, 12) == '001') {
        throw 'El RUC debe terminar en 001';
      }
    } 
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
        appBar: const PreferredSize(preferredSize: Size.fromHeight(50), child: AppBarSample(label: 'Agregar Proveedor')),
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

                      // DATOS DEL PROVEEDOR
                      ContainerBlue(
                        label: 'Datos Del Proveedor',
                        mediaScreen: mediaScreen,
                      ),
                      SizedBox(height: screenHeight * 0.023),

                      // TIPO DE IDENTIFICACION
                      CustomDropdownButtonFormFieldVendor(
                        identifier: 'idTypeVendor',
                        selectedIndex: _selectedIdTypeIndex,
                        dataList: _idTypeVendorList,
                        text: _idTypeText,
                        onSelected: (newValue, idTypeText) {
                          setState(() {
                            _selectedIdTypeIndex = newValue ?? 0;
                            _idTypeText = idTypeText;

                            if (idTypeText == 'C CEDULA' || idTypeText == 'P PASAPORTE') {
                              _idMaxlength = 10;
                            } else if (idTypeText == 'R RUC PERSONAL' || idTypeText == 'R RUC JURIDICO') {
                              _idMaxlength = 13;
                            }

                            _rucController.text = '';
                          });
                        },
                      ),
                      const SizedBox(height: 10),

                      // IDENTIFICADOR
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
                          focusNode: _rucFocusNode,                          
                          maxLength: _idMaxlength,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)), borderSide: BorderSide(width: 25, color: Colors.white)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)), borderSide: BorderSide(width: 25, color: Colors.white)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)), borderSide: BorderSide.none),
                            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)), borderSide: BorderSide(width: 1, color: Colors.red)),
                            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)), borderSide: BorderSide(width: 1, color: Colors.red)),
                            labelText: 'Ingresa identificador',
                            filled: true,
                            fillColor: Colors.white,
                            counterText: ''
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) 
                            {
                              return 'Por favor, ingresa un RUC/DNI válido';
                            } 
                            else if (_selectedIdTypeIndex != 0) 
                            {
                              // VERIFICA SI EL IDENTIFICADOR ES PASAPORTE
                              if (_idTypeText == 'P PASAPORTE' && value.length < _idMaxlength) { 
                                return 'Debe contener al menos $_idMaxlength dígitos'; 
                              }  

                              // VERIFICA SI EL IDENTIFICADOR ES CEDULA O RUC
                              if (_idTypeText == 'C CEDULA' || _idTypeText == 'R RUC PERSONAL' || _idTypeText == 'R RUC JURIDICO') {
                                try {
                                  validateID(_idTypeText, value);
                                } catch (error) {   
                                  return error.toString();
                                }
                              }  
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // RAZON SOCIAL O NOMBRE COMPLETO
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
                          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))],
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)), borderSide: BorderSide(width: 25, color: Colors.white)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)), borderSide: BorderSide(width: 25, color: Colors.white)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)), borderSide: BorderSide.none),
                              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)), borderSide: BorderSide(width: 1, color: Colors.red)),
                              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)), borderSide: BorderSide(width: 1, color: Colors.red)),
                              labelText: 'Razón Social o Nombre Completo',
                              filled: true,
                              fillColor: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingresa la razón social o nombre completo';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // CORREO
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
                      const SizedBox(height: 10),

                      // TELEFONO
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
                      const SizedBox(height: 10),

                      // GRUPO
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
                      const SizedBox(height: 10),

                      // CIIU
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
                      const SizedBox(height: 10),                      

                      // TIPO DE CONTRIBUYENTE
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
                      const SizedBox(height: 25),
                      // CustomDropdownButtonFormFieldVendor(identifier: 'typePersonVendor', selectedIndex: _selectedPersonTypeIndex, dataList:_typePersonList, text: _personTypeText, onSelected: (newValue, personTypeText) {

                      //     setState(() {

                      //         _selectedPersonTypeIndex = newValue ?? 0;
                      //         _personTypeText = personTypeText;

                      //     });

                      // },),
                      // DOMICILIO FISCAL
                      ContainerBlue(
                        label: 'Domicilio Fiscal',
                        mediaScreen: mediaScreen,
                      ),
                      const SizedBox(
                        height: 15,
                      ),

                      // PAIS
                      CustomDropdownButtonFormFieldVendor(
                        identifier: 'countryVendor',
                        selectedIndex: _selectedCountryIndex,
                        dataList: _countryVendorList,
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
                        },
                      ),
                      const SizedBox(height: 10),
                      
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
                      /*Container(
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
                            contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide(width: 25, color: Colors.white)
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide(width: 25, color: Colors.white)
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)), borderSide: BorderSide.none),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide(width: 1, color: Colors.red)
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                              borderSide:  BorderSide(width: 1, color: Colors.red)
                            ),
                            labelText: 'Provincia',
                            filled: true,
                            fillColor: Colors.white
                          ),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingresa una Provincia';
                            }
                            return null;
                          },
                        ),
                      )*/
                      const SizedBox(height: 10),

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
                      /*Container(
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
                      ),*/
                      const SizedBox(height: 10),

                      // DIRECCION
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
                      const SizedBox(height: 10),
                       
                      // CODIGO POSTAL
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
    int idGroup           = _selectedGroupIndex;
    int taxTypeId         = _selectedIdTypeIndex;
    int taxPayerVendorId  = _selectedTaxPayerIndex;
    int personTypeId      = _selectedPersonTypeIndex;
    int ciiuId            = _selectedCiiuCode;
    int countryId         = _selectedCountryIndex;
    int provinceId        = _selectedProvinceIndex;
    int cityId            = _selectedCityIndex;
    
    // Strings
    String groupText = _groupTextVendor;
    String taxIdText = _idTypeText;
    String countryName = _countryText;
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
        lcoTaxtPayerTypeId: taxPayerVendorId,
        taxPayerTypeName: taxPayerName,
        lvePersonTypeId: personTypeId,
        personTypeName: personTypeName,
        ciiuId: ciiuId,
        ciiuTagName: ciiuTagText,
        province: province,
        cCountryId: countryId,
        cRegionId: provinceId,
        cCityId: cityId,        
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
      _selectedIdTypeIndex = 0;
      _selectedCountryIndex = 0;
      _selectedPersonTypeIndex = 0;
      _selectedTaxPayerIndex = 0;
    });

    // Muestra un mensaje de éxito o realiza cualquier otra acción necesaria
    /*ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Proveedor guardado correctamente'),
    ));*/
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
                const Text('Proveedor guardado correctamente', style: TextStyle(fontFamily: 'Poppins Bold')),
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
