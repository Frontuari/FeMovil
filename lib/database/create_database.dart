import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  Future<void> deleteDatabases() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = path.join(databasesPath, 'femovil.db');

    // Elimina la base de datos si existe
    await deleteDatabase(dbPath);
    print('Base de datos eliminada');

    // Llama al método _initDatabase para crear la base de datos con la nueva estructura
    await _initDatabase();
    print('Base de datos creada nuevamente');
  }

  initDatabase() async {
    // Obtener la ruta del directorio donde se almacenará la base de datos
    String databasesPath = await getDatabasesPath();
    String dbpath = path.join(databasesPath, 'femovil.db');

    // Verificar si la base de datos ya existe
    bool exists = await databaseExists(dbpath);

    if (exists) {
      print("base de datos si existe");
    } else {
      print("base de datos creada");
      await _initDatabase();
    }
  }

  Future<Database> _initDatabase() async {
    print("Entré aquí en init database");
    String databasesPath = await getDatabasesPath();
    String dbPath = path.join(databasesPath, 'femovil.db');
    // Abre la base de datos o crea una nueva si no existe
    Database database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {

         await db.execute('''
          CREATE TABLE ciiu(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cod_ciiu INTEGER,
            lco_isic_id INTEGER,
            name STRING
          )
        ''');

        await db.execute('''
          CREATE TABLE products(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cod_product INTEGER,
            m_product_id INTEGER,
            name TEXT,
            quantity INTEGER,
            price REAL,
            product_type STRING,
            product_type_name STRING,
            pro_cat_id INTEGER,
            categoria TEXT,
            tax_cat_id INTEGER,
            tax_cat_name STRING,
            product_group_id INTEGER,
            product_group_name STRING,
            um_id INTEGER,
            um_name STRING,
            quantity_sold INTEGER,
            pricelistsales INTEGER,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(tax_cat_id) REFERENCES tax(id)


          )
        ''');

        await db.execute('''
        CREATE TABLE clients(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            c_bpartner_id INTEGER,
            cod_client INTEGER,
            bp_name TEXT,
            c_bp_group_id INTEGER,
            group_bp_name STRING,
            lco_tax_id_typeid INTEGER,
            tax_id_type_name STRING,
            email STRING,
            c_bpartner_location_id INTEGER,
            is_bill_to STRING,
            phone STRING,
            c_location_id INTEGER,
            city STRING,
            region STRING,
            country STRING,
            code_postal INTEGER,
            c_city_id INTEGER,
            c_region_id INTEGER,
            c_country_id INTEGER,
            ruc TEXT,
            address STRING,
            lco_tax_payer_typeid INTEGER,
            tax_payer_type_name STRING,
            lve_person_type_id INTEGER,
            person_type_name STRING,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

        )

    ''');

        await db.execute('''

        CREATE TABLE providers(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            c_bpartner_id INTEGER,
            c_code_id INTEGER,
            bpname TEXT,
            email STRING,
            c_bp_group_id INTEGER,
            groupbpname STRING,
            tax_id TEXT,
            is_vendor STRING,
            lco_tax_id_type_id INTEGER,
            tax_id_type_name STRING,
            c_bpartner_location_id INTEGER,
            is_bill_to STRING,
            phone STRING,
            c_location_id INTEGER,
            address STRING,
            city STRING,
            ciiu_id INTEGER,
            ciiu_tagname STRING,
            province STRING,
            country_name STRING,
            postal STRING,
            c_city_id INTEGER,
            c_country_id INTEGER,
            lco_taxt_payer_type_id INTEGER, 
            tax_payer_type_name STRING, 
            lve_person_type_id INTEGER,
            person_type_name STRING

        )

    ''');

        await db.execute('''
          CREATE TABLE orden_venta (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          c_doctypetarget_id INTEGER,
          ad_client_id INTEGER,
          ad_org_id INTEGER,
          m_warehouse_id INTEGER,
          documentno INTEGER,
          c_order_id INTEGER,
          paymentrule INTEGER,
          date_ordered TEXT,
          salesrep_id INTEGER,
          c_bpartner_id INTEGER,
          c_bpartner_location_id INTEGER,
          fecha TEXT,
          descripcion TEXT,
          id_factura TEXT,
          documentno_factura TEXT,
          saldo_exento REAL,
          saldo_impuesto REAL,
          monto REAL,
          saldo_neto REAL,
          usuario_id INTEGER,
          cliente_id INTEGER,
          status_sincronized STRING,
          FOREIGN KEY (cliente_id) REFERENCES clients(id),
          FOREIGN KEY (usuario_id) REFERENCES usuarios(ad_user_id)

        )
      ''');

        await db.execute('''

        CREATE TABLE orden_venta_lines (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            orden_venta_id INTEGER,
            producto_id INTEGER,
            ad_client_id INTEGER,
            ad_org_id INTEGER,
            price_entered INTEGER,
            price_actual INTEGER,
            m_product_id INTEGER,
            qty_entered INTEGER,
            FOREIGN KEY (orden_venta_id) REFERENCES orden_venta(id),
            FOREIGN KEY (producto_id) REFERENCES products(id)
        )

      ''');

        await db.execute('''
          CREATE TABLE orden_compra (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          proveedor_id INTEGER,
          documentno TEXT,
          c_doc_type_target_id INTEGER, 
          ad_client_id INTEGER,
          ad_org_id INTEGER,
          m_warehouse_id INTEGER,
          payment_rule STRING, 
          c_order_id INTEGER,
          dateordered STRING,
          sales_rep_id INTEGER,
          c_bpartner_id INTEGER,
          c_bpartner_location_id INTEGER,
          m_price_list_id INTEGER, 
          c_currency_id INTEGER,
          c_payment_term_id INTEGER,
          c_conversion_type_id INTEGER,
          po_reference STRING,
          description STRING,
          saldo_exento REAL,
          saldo_impuesto REAL,
          id_factura INTEGER,
          fecha TEXT,
          monto REAL,
          saldo_neto REAL,
          usuario_id INTEGER,
          status_sincronized,
          FOREIGN KEY (proveedor_id) REFERENCES providers(id),
          FOREIGN KEY (usuario_id) REFERENCES usuarios(ad_user_id)

        )
      ''');

        await db.execute('''

        CREATE TABLE orden_compra_lines (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            orden_compra_id INTEGER,
            ad_client_id INTEGER,
            ad_org_id INTEGER,
            price_entered REAL,
            price_actual REAL,
            m_product_id INTEGER,
            qty_entered REAL,
            producto_id INTEGER,
            FOREIGN KEY (orden_compra_id) REFERENCES orden_compra(id),
            FOREIGN KEY (producto_id) REFERENCES products(id)
        )

      ''');

        await db.execute('''
          CREATE TABLE cobros(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            c_bankaccount_id INTEGER,
            c_bankaccount_name STRING,
            c_doctype_id INTEGER,
            date_trx TEXT,
            description TEXT,
            c_bpartner_id INTEGER,
            pay_amt REAL,
            date TEXT,
            c_currency_id INTEGER,
            c_currency_iso STRING,
            c_order_id INTEGER,
            c_invoice_id INTEGER,
            documentno INTEGER,
            tender_type STRING,
            tender_type_name STRING,
            sale_order_id INTEGER,
            FOREIGN KEY (sale_order_id) REFERENCES orden_venta(id)
            
          )
        ''');

        await db.execute('''
          CREATE TABLE f_retenciones(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            ad_client_id INTEGER,
            ad_org_id TEXT,
            c_bpartner_id TEXT,
            c_bpartner_location_id TEXT,
            c_currency_id INTEGER, 
            c_doctypetarget_id INTEGER, 
            c_paymentterm_id INTEGER,
            description TEXT,
            documentno TEXT,
            is_sotrx TEXT,
            m_pricelist_id INTEGER,
            payment_rule STRING,
            date_invoiced TEXT,
            date_acct TEXT, 
            sales_rep_id INTEGER,
            sri_authorization_code TEXT,
            ing_establishment INTEGER, 
            ing_emission INTEGER, 
            ing_sequence INTEGER,
            ing_taxsustance TEXT,
            provider_id INTEGER,
            date TEXT,
            monto REAL,
            FOREIGN KEY (provider_id) REFERENCES providers(id)


            )

        ''');

           await db.execute('''

        CREATE TABLE f_retencion_lines (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            f_retencion_id INTEGER,
            ad_client_id INTEGER,
            ad_org_id INTEGER,
            price_entered REAL,
            price_actual REAL,
            m_product_id INTEGER,
            qty_entered REAL,
            producto_id INTEGER,
            FOREIGN KEY (f_retencion_id) REFERENCES f_retenciones(id),
            FOREIGN KEY (producto_id) REFERENCES products(id)
        )

      ''');

         await db.execute('''

          CREATE TABLE payment_term_fr(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            c_paymentterm_id INTEGER,
            name TEXT
            )
            
        ''');

        await db.execute('''
          CREATE TABLE usuarios(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            name TEXT,
            password INTEGER,
            ad_user_id TEXT,
            email TEXT,
            phone TEXT
            )
        ''');

        await db.execute('''
          CREATE TABLE posproperties(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            country_id INTEGER,
            tax_payer_type_natural INTEGER,
            tax_payer_type_juridic INTEGER,
            person_type_juridic INTEGER,
            person_type_natural INTEGER,
            m_warehouse_id INTEGER,
            c_doc_type_order_id INTEGER,
            c_conversion_type_id INTEGER,
            c_paymentterm_id INTEGER,
            c_bankaccount_id INTEGER,
            c_bpartner_id INTEGER,
            c_doctypepayment_id INTEGER,
            c_doctypereceipt_id INTEGER,
            city STRING,
            address1 STRING, 
            m_pricelist_id INTEGER,
            m_price_saleslist_id INTEGER,
            c_currency_id INTEGER,
            c_doc_type_order_co INTEGER,
            doc_status_receipt STRING,
            doc_status_invoice_so STRING,
            doc_status_order_so STRING,
            doc_status_order_po STRING,
            c_doc_type_target_fr INTEGER,
            orden_compra_id INTEGER
            )
        ''');

        await db.execute('''
          CREATE TABLE tax(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          c_tax_id INTEGER,
          tax_indicator STRING,
          rate REAL,
          name TEXT,
          c_tax_category_id INTEGER,
          iswithholding TEXT
          )
        ''');


           await db.execute('''
          CREATE TABLE bank_account_app(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          c_bank_id INTEGER,
          bank_name STRING,
          routing_no TEXT,
          c_bank_account_id INTEGER,
          account_no TEXT,
          c_currency_id INTEGER,
          iso_code STRING
          )
        ''');



      },
    );

    return database;
  }
}
