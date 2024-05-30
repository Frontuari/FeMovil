import 'package:femovil/config/app_bar_sampler.dart';
import 'package:femovil/presentation/orden_compra/orden_compra.dart';
import 'package:femovil/presentation/screen/proveedores/edit_providers.dart';
import 'package:flutter/material.dart';

class ProvidersDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> provider;

  const ProvidersDetailsScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final screenMax = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBarSample(label: 'Detalles del proveedor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Form(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: screenMax,
                    height: screenMax * 1.40,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 7,
                              spreadRadius: 2)
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            SizedBox(
                                width: screenMax,
                                child: const Text(
                                  'Nombre',
                                  style: TextStyle(
                                    fontFamily: 'Poppins Bold',
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.start,
                                )),
                            SizedBox(
                              height: screenMax * 0.040,
                            ),
                            SizedBox(
                              width: screenMax,
                              child: Text(
                                '${provider['bpname']}',
                                style: const TextStyle(
                                    fontFamily: 'Poppins Regular'),
                              ),
                            ),
                            SizedBox(
                              height: screenMax * 0.040,
                            ),
                            SizedBox(
                              width: screenMax,
                              child: const Text(
                                'Ruc/DNI',
                                style: TextStyle(
                                    fontFamily: 'Poppins Bold', fontSize: 18),
                              ),
                            ),
                            SizedBox(
                              height: screenMax * 0.040,
                            ),
                            SizedBox(
                              width: screenMax,
                              child: Text(
                                provider['tax_id'].toString(),
                                style: const TextStyle(
                                    fontFamily: 'Poppins Regular'),
                              ),
                            ),
                            SizedBox(
                              height: screenMax * 0.040,
                            ),
                            SizedBox(
                              width: screenMax,
                              child: const Text(
                                'Detalles',
                                style: TextStyle(
                                    fontFamily: 'Poppins Bold', fontSize: 18),
                              ),
                            ),
                            SizedBox(
                              height: screenMax * 0.040,
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Correo: ',
                                  style: TextStyle(fontFamily: 'Poppins Bold'),
                                ),
                                Flexible(
                                    child: Text(
                                  provider['email'] != '{@nil=true}' &&
                                          provider['email']
                                              .toString()
                                              .contains("@")
                                      ? provider['email'].toString()
                                      : '',
                                  style: const TextStyle(
                                      fontFamily: 'Poppins Regular'),
                                  overflow: TextOverflow.clip,
                                ))
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Telefono: ',
                                  style: TextStyle(fontFamily: 'Poppins Bold'),
                                ),
                                Flexible(
                                    child: Text(
                                  provider['phone'] != '{@nil=true}'
                                      ? provider['phone'].toString()
                                      : '',
                                  style: const TextStyle(
                                      fontFamily: 'Poppins Regular'),
                                  overflow: TextOverflow.clip,
                                ))
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Grupo: ',
                                  style: TextStyle(fontFamily: 'Poppins Bold'),
                                ),
                                Flexible(
                                    child: Text(
                                  provider['groupbpname'] != '{@nil=true}'
                                      ? provider['groupbpname'].toString()
                                      : '',
                                  style: const TextStyle(
                                      fontFamily: 'Poppins Regular'),
                                  overflow: TextOverflow.clip,
                                ))
                              ],
                            ),
                            Container(
                                width: screenMax,
                                child: const Text(
                                  'Tipo de contribuyente: ',
                                  style: TextStyle(fontFamily: 'Poppins Bold'),
                                )),
                            Container(
                                width: screenMax,
                                child: Text(
                                  provider['tax_payer_type_name'] !=
                                          '{@nil=true}'
                                      ? provider['tax_payer_type_name']
                                          .toString()
                                      : '',
                                  style: const TextStyle(
                                      fontFamily: 'Poppins Regular'),
                                  overflow: TextOverflow.clip,
                                )),
                            SizedBox(
                              height: screenMax * 0.040,
                            ),
                            SizedBox(
                              width: screenMax,
                              child: const Text(
                                'Domicilio Fiscal',
                                style: TextStyle(
                                    fontFamily: 'Poppins Bold', fontSize: 18),
                              ),
                            ),
                            SizedBox(
                              height: screenMax * 0.040,
                            ),
                            Container(
                                width: screenMax,
                                child: const Text(
                                  'Dirección: ',
                                  style: TextStyle(fontFamily: 'Poppins Bold'),
                                  textAlign: TextAlign.start,
                                )),
                            Container(
                                width: screenMax,
                                child: Text(
                                  provider['address'] != '{@nil=true}'
                                      ? provider['address'].toString()
                                      : '',
                                  style: const TextStyle(
                                      fontFamily: 'Poppins Regular'),
                                  overflow: TextOverflow.clip,
                                )),
                            Row(
                              children: [
                                const Text(
                                  'Provincia: ',
                                  style: TextStyle(fontFamily: 'Poppins Bold'),
                                ),
                                Flexible(
                                    child: Text(
                                  provider['province'] != '{@nil=true}'
                                      ? provider['province'].toString()
                                      : '',
                                  style: const TextStyle(
                                      fontFamily: 'Poppins Regular'),
                                  overflow: TextOverflow.clip,
                                ))
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Ciudad: ',
                                  style: TextStyle(fontFamily: 'Poppins Bold'),
                                ),
                                Flexible(
                                    child: Text(
                                  provider['city'] != '{@nil=true}'
                                      ? provider['city'].toString()
                                      : '',
                                  style: const TextStyle(
                                      fontFamily: 'Poppins Regular'),
                                  overflow: TextOverflow.clip,
                                ))
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  'País: ',
                                  style: TextStyle(fontFamily: 'Poppins Bold'),
                                ),
                                Flexible(
                                    child: Text(
                                  provider['country_name'] != '{@nil=true}'
                                      ? provider['country_name'].toString()
                                      : '',
                                  style: const TextStyle(
                                      fontFamily: 'Poppins Regular'),
                                  overflow: TextOverflow.clip,
                                ))
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Codigo Postal: ',
                                  style: TextStyle(fontFamily: 'Poppins Bold'),
                                ),
                                Flexible(
                                    child: Text(
                                  provider['postal'] != '{@nil=true}'
                                      ? provider['postal'].toString()
                                      : '',
                                  style: const TextStyle(
                                      fontFamily: 'Poppins Regular'),
                                  overflow: TextOverflow.clip,
                                ))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenMax * 0.1,
                  ),
                  Container(
                    width: screenMax,
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
                        // Aquí puedes manejar la acción de agregar orden
                        // Por ejemplo, puedes navegar a una pantalla de agregar orden

                        print('estos son los proveedores $provider');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OrdenDeCompraScreen(
                                  providerId: provider["id"],
                                  providerName: provider["bpname"],
                                  cBPartnerID: provider['c_bpartner_id'],
                                  cBPartnerLocationId:
                                      provider['c_bpartner_location_id'] !=
                                              '{@nil=true}'
                                          ? provider['c_bpartner_location_id']
                                          : 0,
                                  rucProvider: provider['tax_id'],
                                  emailProvider:
                                      provider['email'].toString().contains("@")
                                          ? provider['email']
                                          : "",
                                  phoneProvider: provider['phone'].toString())),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: const WidgetStatePropertyAll<Color>(
                            Color(0xFFA5F52B)),
                        foregroundColor:
                            const WidgetStatePropertyAll<Color>(Colors.black),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                15), // Aquí establece el radio de borde
                          ),
                        ),
                      ),
                      child: const Text(
                        'Agregar Orden',
                        style:
                            TextStyle(fontFamily: 'Poppins Bold', fontSize: 15),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenMax * 0.02,
                  ),
                  Container(
                    width: screenMax,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        // Aquí puedes manejar la acción de agregar orden
                        // Por ejemplo, puedes navegar a una pantalla de agregar orden

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EditProviderScreen(provider: provider)),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: const WidgetStatePropertyAll<Color>(
                            Color(0xFF7531FF)),
                        foregroundColor:
                            const WidgetStatePropertyAll<Color>(Colors.white),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                15), // Aquí establece el radio de borde
                          ),
                        ),
                      ),
                      child: const Text(
                        'Editar',
                        style:
                            TextStyle(fontFamily: 'Poppins Bold', fontSize: 15),
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

  Widget _buildTextFormField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
      ),
    );
  }
}
