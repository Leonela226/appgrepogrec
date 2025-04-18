import 'dart:convert';
import 'package:appgrec/src/widgets/custom_appbar.dart';
import 'package:appgrec/src/widgets/custom_bottom_nav_bar.dart';
import 'package:appgrec/src/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';

class ClientQRScanScreen extends StatefulWidget {
  const ClientQRScanScreen({super.key});

  @override
  State<ClientQRScanScreen> createState() => _ClientQRScanScreenState();
}

class _ClientQRScanScreenState extends State<ClientQRScanScreen> {
  final MobileScannerController _cameraController = MobileScannerController();
  bool _hasScanned = false;

  Future<void> _registerCode(String qrCode) async {
    final String? baseUrl = dotenv.env['FRONTEND_URL'];

    if (baseUrl == null || baseUrl.isEmpty) {
      if (mounted) {
        CustomSnackbar.showError(context, 'FRONTEND_URL no está definida');
      }
      return;
    }

    final url = Uri.parse('$baseUrl/api/scanner/create');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'qr_code_value': qrCode}),
      );

      print('📦 Código de estado: ${response.statusCode}');
      print('📨 Respuesta del servidor: ${response.body}');

      if (response.statusCode == 201) {
        if (mounted) {
          CustomSnackbar.showSuccess(context, '¡Participación registrada exitosamente!');
        }
      } else {
        try {
          final data = json.decode(response.body);
          final errorMessage = data['message'] ?? 'Error desconocido';
          final errorType = data['error']?.toString().toLowerCase() ?? '';

          if (mounted) {
            if (errorType.contains('validation')) {
              CustomSnackbar.showWarning(context, 'Este código ya fue registrado.');
            } else {
              CustomSnackbar.showError(context, 'Error: $errorMessage');
            }
          }
        } catch (e) {
          print('⚠️ Error al decodificar JSON: $e');
          if (mounted) {
            CustomSnackbar.showError(context, 'Error inesperado. Respuesta: ${response.body}');
          }
        }
      }
    } catch (e) {
      print('🚨 Error de red: $e');
      if (mounted) {
        CustomSnackbar.showError(context, 'Error de red: $e');
      }
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: (BarcodeCapture capture) async {
              final List<Barcode> barcodes = capture.barcodes;

              for (final barcode in barcodes) {
                final qrCode = barcode.rawValue;

                if (!_hasScanned && qrCode != null) {
                  setState(() {
                    _hasScanned = true;
                  });

                  await _registerCode(qrCode);

                  await Future.delayed(const Duration(seconds: 3));

                  if (mounted) {
                    setState(() {
                      _hasScanned = false;
                    });
                  }

                  break;
                }
              }
            },
          ),
          // Botón para linterna
          Positioned(
            top: 50,
            left: 10,
            child: FloatingActionButton(
              onPressed: () => _cameraController.toggleTorch(),
              backgroundColor: Colors.black,
              child: const Icon(Icons.flash_on, color: Colors.white),
            ),
          ),
          // Botón para cambiar cámara
          Positioned(
            top: 50,
            right: 10,
            child: FloatingActionButton(
              onPressed: () => _cameraController.switchCamera(),
              backgroundColor: Colors.black,
              child: const Icon(Icons.cameraswitch, color: Colors.white),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
