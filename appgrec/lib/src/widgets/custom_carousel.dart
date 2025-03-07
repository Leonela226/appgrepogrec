import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Importamos el paquete carousel_slider

class CustomCarousel extends StatefulWidget {
  final List<String> imageUrls; // Lista de URLs de las imágenes

  const CustomCarousel({super.key, required this.imageUrls});

  @override
  _CustomCarouselState createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarousel> {
  int _currentPage = 0; // Variable para mantener el índice de la página actual

  @override
  Widget build(BuildContext context) {
    // Usamos MediaQuery para obtener el tamaño de la pantalla
    double screenHeight = MediaQuery.of(context).size.height;

    // Proporción de altura del carrusel, puedes ajustarlo a tu preferencia
    double carouselHeight = screenHeight * 0.3; // 30% de la altura de la pantalla

    return Column(
      children: [
        // Usamos CarouselSlider en lugar de PageView
        CarouselSlider.builder(
          itemCount: widget.imageUrls.length,
          itemBuilder: (BuildContext context, int index, int realIndex) {
            final imageUrl = widget.imageUrls[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Opacity(
                  opacity: 0.85,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover, // Hace que la imagen cubra completamente el área
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: carouselHeight,
            autoPlay: true, // Activamos el autoplay
            autoPlayInterval: Duration(seconds: 3), // Intervalo de tiempo entre cada cambio
            onPageChanged: (index, reason) {
              setState(() {
                _currentPage = index;
              });
            },
            viewportFraction: 1.0, // Muestra una imagen por vez
            enlargeCenterPage: true, // Aumenta ligeramente la imagen central
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.imageUrls.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index ? Colors.white : Colors.grey,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
