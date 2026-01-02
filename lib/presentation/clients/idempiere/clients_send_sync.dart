import 'package:femovil/database/create_database.dart';
import 'package:femovil/database/gets_database.dart';
import 'package:femovil/database/update_database.dart';
import 'package:femovil/infrastructure/models/clients.dart';
import 'package:femovil/presentation/clients/idempiere/create_customer.dart';
import 'package:femovil/presentation/perfil/perfil_http.dart';
import 'package:femovil/utils/searck_key_idempiere.dart';

class ClientSyncService{
  /// 🔹 Sincroniza clientes no enviados a iDempiere
  Future<int> syncClients() async {
    final clientsNoSync = await getBPartnerNoSync();
    int syncedCount = 0;

    for (final item in clientsNoSync) {
      final customer = Customer(
        bpName: item['bp_name'],
        ruc: item['ruc'],
        address: item['address'],
        cBpGroupId: item['c_bp_group_id'],
        cBparnetLocationId: item['c_bpartner_location_id'],
        lcoTaxPayerTypeId: item['lco_tax_payer_typeid'],
        lvePersonTypeId: item['lve_person_type_id'],
        personTypeName: item['person_type_name'],
        taxPayerTypeName: item['tax_payer_type_name'],
        cCityId: item['c_city_id'],
        cCountryId: item['c_country_id'],
        cLocationId: item['c_location_id'],
        cRegionId: item['c_region_id'],
        cbPartnerId: item['c_bpartner_id'],
        codClient: item['cod_client'],
        codePostal: item['code_postal'],
        isBillTo: item['is_bill_to'],
        lcoTaxIdTypeId: item['lco_tax_id_typeid'],
        taxIdTypeName: item['tax_id_type_name'],
        email: item['email'],
        phone: item['phone'],
        cBpGroupName: item['group_bp_name'],
      );

      final response =
          await createCustomerIdempiere(customer.toMap());

      final cBPartnerId =
          findValueByColumn(response, 'C_BPartner_ID') ?? 0;
      final cLocationId =
          findValueByColumn(response, 'C_Location_ID') ?? 0;
      final cBPartnerLocationId =
          findValueByColumn(response, 'C_BPartner_Location_ID') ?? 0;

      if (cBPartnerId > 0 &&
          cLocationId > 0 &&
          cBPartnerLocationId > 0) {
        await updateClientAfterSync(
          localId: item['id'],
          cBPartnerId: cBPartnerId,
          cLocationId: cLocationId,
          cBPartnerLocationId: cBPartnerLocationId,
        );

        syncedCount++;
      }
    }

    return syncedCount;
  }
}
