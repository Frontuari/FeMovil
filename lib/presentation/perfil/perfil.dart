import 'package:femovil/config/banner_app.dart';
import 'package:femovil/database/gets_database.dart';
import 'package:femovil/sincronization/config/clear_db.dart';
import 'package:femovil/utils/alerts_messages.dart';
import 'package:femovil/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:femovil/assets/nav_bar_bottom.dart';
import 'package:femovil/config/fields_perfil.dart';
import 'package:femovil/infrastructure/models/info_perfil.dart';
import 'package:femovil/presentation/perfil/perfil_http.dart';
import 'package:femovil/presentation/screen/home/home_screen.dart';
import 'package:femovil/presentation/screen/login/login_success.dart';
import 'package:femovil/presentation/screen/login/progress_indicator.dart';

class Perfil extends StatefulWidget {
  const Perfil({Key? key}) : super(key: key);

  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  InfPerfil? perfilData;
  final authenticated = AuthenticationService();
  bool redirect = false;
  bool login = false;
  bool showErrorMes = false;
  bool? token;
  dynamic name;
  dynamic email;
  dynamic phone;
  dynamic adUserID;
  @override
  void initState() {
    super.initState();
    obtenerPerfilNEW();
    //obtenerPerfilLegacy();
  }

  Future<void> obtenerPerfilLegacy() async {
    final user = await getLogin();

    while (perfilData == null) {
      print('esto es usuario $user');
      final inf =
          await infoP(username: user['user'], password: user['password']);
      print('esto es informacion $inf');

      if (inf == 'hay problemas con el internet' && user['auth'] == true) {
        setState(() {
          showErrorMes = true;
        });
      }

      if (inf == 'hay problemas con el internet' && user['auth'] == false) {
        setState(() {
          login = true;
        });
      }

      if (user['auth'] == false) {
        setState(() {
          login = true;
        });
      }

      if (inf == "La URL está mal escrita." && user['auth'] == false) {
        setState(() {
          redirect = true;
        });
      }
      if (inf["Error"] == "Error login - User invalid" &&
          user['auth'] == false) {
        setState(() {
          login = true;
        });
      }
      setState(() {
        perfilData = inf != null ? InfPerfil.fromJsonMap(inf) : null;
      });
      await Future.delayed(const Duration(seconds: 1));
    }

    print("esto es perfilData ${perfilData}");
  }

  Future<void> obtenerPerfilNEW() async {
    dynamic userData = await getUserData();
    print('Data user $userData');

    setState(() {
      name = userData[0]['description'].toString().trim();
      email = userData[0]['email'].toString().trim();
      phone = userData[0]['phone'].toString().trim();
      adUserID = userData[0]['ad_user_id'].toString().trim();
    });

    print(' dATOS DEL USUARIO $userData');

    //print("esto es perfilData ${perfilData}");
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (redirect) {
      authenticated.logout();
      Future.delayed(Duration.zero, () {
        setState(() {
          redirect = false;
        });
        Navigator.pushReplacementNamed(context, '/configuracion');
      });
    } else if (login) {
      authenticated.logout();
      Future.delayed(Duration.zero).then((_) {
        setState(() {
          login = false;
        });
        Navigator.pushReplacementNamed(context, '/');
      });
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(170), // Altura del AppBar
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(50), // Radio del borde redondeado
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: Stack(
              children: [
                CustomPaint(
                  painter: CirclePainter(),
                ),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: 50), // Ajuste de la posición vertical
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Perfil',
                          style: TextStyle(
                            fontFamily: 'Poppins ExtraBold',
                            color: Colors.white,
                            fontSize: 30, // Tamaño del texto
                            shadows: <Shadow>[
                              Shadow(
                                offset: Offset(2, 2),
                                blurRadius: 3.0,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF7531FF), // Color hexadecimal
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(40.5),
              child: Container(
          
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                      15.0), // Ajusta el valor según sea necesario
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.1), // Color y opacidad de la sombra
                      blurRadius: 10, // Radio de difuminado de la sombra
                      offset: const Offset(0, 5), // Desplazamiento de la sombra
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Datos del Usuario',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 20),
                    buildPerfilRow(context, Icons.person, 'Nombre', name.toString()),
                    const SizedBox(height: 12),
                    buildPerfilRow(context, Icons.email, 'Email', email.toString()),
                    const SizedBox(height: 12),
                    buildPerfilRow(context, Icons.phone, 'Teléfono', phone.toString()),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                final currentContext = context;
                  final bool? shouldLogout = await showConfirmationDialog(
                    context: context,
                    title: '¿Desea cerrar sesión?',
                    content: 'Nota: Debera de Sincronizar Nuevamente',
                  );
                  if (shouldLogout == true) {
                   

                setState(() {
                  flag = true;
                  isSelected = true;
                  perfilIsSelected = false;
                  infoIsSelected = false;
                });

                authenticated.logout();

                    await clearDatabaseLogout();
                    await Navigator.pushNamedAndRemoveUntil(
                      currentContext,
                      '/',
                      (route) => false,
                    );
                  }
                },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/assets/Cerrar_Sesión.png',
                      width: 25,
                      height: 25,
                    ),
                    const SizedBox(
                        width:
                            5), // Espacio entre el icono y el texto (puedes eliminarlo si no lo necesitas
                    const Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        color: Color(
                            0xFFEC2641), // Puedes ajustar el color del texto según tus necesidades
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBarBottom(),
    );
  }
}
