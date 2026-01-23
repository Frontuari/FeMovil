import 'package:femovil/config/app_bar_femovil.dart';
import 'package:femovil/config/getOrgInfo.dart';
import 'package:femovil/config/getPosProperties.dart';
import 'package:femovil/database/create_database.dart';
import 'package:femovil/presentation/retenciones/idempiere/payment_terms_sincronization.dart';
import 'package:femovil/presentation/screen/home/home_screen.dart';
import 'package:femovil/sincronization/design_charger/striped_design.dart';
import 'package:femovil/sincronization/https/bank_account.dart';
import 'package:femovil/sincronization/https/ciuu_activities.dart';
import 'package:femovil/sincronization/https/customer_http.dart';
import 'package:femovil/sincronization/https/get_orginfo.dart';
import 'package:femovil/sincronization/https/impuesto_http.dart';
import 'package:femovil/sincronization/https/search_id_invoice.dart';
import 'package:femovil/sincronization/https/vendors_http.dart';
import 'package:femovil/sincronization/sincronizar_create.dart';
import 'package:femovil/utils/alerts_messages.dart';
import 'package:femovil/utils/snackbar_messages.dart';
import 'package:flutter/material.dart';
import 'package:femovil/sincronization/widgets/empty_database.dart';

double syncPercentage = 0.0; // Estado para mantener el porcentaje sincronizado
double syncPercentageClient = 0.0;
double syncPercentageProviders = 0.0;
double syncPercentageSelling = 0.0;
double syncPercentageImpuestos = 0.0;
double syncPercentageBankAccount = 0.0;
bool setearValoresEnCero = true;

class SynchronizationScreen extends StatefulWidget {
  const SynchronizationScreen({super.key});

  @override
  _SynchronizationScreenState createState() => _SynchronizationScreenState();
}

Future<void> _deleteBaseDatos() async {
  await DatabaseHelper.instance.deleteDatabases();
}

class _SynchronizationScreenState extends State<SynchronizationScreen> {
  GlobalKey<_SynchronizationScreenState> synchronizationScreenKey =
      GlobalKey<_SynchronizationScreenState>();
  bool _enableButtons = true;

  @override
  void initState() {
    //  _deleteBaseDatos();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: synchronizationScreenKey,
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(170),
          child: AppBars(labelText: 'Sincronización')),
      body: Column(
        children: [
          const SizedBox(height: 25),
         Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 3, // ¡Aquí definimos las 3 columnas!
          crossAxisSpacing: 10, // Espacio horizontal entre tarjetas
          mainAxisSpacing: 10, // Espacio vertical entre tarjetas
          childAspectRatio: 0.75, // Relación de aspecto (Alto vs Ancho) para que no se corte
          shrinkWrap: true, // Importante si está dentro de otro scroll
          physics: const NeverScrollableScrollPhysics(), // Para que no haga scroll interno
          children: [
            SyncStatusCard(
              title: 'Productos',
              percentage: syncPercentage,
              icon: Icons.inventory_2_outlined,
            ),
            SyncStatusCard(
              title: 'Clientes',
              percentage: syncPercentageClient,
              icon: Icons.people_alt_outlined,
            ),
            SyncStatusCard(
              title: 'Proveedores',
              percentage: syncPercentageProviders,
              icon: Icons.local_shipping_outlined,
            ),
            SyncStatusCard(
              title: 'Ventas',
              percentage: syncPercentageSelling,
              icon: Icons.point_of_sale_outlined,
            ),
            SyncStatusCard(
              title: 'Impuestos',
              percentage: syncPercentageImpuestos,
              icon: Icons.request_quote_outlined,
            ),
            SyncStatusCard(
              title: 'Bancos',
              percentage: syncPercentageBankAccount,
              icon: Icons.account_balance_outlined,
            ),
          ],
        ),
      ),
      
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 7,
                  spreadRadius: 1,
                )
              ]),
              child: ElevatedButton(
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all<double>(0),
                  foregroundColor: const MaterialStatePropertyAll(Colors.black),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide.none,
                    ),
                  ),
                ),
                onPressed: _enableButtons
                    ? () async {
                        setState(() {
                          _enableButtons = false;
                        });

                        if (!setearValoresEnCero) {
                          setState(() {
                            syncPercentage = 0;
                            syncPercentageClient = 0;
                            syncPercentageImpuestos = 0;
                            syncPercentageProviders = 0;
                            syncPercentageSelling = 0;
                            syncPercentageBankAccount = 0;
                            setearValoresEnCero = true;
                            totalProducts = 0;
                            currentSyncCount = 0;
                            syncedProducts = 0;
                          });
                        }

                        // 🔹 Solo este bloque tiene manejo de error con mensaje
                        try {
                          await getPosPropertiesInit();
                          final response = await getPosPropertiesV();

                          setState(() {
                            variablesG = response;
                          });
                        } catch (e) {
                          setState(() {
                            _enableButtons = true;
                            setearValoresEnCero = false;
                          });

                          ErrorMessage.showErrorMessageDialog(
                            context,
                            'Sin Conexión a Internet. La sincronización no se pudo completar.',
                          );
                          return; // ❗ Detener la operación aquí
                        }

                        // 🔹 El resto de sincronizaciones se ejecuta normalmente
                        sincronizationSearchIdInvoice(setState);
                        sincronizationCiuActivities(setState);
                        sincronizationBankAccount(setState);
                        sincronizationPaymentTerms();
                        sincronizationImpuestos(setState);
                        await sincronizationOrgInfo();
                        await sincronizationCustomers(setState); //Customer Actualizados,
                        await sincronizationVendors(setState); //Proveedores, Actualizado
                        //await synchronizeCustomersUpdateWithIdempiere(setState); Despreciado, explotaba mucho la API
                        //await synchronizeVendorsWithIdempiere(setState); Despreciado, explotaba mucho la API
                        await synchronizeProductsWithIdempiere(setState);
                        //await synchronizeProductsUpdateWithIdempiere(setState); Despreciado, explotaba mucho la API
                        await synchronizeOrderSalesWithIdempiere(setState);
                        await synchronizeTaxIdTypes();
                        await synchronizeTaxPayerTypes();
                        await synchronizeCountries();

                        showSuccesSnackbar(
                            context, 'Sincronización completada');

                        setState(() {
                          _enableButtons = true;
                          setearValoresEnCero = false;
                        });
                      }
                    : null,
                child: Text(
                  !_enableButtons ? 'Sincronizando...' : 'Sincronizar',
                  style: TextStyle(
                    fontFamily: 'Poppins Bold',
                    fontSize: 17,
                    color: _enableButtons
                        ? const Color(0XFF7531FF)
                        : const Color.fromARGB(255, 82, 78, 78),
                  ),
                ),
              ),
            ),
          ),
          EmptyDatabase(),
        ],
      ),
    );
  }
}
