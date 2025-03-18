import 'package:flutter/material.dart';
import 'package:image_card/image_card.dart';
import 'package:flip_card/flip_card.dart';

class FlipCardGrid extends StatelessWidget {
  final int totalCards = 12; // Número total de tarjetas
  final int cardsPerRow = 4; // Tarjetas por fila

  const FlipCardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    int rowCount = (totalCards / cardsPerRow).ceil(); // Calcula la cantidad de filas necesarias

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(  // Aquí añadimos el SingleChildScrollView para permitir el desplazamiento vertical
        child: Column(
          children: List.generate(rowCount, (rowIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 35),
              child: buildScrollableRowOfCards(context, rowIndex),
            );
          }),
        ),
      ),
    );
  }

  Widget buildScrollableRowOfCards(BuildContext context, int rowIndex) {
    final ScrollController scrollController = ScrollController();
    double cardWidth = MediaQuery.of(context).size.width * 0.4;
    double cardHeight = cardWidth * 1.8;

    return SizedBox(
      height: cardHeight,
      child: Stack(
        children: [
          SingleChildScrollView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(cardsPerRow, (index) {
                int cardIndex = rowIndex * cardsPerRow + index;
                if (cardIndex < totalCards) {
                  return buildFlipCard(context);
                }
                return SizedBox(); // Espacio vacío si hay menos de 12 tarjetas
              }),
            ),
          ),
          Positioned(
            left: 10,
            top: cardHeight / 2 - 14,
            child: GestureDetector(
              onTap: () {
                scrollController.animateTo(
                  scrollController.offset - 200,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.blue,
                size: 28,
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: cardHeight / 2 - 14,
            child: GestureDetector(
              onTap: () {
                scrollController.animateTo(
                  scrollController.offset + 200,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.blue,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFlipCard(BuildContext context) {
    final GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
    double cardWidth = MediaQuery.of(context).size.width * 0.4;
    double cardHeight = cardWidth * 1.4;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: FlipCard(
        key: cardKey,
        flipOnTouch: false,
        direction: FlipDirection.HORIZONTAL,
        front: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Stack(
            children: [
              FillImageCard(
                width: cardWidth,
                heightImage: cardHeight * 0.8,
                imageProvider: NetworkImage('https://via.placeholder.com/300x180'),
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Imagen",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: ElevatedButton(
                  onPressed: () {
                    cardKey.currentState?.toggleCard();
                    Future.delayed(Duration(seconds: 45), () {
                      if (cardKey.currentState?.isFront == false) {
                        cardKey.currentState?.toggleCard();
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    backgroundColor: Color(0xFF434244),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Ver detalle",
                    style: TextStyle(
                      fontFamily: 'TitilliumWeb',
                      fontWeight: FontWeight.w600,
                      fontSize: MediaQuery.of(context).size.width * 0.03,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        back: GestureDetector(
          onTap: () {
            cardKey.currentState?.toggleCard();
          },
          child: Container(
            width: cardWidth,
            height: cardHeight,
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
