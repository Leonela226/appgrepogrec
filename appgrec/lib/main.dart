import 'package:appgrec/src/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:appgrec/src/providers/auth.dart'; // Asegúrate de importar el proveedor
import 'package:provider/provider.dart'; // Importa provider para usar ChangeNotifierProvider

void main() async {
  // Asegura que se inicialicen los widgets antes de comenzar
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Inicializa Firebase
  await Firebase.initializeApp();

  // Elimina la pantalla de carga después de la inicialización
  FlutterNativeSplash.remove();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(), // Aquí se agrega el proveedor
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/register',  // Establece la ruta inicial a la pantalla de registro
        routes: appRoutes,
      ),
    );
  }
}
