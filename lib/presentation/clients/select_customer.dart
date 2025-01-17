import 'package:femovil/presentation/products/utils/switch_generated_names_select.dart';
import 'package:flutter/material.dart';

class CustomDropdownButtonFormField extends StatelessWidget {
  final String identifier;
  final int selectedIndex;
  final String text;
  final List<Map<String, dynamic>> dataList;
  final Function(int?, String) onSelected;
  final bool readOnly;

  const CustomDropdownButtonFormField(
      {super.key,
      required this.identifier,
      required this.selectedIndex,
      required this.dataList,
      required this.text,
      required this.onSelected,
      this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    final mediaScreen = MediaQuery.of(context).size.width * 0.8;

    switch (identifier) {
      case 'groupBp':
        return Container(
          height: mediaScreen * 0.22,
          width: mediaScreen * 0.95,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 7,
                    spreadRadius: 2),
              ]),
          child: DropdownButtonFormField<int>(
            icon: Image.asset('lib/assets/Abajo.png'),
            value: selectedIndex,
            items: dataList
                .where((groupList) =>
                    groupList['c_bp_group_id'] is int &&
                    groupList['group_bp_name'] != '')
                .map<DropdownMenuItem<int>>((group) {
              print('tax $group');
              return DropdownMenuItem<int>(
                value: group['c_bp_group_id'] as int,
                child: Text(
                  group['group_bp_name'] as String,
                  style: const TextStyle(
                      fontFamily: 'Poppins Regular',
                      overflow: TextOverflow.ellipsis),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              print('esto es el taxList ${dataList}');
              String nameGroup =
                  invoke('obtenerNombreGroup', newValue, dataList);
              print("esto es el nombre de impuesto $nameGroup");
              onSelected(newValue, nameGroup);
            },
            decoration: InputDecoration(
                errorStyle: const TextStyle(fontFamily: 'Poppins Regular'),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none)),
          ),
        );
      case 'idType':
        return Container(
          height: mediaScreen * 0.22,
          width: mediaScreen * 0.95,
          decoration: BoxDecoration(
              color: readOnly ? Colors.grey.shade300 : Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5), 
                  blurRadius: 7, 
                  spreadRadius: 2
                )
              ]
          ),
          child: DropdownButtonFormField<int>(
            icon: Image.asset('lib/assets/Abajo.png'),
            value: selectedIndex,
            items: dataList
                .where((taxType) =>
                    taxType['lco_tax_id_type_id'] is int &&
                    taxType['tax_id_type_name'] != '')
                .map<DropdownMenuItem<int>>((taxType) {
              print('tax $taxType');
              return DropdownMenuItem<int>(
                value: taxType['lco_tax_id_type_id'] as int,
                child: SizedBox(
                    width: 200,
                    child: Text(
                      taxType['tax_id_type_name'] as String,
                      style: const TextStyle(
                        fontFamily: 'Poppins Regular',
                        color: Colors.black
                      ),
                    )),
              );
            }).toList(),
            onChanged: readOnly ? null : (newValue) {
              print('esto es el taxList ${dataList}');
              String nameTax = invoke('obtenerNombreTax', newValue, dataList);
              print("esto es el nombre del tipo de impuesto $nameTax");

              onSelected(newValue, nameTax);
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              filled: true,
              fillColor: readOnly ? Colors.grey.shade300 : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
            validator: (value) {
              if (value == null || value == 0) {
                return 'Por favor, selecciona un tipo de identificación';
              }
              return null;
            },
          ),
        );
      case 'taxPayer':
        return Container(
          height: mediaScreen * 0.22,
          width: mediaScreen * 0.95,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 7,
                    spreadRadius: 2)
              ]),
          child: DropdownButtonFormField<int>(
            icon: Image.asset('lib/assets/Abajo.png'),
            value: selectedIndex,
            items: dataList
                .where((taxPayer) =>
                    taxPayer['lco_tax_payer_type_id'] is int &&
                    taxPayer['tax_payer_type_name'] != '')
                .map<DropdownMenuItem<int>>((taxPayer) {
              return DropdownMenuItem<int>(
                value: taxPayer['lco_tax_payer_type_id'],
                child: SizedBox(
                    width: 200,
                    child: Text(
                      taxPayer['tax_payer_type_name'] as String,
                      style: const TextStyle(fontFamily: 'Poppins Regular'),
                    )),
              );
            }).toList(),
            onChanged: (newValue) {
              print('esto es el taxList ${dataList}');
              String nameTaxPayer = invoke('obtenerNombreTaxPayer', newValue, dataList);
              print("esto es el nombre del tipo de constribuyente $nameTaxPayer");

              onSelected(newValue, nameTaxPayer);
            },
            decoration: InputDecoration(
                errorStyle: const TextStyle(fontFamily: 'Poppins Regular'),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                )),
          ),
        );
      case 'typePerson':
        return DropdownButtonFormField<int>(
          value: selectedIndex,
          items: dataList
              .where((typePerson) =>
                  typePerson['lve_person_type_id'] is int &&
                  typePerson['person_type_name'] != '')
              .map<DropdownMenuItem<int>>((typePerson) {
            return DropdownMenuItem<int>(
              value: typePerson['lve_person_type_id'],
              child: SizedBox(
                  width: 200,
                  child: Text(typePerson['person_type_name'] as String)),
            );
          }).toList(),
          onChanged: (newValue) {
            print('esto es el taxList ${dataList}');
            String nameTypePerson =
                invoke('obtenerNombreTypePerson', newValue, dataList);
            print("esto es el nombre del tipo de persona $nameTypePerson");

            onSelected(newValue, nameTypePerson);
          },
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) {
            if (value == null || value == 0) {
              return 'Por favor selecciona un tipo de persona';
            }
            return null;
          },
        );
      case 'selectCountry':
        return Container(
          height: mediaScreen * 0.22,
          width: mediaScreen * 0.95,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  blurRadius: 7,
                  spreadRadius: 2,
                  color: Colors.grey.withOpacity(0.5))
            ],
          ),
          child: DropdownButtonFormField<int>(
            icon: Image.asset('lib/assets/Abajo.png'),
            value: selectedIndex,
            items: dataList
              .where((country) => country['c_country_id'] is int && country['country'].toString() != 'null')
              .map<DropdownMenuItem<int>>((country) {
                // print('tax $country');
                return DropdownMenuItem<int>(
                  value: country['c_country_id'] as int,
                  child: Container(
                    width: mediaScreen * 0.5,
                    child: Text(
                      country['country'].toString(),
                      overflow: TextOverflow.clip,
                      style: const TextStyle(fontFamily: 'Poppins Regular', color: Colors.black),
                    )
                  ),
                );
            }).toList(),
            onChanged: (newValue) {
              print('esto es el Listado de country ${dataList}');
              String nameCountry = invoke('obtenerNombreCountry', newValue, dataList);
              print("esto es el nombre del Pais $nameCountry");

              onSelected(newValue, nameCountry);
            },
            decoration: InputDecoration(
              errorStyle: const TextStyle(fontFamily: 'Poppins Regular'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(15),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value == null || value == 0) {
                return 'Por favor, selecciona un país';
              }
              return null;
            },
          ),
        );
      case 'selectTypeAccountBank':
        return Container(
            height: mediaScreen * 0.22,
            width: mediaScreen * 0.95,
            decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  blurRadius: 7,
                  spreadRadius: 2,
                  color: Colors.grey.withOpacity(0.5))
            ],
          ),
          child: DropdownButtonFormField<int>(
            value: selectedIndex,
            items: dataList
                .where((bankAccount) =>
                    bankAccount['c_bank_id'] is int &&
                    bankAccount['bank_name'] != '')
                .map<DropdownMenuItem<int>>((bankAcc) {
              print('bankAccount $bankAcc');
              return DropdownMenuItem<int>(
                value: bankAcc['c_bank_id'] as int,
                child: SizedBox(
                  width: mediaScreen * 0.7,
                  child: Text(bankAcc['bank_name'] as String, style: const TextStyle(fontFamily: 'Poppins Regular'),)),
              );
            }).toList(),
            onChanged: (newValue) {
              print('esto es el bank Account List ${dataList}');
              String nameBankAccount =
                  invoke('obtenerNombreBankAccount', newValue, dataList);
              print(
                  "esto es el nombre de la cuenta bancaria $nameBankAccount y este el id $newValue");
          
              onSelected(newValue, nameBankAccount);
            },
            decoration:  InputDecoration(
               errorStyle: const TextStyle(fontFamily: 'Poppins Regular'),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(15),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value == null || value == 0) {
                return 'Por favor selecciona una cuenta bancaria';
              }
              return null;
            },
          ),
        );
      case 'selectTypeCoins':
        return Container(
           height: mediaScreen * 0.22,
            width: mediaScreen * 0.95,
            decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  blurRadius: 7,
                  spreadRadius: 2,
                  color: Colors.grey.withOpacity(0.5))
            ],
          ),
          child: DropdownButtonFormField<int>(
            value: selectedIndex,
            items: dataList
                .where((typeCoins) =>
                    typeCoins['c_currency_id'] is int &&
                    typeCoins['iso_code'] != '')
                .map<DropdownMenuItem<int>>((typeCoins) {
              return DropdownMenuItem<int>(
                value: typeCoins['c_currency_id'] as int,
                child: SizedBox(
                   width: mediaScreen * 0.7,
                  child: Text(typeCoins['iso_code'] as String, style: const TextStyle(fontFamily: 'Poppins Regular'),)),
              );
            }).toList(),
            onChanged: (newValue) {
              print('esto es el currency List ${dataList}');
              String nameCurrency =
                  invoke('obtenerNombreCurrencyType', newValue, dataList);
              print(
                  "esto es el nombre que tiene el tipo de moneda $nameCurrency y este el id $newValue");
          
              onSelected(newValue, nameCurrency);
            },
            decoration:  InputDecoration(
              errorStyle: const TextStyle(fontFamily: 'Poppins Regular'),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(15),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value == null || value == 0) {
                return 'Por favor selecciona un tipo de moneda';
              }
              return null;
            },
          ),
        );
      case 'selectProvince':
        return Container(
          height: mediaScreen * 0.22,
          width: mediaScreen * 0.95,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                blurRadius: 7,
                spreadRadius: 2,
                color: Colors.grey.withOpacity(0.5)
              )
            ],
          ),
          child: DropdownButtonFormField<int>(
            icon: Image.asset('lib/assets/Abajo.png'),
            value: selectedIndex,
            items: dataList
              .where((item) => item['c_region_id'] is int && item['region'].toString() != '')
              .map<DropdownMenuItem<int>>((itemRegion) {
                return DropdownMenuItem<int>(
                  value: itemRegion['c_region_id'] as int,
                  child: SizedBox(
                    width: mediaScreen * 0.7,
                    child: Text(itemRegion['region'].toString(), style: const TextStyle(fontFamily: 'Poppins Regular'))
                  ),
                );
            }).toList(),
            onChanged: (newValue) {
              print('Este es el listado de region: ${dataList}');
              String regionName = dataList.firstWhere((item) => item['c_region_id'] == newValue, orElse: () => {})["region"];
              print("Este es el nombre que tiene la region $regionName y el id $newValue");
          
              onSelected(newValue, regionName);
            },
            decoration:  InputDecoration(
              errorStyle: const TextStyle(fontFamily: 'Poppins Regular'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(15)),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (dataList.length > 1) {
                if (value == null || value == 0) {
                  return 'Por favor, selecciona una provincia';
                }
              }
              
              return null;
            },
          ),
        );
      case 'selectCity':
        return Container(
          height: mediaScreen * 0.22,
          width: mediaScreen * 0.95,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                blurRadius: 7,
                spreadRadius: 2,
                color: Colors.grey.withOpacity(0.5)
              )
            ],
          ),
          child: DropdownButtonFormField<int>(
            icon: Image.asset('lib/assets/Abajo.png'),
            value: selectedIndex,
            items: dataList
              .where((item) => item['c_city_id'] is int && item['city'].toString() != '')
              .map<DropdownMenuItem<int>>((itemRegion) {
                return DropdownMenuItem<int>(
                  value: itemRegion['c_city_id'] as int,
                  child: SizedBox(
                    width: mediaScreen * 0.7,
                    child: Text(itemRegion['city'].toString(), style: const TextStyle(fontFamily: 'Poppins Regular'))
                  ),
                );
            }).toList(),
            onChanged: (newValue) {
              print('Este es el listado de city: ${dataList}');
              String cityName = dataList.firstWhere((item) => item['c_city_id'] == newValue, orElse: () => {})["city"];
              print("Este es el nombre que tiene la city $cityName y el id $newValue");
          
              onSelected(newValue, cityName);
            },
            decoration:  InputDecoration(
              errorStyle: const TextStyle(fontFamily: 'Poppins Regular'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(15)),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (dataList.length > 1) {
                if (value == null || value == 0) {
                  return 'Por favor, selecciona una ciudad';
                }
              }
              
              return null;
            },
          ),
        );
      
      default:
        return DropdownButtonFormField<int>(
          value: selectedIndex,
          items: dataList
              .where((defaults) => defaults['key'] is int)
              .map<DropdownMenuItem<int>>((defaults) {
            return DropdownMenuItem<int>(
              value: defaults['key'] as int,
              child: Text(defaults['value'] as String),
            );
          }).toList(),
          onChanged: (newValue) {
            onSelected(newValue, 'Nada');
          },
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) {
            if (value == null || value == 0) {
              return 'Por favor crea el idenficiador del select';
            }
            return null;
          },
        );
    }
  }
}
