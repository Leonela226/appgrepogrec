import 'package:appgrec/src/widgets/custom_appbar.dart';
import 'package:appgrec/src/widgets/custom_drawer.dart';
import 'package:appgrec/src/widgets/custom_roulette.dart';
import 'package:flutter/material.dart';

class RouletteScreen extends StatefulWidget {

  const RouletteScreen({super.key});

  @override
  State<RouletteScreen> createState() => RouletteScreenState();
}

class RouletteScreenState extends State<RouletteScreen> {
   late String codeGiveaway;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Recuperamos el `code_giveaway` pasado como argumento
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      codeGiveaway = args;  
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Título y icono
            SizedBox(height: 20),  
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.casino, size: 30, color: Color(0xFFFF0000),),  
                SizedBox(width: 8),  
                Text(
                  '¡Momento del Sorteo!',
                  style: TextStyle(
                    fontSize: 26,
                    fontFamily: 'TitilliumWeb',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF0000),
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),  
            // La ruleta de participantes
            CustomRoulette( codeGiveaway: codeGiveaway ),
          ],
        ),
      ),
    );
  }
}
