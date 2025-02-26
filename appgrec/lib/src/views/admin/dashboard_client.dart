import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:appgrec/src/widgets/custom_snackbar.dart';

class DashboardAdminClientScreen extends StatefulWidget {
  const DashboardAdminClientScreen({super.key});

  @override
  State<DashboardAdminClientScreen> createState() => DashboardAdminClientState();
}

class DashboardAdminClientState extends State<DashboardAdminClientScreen> {
  List<String> imageUrls = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  /// Verifica y solicita permisos de almacenamiento en función de la versión de Android
  Future<bool> _requestPermissions() async {
    PermissionStatus status;

    if (await Permission.photos.isGranted) return true; // Para Android 13+
    if (await Permission.storage.isGranted) return true; // Para Android 12 o menor

    // Solicita el permiso según la versión de Android
    if (await Permission.photos.isDenied || await Permission.storage.isDenied) {
      status = await Permission.photos.request(); // Android 13+
      if (status.isDenied) status = await Permission.storage.request(); // Android 12 o menor
    } else {
      status = PermissionStatus.denied;
    }

    if (status.isGranted) return true;

    // Si el usuario ha denegado permanentemente el permiso, mostrar Snackbar con opción de configuración
    if (status.isPermanentlyDenied) {
      _showPermissionSnackbar();
    }

    return false;
  }

  /// Muestra un mensaje para abrir la configuración si el permiso está denegado permanentemente
  void _showPermissionSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Permiso requerido para imágenes.'),
        action: SnackBarAction(
          label: 'Abrir Configuración',
          onPressed: () {
            openAppSettings();
          },
        ),
      ),
    );
  }

  /// Obtiene las imágenes del carrusel desde la API
  Future<void> _fetchImages() async {
    final url = '${dotenv.env['FRONTEND_URL']}/api/carousel/all';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> images = json.decode(response.body);
        setState(() {
          imageUrls = images.map((img) => img['url_carousel_image'] as String).toList();
        });
      } else {
        CustomSnackbar.showSnackBar(context, 'Error al cargar imágenes');
      }
    } catch (e) {
      CustomSnackbar.showSnackBar(context, 'Error de conexión');
    }
  }

  /// Selecciona y sube una imagen al servidor
  Future<void> _pickAndUploadImage() async {
    bool hasPermission = await _requestPermissions();
    if (!hasPermission) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile == null) return; // Si el usuario cancela la selección

    setState(() => isLoading = true);

    File imageFile = File(pickedFile.path);
    String uploadUrl = '${dotenv.env['FRONTEND_URL']}/api/carousel/create';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var response = await request.send();
      if (response.statusCode == 201) {
        await _fetchImages();
        CustomSnackbar.showSnackBar(context, 'Imagen subida correctamente', backgroundColor: Colors.green);
      } else {
        CustomSnackbar.showSnackBar(context, 'Error al subir la imagen');
      }
    } catch (e) {
      CustomSnackbar.showSnackBar(context, 'Error de conexión');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administración de Carrusel'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: isLoading ? null : _pickAndUploadImage,
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: imageUrls.length,
            itemBuilder: (context, index) => ListTile(
              title: Text('Imagen $index'),
              subtitle: Text('Descripción de la imagen'),
            ),
          ),
          if (isLoading)
            Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
