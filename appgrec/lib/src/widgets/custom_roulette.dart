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
  List<Map<String, dynamic>> participants = [];
  List<Map<String, dynamic>> prizes = [];

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
        body: json.encode({'code_giveaway': codeGiveaway}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          participants = List<Map<String, dynamic>>.from(data['participants']);
          prizes = List<Map<String, dynamic>>.from(data['prizes']);
        });
      } else {
        throw Exception('Error al cargar participantes');
      }
    } catch (e) {
      CustomSnackbar.showError(context, 'Error al obtener los participantes.');
    }
  }

  void _startTombola() {
    if (_isSpinning) return;

    if (participants.isEmpty) {
      CustomSnackbar.showError(context, 'No quedan participantes disponibles.');
      return;
    }

    if (prizes.isEmpty) {
      CustomSnackbar.showError(context, 'No quedan premios disponibles.');
      return;
    }

    setState(() {
      _isSpinning = true;
    });

    int index = 0;
    double speedFactor = 1.0;
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      index = (index + 1) % participants.length;

      if (index < participants.length / 2) {
        speedFactor = 1.0;
      } else {
        speedFactor = 0.5;
      }

      _controller.animateTo(
        index * 220.0,
        duration: Duration(milliseconds: (50 / speedFactor).toInt()),
        curve: Curves.easeOut,
      );
    });

    Future.delayed(const Duration(seconds: 5), () {
      _timer?.cancel();

      setState(() {
        _isSpinning = false;
        winnerIndex = index % participants.length;
      });

      _confettiController.play();

      Future.delayed(const Duration(milliseconds: 300), () {
        Map<String, dynamic>? selectedPrize;
        if (prizes.isNotEmpty) {
          selectedPrize = prizes.removeAt(0);
        }

        final winningEmail = participants[winnerIndex]['realEmail'];
        final winnerName = participants[winnerIndex]['nameUser']; // Nombre del ganador

        showDialog(
          context: context,
          builder: (context) => Stack(
            children: [
              AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Text('¡Felicidades!'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('El ganador es: $winnerName (${participants[winnerIndex]['censoredEmail']})'),
                    if (selectedPrize != null) ...[
                      const SizedBox(height: 10),
                      Text('Premio: ${selectedPrize['namePrize']}'),
                      Text('Lugar: ${selectedPrize['rank']}'),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _confettiController.stop();

                      // Eliminar todas las participaciones del ganador
                      setState(() {
                        participants.removeWhere((participant) => participant['realEmail'] == winningEmail);
                      });

                      // Verificar si ya no hay premios o participantes
                      if (prizes.isEmpty) {
                        CustomSnackbar.showSuccess(context, 'Todos los premios han sido asignados.');
                      }
                      if (participants.isEmpty) {
                        CustomSnackbar.showSuccess(context, 'Todos los participantes han sido premiados.');
                      }
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Container(
                width: 150,
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
                    participants[index]['censoredEmail'],
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
        ElevatedButton(
          onPressed: _startTombola,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF434244),
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
