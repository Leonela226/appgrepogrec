import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CustomCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const CustomCarousel({super.key, required this.imageUrls});

  @override
  CustomCarouselState createState() => CustomCarouselState();
}

class CustomCarouselState extends State<CustomCarousel> {
  int _currentIndex = 0; // Índice de la imagen actual

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double carouselHeight = screenHeight * 0.20; // 20% del alto de la pantalla

    // Verificar si la lista de imágenes está vacía
    bool isEmpty = widget.imageUrls.isEmpty;

    return Column(
      children: [
        const SizedBox(height: 20), // Espaciado antes del carrusel

        isEmpty
            ? SizedBox(
                height: carouselHeight,
                child: const Center(
                  child: Icon(Icons.broken_image, size: 55, color: Colors.grey),
                ),
              )
            : CarouselSlider(
                items: widget.imageUrls.map((imageUrl) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Sombra más sutil
                          blurRadius: 9, // Difuminado más suave
                          spreadRadius: 1, // Expansión ligera
                          offset: const Offset(0, 4), // Sombra baja ligeramente
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                              );
                            },
                          ),
                          // Gradiente para mejorar visibilidad sin afectar la sombra
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.center,
                                colors: [Colors.black26, Colors.transparent],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: carouselHeight,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  enlargeCenterPage: true,
                  viewportFraction: 0.8, // Permite ver parte de las imágenes laterales
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),

        const SizedBox(height: 20), // Espaciado después del carrusel

        if (!isEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.imageUrls.length, (index) {
              return Container(
                width: 6,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index ? const Color(0xFFFF0000) : const Color(0xFF434244),
                ),
              );
            }),
          ),
      ],
    );
  }
}
