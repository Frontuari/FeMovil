import 'package:femovil/config/app_bar_sampler.dart';
import 'package:femovil/database/gets_database.dart';
import 'package:femovil/database/list_database.dart';
import 'package:femovil/infrastructure/models/clients.dart';
import 'package:femovil/presentation/clients/helpers/save_client_to_database.dart';
import 'package:femovil/presentation/clients/idempiere/create_customer.dart';
import 'package:femovil/presentation/clients/select_customer.dart';
import 'package:femovil/utils/alerts_messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _codePostalController = TextEditingController();

  // FOCUS
  final FocusNode _rucFocusNode = FocusNode();

//List
  final List<Map<String, dynamic>> _countryList     = [];
  final List<Map<String, dynamic>> _groupList       = [];
  final List<Map<String, dynamic>> _idTypeList      = [];
  final List<Map<String, dynamic>> _taxPayerList    = [];
  final List<Map<String, dynamic>> _typePersonList  = [];
  List<Map<String, dynamic>> _provinceList          = [];
  List<Map<String, dynamic>> _cityList              = [];

  // SELECTED
  int _selectedCountryIndex   = 0; // 171
  int _selectedGroupIndex     = 0;
  int _selectedIdType         = 0;
  int _selectedTaxPayer       = 0;
  int _seletectedTypePerson   = 0;
  int _selectedProvinceIndex  = 0;
  int _selectedCityIndex      = 0;
