import 'package:flutter/material.dart';
import 'package:image_card/image_card.dart';
import 'package:flip_card/flip_card.dart';

class FlipCardGrid extends StatelessWidget {
  const FlipCardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          buildScrollableRowOfCards(),
          SizedBox(height: 20),
          buildScrollableRowOfCards(),
        ],
      ),
    );
  }

  Widget buildScrollableRowOfCards() {
    final ScrollController _scrollController = ScrollController();

    return SizedBox(
      height: 240,
      child: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(6, (index) => buildFlipCard()),
            ),
          ),
          // Flecha izquierda
          Positioned(
            left: 10,
            top: 100,
            child: GestureDetector(
              onTap: () {
                _scrollController.animateTo(
                  _scrollController.offset - 200,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedOpacity(
                opacity: _scrollController.hasClients && _scrollController.offset > 0 ? 1.0 : 0.4,
                duration: Duration(milliseconds: 200),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.blue,
                  size: 28,
                ),
              ),
            ),
          ),
          // Flecha derecha
          Positioned(
            right: 10,
            top: 100,
            child: GestureDetector(
              onTap: () {
                _scrollController.animateTo(
                  _scrollController.offset + 200,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedOpacity(
                opacity: _scrollController.hasClients &&
                        _scrollController.offset < _scrollController.position.maxScrollExtent
                    ? 1.0
                    : 0.4,
                duration: Duration(milliseconds: 200),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.blue,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFlipCard() {
    final GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: FlipCard(
        key: cardKey,
        flipOnTouch: false,
        direction: FlipDirection.HORIZONTAL,
        front: SizedBox(
          width: 160, // Más ancho
          child: FillImageCard(
            width: 160,
            heightImage: 180, // Imagen más grande
            imageProvider: NetworkImage('https://via.placeholder.com/300x180'),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Imagen",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            footer: TextButton(
              onPressed: () {
                cardKey.currentState?.toggleCard();
              },
              child: Text("Ver detalles", style: TextStyle(fontSize: 14)),
            ),
          ),
        ),
        back: GestureDetector(
          onTap: () {
            cardKey.currentState?.toggleCard();
          },
          child: Container(
            width: 160,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Se ha realizado con éxito\n(Toca para volver)",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
