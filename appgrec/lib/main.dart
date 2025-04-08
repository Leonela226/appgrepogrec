import 'package:appgrec/src/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:appgrec/src/providers/auth.dart'; // Importa el proveedor de autenticación
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importa dotenv
import 'package:provider/provider.dart';

void main() async {
  // Asegura que Flutter está inicializado antes de ejecutar cualquier otro código
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");

  // Mantener la pantalla de carga hasta que todo esté listo
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Inicializar Firebase con manejo de errores
  try {
  await Firebase.initializeApp();
  debugPrint("🔥 Firebase inicializado correctamente");
  } catch (e) {
  debugPrint("❌ Error al inicializar Firebase: $e");
  }

  // Eliminar la pantalla de carga una vez que todo esté listo
  FlutterNativeSplash.remove();

  // Ejecutar la aplicación Flutter
  runApp(const MyApp()); // Aquí pasas el widget MyApp como constante
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(), // Inicializa el proveedor de autenticación
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/welcome', // Ruta inicial
        routes: appRoutes,
        builder: (context, child) {
          // Inicializar ScreenUtil aquí para evitar problemas con MediaQuery
          ScreenUtil.init(context, designSize: const Size(375, 812));
          return child!; // Asegúrate de que child no sea nulo
        },
      ),
    );
  }
}