// Text

  String _countryText     = 'Ecuador';
  String _groupText       = '';
  String _idTypeText      = '';
  String _taxPayerText    = '';
  String _typePersonText  = '';
  String _cityText        = '';
  String _provinceText    = '';
  
  int _idMaxlength        = 20;

  loadList() async {
    List<Map<String, dynamic>> getCountryGroup = await listarCountries();
    List<Map<String, dynamic>> getGroupTercero = await listarGroupTercero();
    List<Map<String, dynamic>> getIdType = await listarTaxType();
    List<Map<String, dynamic>> getTaxPayer = await listarTaxPayer();
    List<Map<String, dynamic>> getTypePerson = await listarTypePerson();
    print('Esta es la respuesta $getCountryGroup');
    print('Esta es la respuesta de getGroupTercero $getGroupTercero');
    print('Esto es getIdType $getIdType');
    print('Estos son los taxPayers $getTaxPayer');
    print('Estos son los type person $getTypePerson');
    
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
      'tax_payer_type_name': 'Selecciona un tipo de contribuyente'
    });
    _typePersonList.add({
      'lve_person_type_id': 0,
      'person_type_name': 'Selecciona un tipo de Persona'
    });
    _countryList.add({
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
      _countryList.addAll(getCountryGroup);
      _groupList.addAll(getGroupTercero);
      _idTypeList.addAll(getIdType);
      _taxPayerList.addAll(getTaxPayer);
      _typePersonList.addAll(getTypePerson);
    });

    if (getCountryGroup.isNotEmpty) {
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

    // SE VALIDA QUE NO EXISTE UN CLIENTE CON EL MISMO RUC
    _rucFocusNode.addListener(() async {
      if (!_rucFocusNode.hasFocus) {
        String rucText = _rucController.text.trim(); 

        if (rucText.length == _idMaxlength) {
          bool ifExists = await customerExists(rucText);
          
          if (ifExists) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Cliente ya registrado', style: TextStyle(fontFamily: 'Poppins SemiBold', fontSize: 18)),
                  content: Text(
                    'El Cliente con el ID fiscal \'$rucText\' ya se encuentra registrado en el sistema.',
                    style: TextStyle(fontFamily: 'Poppins Regular', fontSize: 16),
                  ),
                  actions: [
                    TextButton(
                      child: Text('Aceptar', style: TextStyle(fontFamily: 'Poppins SemiBold', fontSize: 16)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              }
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
    final mediaScreen = MediaQuery.of(context).size.width * 0.8;
    final colorTheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: const PreferredSize(preferredSize: Size.fromHeight(50), child: AppBarSample(label: 'Agregar Cliente')),
        body: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: mediaScreen,
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: MediaQuery.of(context).size.width * 0.05),

                    // DATOS PERSONALES
                    SizedBox(
                      width: mediaScreen,
                      child: const Text(
                        "Datos Personales",
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.black, fontFamily: 'Poppins Bold', fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 15),

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
                          } else if (idTypeText == 'R RUC PERSONAL' || idTypeText == 'R RUC JURIDICO') {
                            _idMaxlength = 13;
                          }

                          // RESETEAMOS EL VALOR DEL IDENTIFICADOR
                          _rucController.text = '';
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    // IDENTIFICADOR
                    Container(
                      height: mediaScreen * 0.20,
                      width: mediaScreen * 0.95,
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
                        controller: _rucController,
                        focusNode: _rucFocusNode,
                        maxLength: _idMaxlength,
                        decoration: InputDecoration(
                          errorStyle: const TextStyle(fontFamily: 'Poppins Regular'),
                          labelText: 'Ingresa identificador',
                          labelStyle: const TextStyle(fontFamily: 'Poppins Regular', color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white, width: 25)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white, width: 25)),
                          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red, width: 1)),
                          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red, width: 1)),
                          counterText: ''
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) 
                          {
                            return 'Por favor, ingresa un RUC/DNI válido';
                          } 
                          else if (_selectedIdType != 0) 
                          {
                            // VERIFICA SI EL IDENTIFICADOR ES PASAPORTE
                            if (_idTypeText == 'P PASAPORTE' && value.length < _idMaxlength) { 
                              return 'Debe contener al menos $_idMaxlength dígitos'; 
                            }  

                            // VERIFICA SI EL IDENTIFICADOR ES CEDULA O RUC
                            if (_idTypeText == 'C CEDULA' || _idTypeText == 'R RUC PERSONAL') {
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
                      height: mediaScreen * 0.20,
                      width: mediaScreen * 0.95,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))],
                        decoration: InputDecoration(
                          labelText: 'Razón Social o Nombre Completo',
                          labelStyle: const TextStyle(fontFamily: 'Poppins Regular', color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white, width: 25)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white, width: 25)),
                          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red, width: 1)),
                          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red, width: 1)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa el nombre del Cliente';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    const SizedBox(height: 10),                    

                    // GRUPO
                    CustomDropdownButtonFormField(
                      identifier: 'groupBp',
                      selectedIndex: _selectedGroupIndex,
                      dataList: _groupList,
                      text: _groupText,
                      onSelected: (newValue, selected) {
                        setState(() {
                          _selectedGroupIndex = newValue ?? 0;
                          _groupText = (newValue != 0) ? selected : "";                          
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    // TIPO DE IMPUESTOS                    

                    // TIPO DE CONTRIBUYENTE
                    CustomDropdownButtonFormField(
                      identifier: 'taxPayer',
                      selectedIndex: _selectedTaxPayer,
                      dataList: _taxPayerList,
                      text: _taxPayerText,
                      onSelected: (newValue, payerText) {
                        setState(() {
                          _selectedTaxPayer = newValue ?? 0;
                          _taxPayerText = (newValue != 0) ? payerText : ""; 
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    // const SizedBox(height: 10,),
                    // CustomDropdownButtonFormField(identifier: 'typePerson', selectedIndex: _seletectedTypePerson, dataList: _typePersonList, text: _typePersonText, onSelected: (newValue, tyPersonText) {
                    //     setState(() {
                    //       _seletectedTypePerson = newValue ?? 0;
                    //       _typePersonText = tyPersonText;

                    //     });

                    // },),

                    // CORREO
                    Container(
                      height: mediaScreen * 0.20,
                      width: mediaScreen * 0.95,
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
                        decoration: InputDecoration(
                            errorStyle:
                                const TextStyle(fontFamily: 'Poppins Regular'),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.red)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 1,
                                )),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 25, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 25,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 25,
                              ),
                            ),
                            labelText: 'Correo',
                            labelStyle: const TextStyle(
                                fontFamily: 'Poppins Regular',
                                color: Colors.black),
                            filled: true,
                            fillColor: Colors.white),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Por favor ingresa un correo';
                          } else if (!value.contains('@')) {
                            return 'Por favor ingresa un correo electronico valido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // TELEFONO
                    Container(
                      height: mediaScreen * 0.20,
                      width: mediaScreen * 0.95,
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
                        decoration: InputDecoration(
                            errorStyle:
                                const TextStyle(fontFamily: 'Poppins Regular'),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.red)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 1,
                                )),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 25,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 25,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 25, horizontal: 20),
                            labelText: 'Telefono',
                            labelStyle: const TextStyle(
                                fontFamily: 'Poppins Regular',
                                color: Colors.black),
                            filled: true,
                            fillColor: Colors.white),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el telefono del cliente';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // DIRECCION FISCAL
                    SizedBox(
                      width: mediaScreen,
                      child: const Text(
                        "Dirección Fiscal",
                        textAlign: TextAlign.start,
                        style: TextStyle(fontFamily: 'Poppins Bold', color: Colors.black, fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // PAIS
                    CustomDropdownButtonFormField(
                      identifier: 'selectCountry',
                      selectedIndex: _selectedCountryIndex,
                      dataList: _countryList ?? [],
                      text: _countryText,
                      onSelected: (newValue, newText)  async {
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
                    /*Container(
                      height: mediaScreen * 0.20,
                      width: mediaScreen * 0.95,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 7,
                                spreadRadius: 2,
                                color: Colors.grey.withOpacity(0.5))
                          ]),
                      child: TextFormField(
                        controller: _provinceController,
                        decoration: InputDecoration(
                          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red, width: 1.0)),
                          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red, width: 1.0)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(width: 25, color: Colors.white)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(width: 25, color: Colors.white)),
                          labelText: 'Provincia',
                          labelStyle: const TextStyle(fontFamily: 'Poppins Regular', color: Colors.black),
                          filled: true,
                          fillColor: Colors.white
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa la Provincia';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.text,
                      ),
                    )*/
                    CustomDropdownButtonFormField(
                      identifier: 'selectProvince',
                      selectedIndex: _selectedProvinceIndex,
                      dataList: _provinceList,
                      text: _provinceText,
                      onSelected: (newValue, newText) async {
                        var provinceIndex = newValue ?? 0;
                        var provinceName  = (newValue != 0) ? newText : ""; 

                        List<Map<String, dynamic>> newCityList = [];
                        newCityList.add({
                          'c_city_id': 0,
                          'city'     : 'Selecciona una ciudad'
                        });
                        if (provinceName != "") {
                          dynamic citiesListByRegion = await listarCities(provinceIndex);

                          newCityList.addAll(citiesListByRegion);
                        }

                        print('cities by province: $newCityList');

                        setState(() {
                          _selectedProvinceIndex  = provinceIndex;
                          _provinceText           = provinceName;
                          _cityList               = newCityList;
                          _selectedCityIndex      = 0;
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    // CIUDAD
                    /*Container(
                      height: mediaScreen * 0.20,
                      width: mediaScreen * 0.95,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 7,
                                spreadRadius: 2,
                                color: Colors.grey.withOpacity(0.5))
                          ]),
                      child: TextFormField(
                        controller: _cityController,
                        decoration: InputDecoration(
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 1.0)),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 1.0,
                                )),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 25, horizontal: 20),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    width: 25, color: Colors.white)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                  width: 25, color: Colors.white),
                            ),
                            labelText: 'Ciudad',
                            labelStyle: const TextStyle(
                                fontFamily: 'Poppins Regular',
                                color: Colors.black),
                            filled: true,
                            fillColor: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa la Ciudad';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.text,
                      ),
                    )*/
                    CustomDropdownButtonFormField(
                      identifier: 'selectCity',
                      selectedIndex: _selectedCityIndex,
                      dataList: _cityList,
                      text: _cityText,
                      onSelected: (newValue, newText) {
                        setState(() {
                          _selectedCityIndex  = newValue ?? 0;
                          _cityText           = newValue != 0 ? newText : "";
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    // DIRECCION
                    Container(
                      height: mediaScreen * 0.30,
                      width: mediaScreen * 0.95,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 7,
                              spreadRadius: 2,
                            )
                          ]),
                      child: TextFormField(
                        controller: _direccionController,
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 25, horizontal: 20),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    width: 25, color: Colors.white)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 25,
                                )),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 1.0)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    width: 1.0, color: Colors.red)),
                            labelText: 'Direccion',
                            labelStyle: const TextStyle(
                              fontFamily: 'Poppins Regular',
                              color: Colors.black,
                            ),
                            filled: true,
                            fillColor: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa la direccion del cliente';
                          }
                          return null;
                        },
                        maxLines: 2,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // CODIGO POSTAL
                    Container(
                      height: mediaScreen * 0.20,
                      width: mediaScreen * 0.95,
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
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 25, horizontal: 20),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    width: 25, color: Colors.white)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    width: 25, color: Colors.white)),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 1)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 1)),
                            labelText: 'Codigo Postal',
                            errorStyle: const TextStyle(
                              fontFamily: 'Poppins Regular',
                            ),
                            labelStyle: const TextStyle(
                                fontFamily: 'Poppins Regular',
                                color: Colors.black),
                            filled: true,
                            fillColor: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa el codigo postal de su dirección';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                    ),

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
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
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
                            'Crear Cliente',
                            style: TextStyle(fontFamily: 'Poppins SemiBold'),
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

  void _saveProduct() async {
    // Obtén los valores del formulario
    String name = _nameController.text;
    String ruc = _rucController.text;
    String correo = _correoController.text;
    String telefono = _telefonoController.text;
    String address = _direccionController.text;
    String province = _provinceController.text;
    String city = _cityController.text;
    String codePostal = _codePostalController.text;

    // Selected DropdownButtonFormField

    int selectlcoTaxPayerTypeId = _selectedTaxPayer;
    int selectlveTypePerson     = _seletectedTypePerson;
    int selectGoupBp            = _selectedGroupIndex;
    int selectCountryId         = _selectedCountryIndex;
    int selectProvinceId        = _selectedProvinceIndex;
    int selectCityId            = _selectedCityIndex;
    int selectIdType            = _selectedIdType; // _selectedTaxType;

    // Text Selected
    String personTypeText = _typePersonText;
    String payerTypeName = _taxPayerText;
    String countryTextName = _countryText;
    String idTypeName = _idTypeText;
    String groupBpName = _groupText;

    bool ifExists = await customerExists(ruc);

    

    if (ifExists) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Cliente ya registrado',
              style: TextStyle(
                fontFamily: 'Poppins SemiBold',
                fontSize: 18,
              ),
            ),
            content: Text(
              'El Cliente con el ID fiscal proporcionado ya está registrado en el sistema.',
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

    // Crea una instancia del producto
    /*Customer client = Customer(
      bpName: name,
      ruc: ruc,
      address: address,
      cBpGroupId: selectGoupBp,
      cBparnetLocationId: 0,
      lcoTaxPayerTypeId: selectlcoTaxPayerTypeId,
      lvePersonTypeId: selectlveTypePerson,
      personTypeName: personTypeText,
      taxPayerTypeName: payerTypeName,
      cCityId: 0,
      cCountryId: selectCountryId,
      cLocationId: 0,
      cRegionId: 0,
      cbPartnerId: 0,
      city: city,
      codClient: 0,
      codePostal: codePostal,
      country: countryTextName,
      isBillTo: 'Y',
      lcoTaxIdTypeId: selectIdType,
      taxIdTypeName: idTypeName,
      email: correo,
      phone: telefono,
      cBpGroupName: groupBpName,
      region: province
    );*/
    Customer client = Customer(
      bpName: name,
      ruc: ruc,
      address: address,
      cBpGroupId: selectGoupBp,
      cBparnetLocationId: 0,
      lcoTaxPayerTypeId: selectlcoTaxPayerTypeId,
      lvePersonTypeId: selectlveTypePerson,
      personTypeName: personTypeText,
      taxPayerTypeName: payerTypeName,
      cCityId: selectCityId,
      cCountryId: selectCountryId,
      cLocationId: 0,
      cRegionId: selectProvinceId,
      cbPartnerId: 0,
      codClient: 0,
      codePostal: codePostal,
      isBillTo: 'Y',
      lcoTaxIdTypeId: selectIdType,
      taxIdTypeName: idTypeName,
      email: correo,
      phone: telefono,
      cBpGroupName: groupBpName,
    );

    print('Data antes de enviar $client' );

    // Llama a un método para guardar el producto en Sqflite


    // Limpia los controladores de texto después de guardar el producto
    _nameController.clear();
    _rucController.clear();
    _correoController.clear();
    _telefonoController.clear();
    _cityController.clear();
    _codePostalController.clear();
    _direccionController.clear();

    setState(() {
      _selectedCountryIndex = 0;
      _selectedGroupIndex = 0;
      _selectedIdType = 0;
      _selectedTaxPayer = 0;
      _seletectedTypePerson = 0;
    });

    showLoadingDialog(context);
  
    await createCustomerIdempiere(client.toMap());

    await saveClientToDatabase(client);
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          backgroundColor: Colors.white,
          // Center the title, content, and actions using a Column
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Wrap content vertically
            children: [
              Image.asset('lib/assets/Check@2x.png',
                  width: 50, height: 50), // Adjust width and height
              const Text('Cliente creado con éxito',
                  style: TextStyle(fontFamily: 'Poppins Bold')),
              TextButton(
                onPressed: () =>
                    {Navigator.pop(context), Navigator.pop(context)},
                child: const Text('Volver'),
              ),
            ],
          ),
        );
      },
    );

    // Muestra un mensaje de éxito o realiza cualquier otra acción necesaria
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Cliente guardado correctamente'),
    ));
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
