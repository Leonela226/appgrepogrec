import 'dart:convert';
import 'dart:async';
import 'package:appgrec/src/widgets/custom_snackbar.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CustomRoulette extends StatefulWidget {
  final String codeGiveaway;

  const CustomRoulette({super.key, required this.codeGiveaway});

  @override
  CustomRouletteState createState() => CustomRouletteState();
}

class CustomRouletteState extends State<CustomRoulette> {
  late ScrollController _controller;
  late ConfettiController _confettiController;
  Timer? _timer;
  bool _isSpinning = false;
  int winnerIndex = 0;
  List<String> participants = [];

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));

    String? baseUrl = dotenv.env['FRONTEND_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Error: FRONTEND_URL no está definida.');
      }
      return;
    }

    fetchParticipants(baseUrl, widget.codeGiveaway);
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> fetchParticipants(String baseUrl, String codeGiveaway) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/participationPrize/roulette'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'code_giveaway': widget.codeGiveaway}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['participants'] == null || data['participants'].isEmpty) {
          print("No hay participantes disponibles.");
        }

        setState(() {
          participants = List<String>.from(data['participants']);
        });
      } else {
        throw Exception('Failed to load participants');
      }
    } catch (e) {
      CustomSnackbar.showError(context, 'Error al obtener los participantes.');
    }
  }

  void _startTombola() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
    });

    int index = 0;
    double speedFactor = 1.0;  // Factor de velocidad (1 es velocidad normal)
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      index = (index + 1) % participants.length;

      // Aumentar la velocidad al principio y desacelerar al final
      if (index < participants.length / 2) {
        speedFactor = 1.0;  // Rápido al principio
      } else {
        speedFactor = 0.5;  // Desacelerar al acercarse al final
      }

      _controller.animateTo(
        index * 220.0,
        duration: Duration(milliseconds: (50 / speedFactor).toInt()),  // Cambiar la duración según la velocidad
        curve: Curves.easeOut,  // Desacelerar al final
      );

      if (index == participants.length - 1) {
        _timer?.cancel();
        setState(() {
          _isSpinning = false;
          winnerIndex = index;
        });

        _confettiController.play();

        Future.delayed(const Duration(milliseconds: 300), () {
          showDialog(
            context: context,
            builder: (context) => Stack(
              children: [
                AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Text('¡Felicidades!'),
                  content: Text('El ganador es: ${participants[winnerIndex]}'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _confettiController.stop();
                      },
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
                ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: true,
                  numberOfParticles: 250,
                  gravity: 0.4,
                  colors: [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.purple],
                  maxBlastForce: 20,
                  minBlastForce: 10,
                  blastDirection: 2.0,
                ),
              ],
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Contenedor horizontal para la tómbola
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 10, spreadRadius: 5),
            ],
          ),
          child: ListView.builder(
            controller: _controller,
            itemCount: participants.length,
            scrollDirection: Axis.horizontal,  // Cambio para mostrar la tómbola horizontal
            itemBuilder: (context, index) {
              return Container(
                width: 150,  // Establece el tamaño del item horizontalmente
                margin: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 186, 196, 212),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 6, spreadRadius: 1),
                  ],
                ),
                child: Center(
                  child: Text(
                    participants[index],
                    style: const TextStyle(
                      color: Colors.black,
                      fontFamily: 'TitilliumWeb',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        
        // Botón debajo de la tómbola
        ElevatedButton(
          onPressed: _startTombola,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF434244),
            textStyle: const TextStyle(
              fontFamily: 'TitilliumWeb',
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18),
          ),
          child: const Text(
            'Iniciar Sorteo',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
