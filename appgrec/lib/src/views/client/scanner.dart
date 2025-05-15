import 'dart:convert';
import 'package:appgrec/src/widgets/custom_appbar.dart';
import 'package:appgrec/src/widgets/custom_bottom_nav_bar.dart';
import 'package:appgrec/src/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientQRScanScreen extends StatefulWidget {
  const ClientQRScanScreen({super.key});

  @override
  State<ClientQRScanScreen> createState() => _ClientQRScanScreenState();
}

class _ClientQRScanScreenState extends State<ClientQRScanScreen> {
  final MobileScannerController _cameraController = MobileScannerController();
  bool _hasScanned = false;

  late final String? baseUrl;

  @override
  void initState() {
    super.initState();
    baseUrl = dotenv.env['FRONTEND_URL'];
  }

  Future<int?> _getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_user');
  }

  Future<int?> _registerCode(String qrCode) async {
    if (baseUrl == null || baseUrl!.isEmpty) {
      if (mounted) {
        CustomSnackbar.showError(context, 'FRONTEND_URL no está definida');
      }
      return null;
    }

    final url = Uri.parse('$baseUrl/api/scanner/create');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'qr_code_value': qrCode}),
      );


      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        final idCodesQR = data['data']['id_codes_qr'];
        return idCodesQR;
      } else {
        final errorMessage = data['message'] ?? 'Error desconocido';
        final errorType = data['error']?.toString().toLowerCase() ?? '';

        if (mounted) {
          if (errorType.contains('validation') || response.statusCode == 409) {
            CustomSnackbar.showWarning(context, 'Este código ya fue registrado.');
          } else {
            CustomSnackbar.showError(context, 'Error: $errorMessage');
          }
        }
      }
    } catch (e) {

      if (mounted) {
        CustomSnackbar.showError(context, 'Error de red: $e');
      }
    }

    return null;
  }

  Future<void> _registerParticipation(int idUser, int idCodesQR) async {
    if (baseUrl == null || baseUrl!.isEmpty) {
      if (mounted) {
        CustomSnackbar.showError(context, 'FRONTEND_URL no está definida');
      }
      return;
    }

    final url = Uri.parse('$baseUrl/api/participation/create');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_user': idUser,
          'id_codes_qr': idCodesQR,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        if (mounted) {
          CustomSnackbar.showSuccess(context, '¡Participación registrada exitosamente!');
        }
      } else {
        final errorMessage = data['message'] ?? 'Error desconocido';

        if (mounted) {
          if (response.statusCode == 409) {
            CustomSnackbar.showWarning(context, 'Ya participaste con este código.');
          } else {
            CustomSnackbar.showError(context, 'Error: $errorMessage');
          }
        }
      }
    } catch (e) {

      if (mounted) {
        CustomSnackbar.showError(context, 'Error al registrar participación: $e');
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

                  final idCodesQR = await _registerCode(qrCode);

                  if (idCodesQR != null) {
                    final idUser = await _getUserIdFromPrefs();
                    if (idUser != null) {
                      await _registerParticipation(idUser, idCodesQR);
                    } else {
                      if (mounted) {
                        CustomSnackbar.showError(context, 'No se pudo obtener el ID del usuario.');
                      }
                    }
                  }

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
          Positioned(
            top: 50,
            left: 10,
            child: FloatingActionButton(
              onPressed: () => _cameraController.toggleTorch(),
              backgroundColor: Colors.black,
              child: const Icon(Icons.flash_on, color: Colors.white),
            ),
          ),
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
