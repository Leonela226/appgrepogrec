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
        // Espaciado entre texto y carrusel
        const SizedBox(height: 20),

        // Carrusel de imágenes o icono de imagen rota si no hay imágenes
        isEmpty
            ? SizedBox(
                height: carouselHeight,
                child: const Center(
                  child: Icon(Icons.broken_image, size: 55, color: Colors.grey),
                ),
              )
            : CarouselSlider(
                items: widget.imageUrls.map((imageUrl) {
                  print('Cargando imagen desde la URL: $imageUrl'); // Depuración para verificar la URL
                  return ClipRRect(
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
                            print('Error al cargar la imagen: $error'); // Depuración para errores
                            return const Center(
                              child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            );
                          },
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.center,
                              colors: [Colors.black38, Colors.transparent], // Reducción de opacidad
                            ),
                          ),
                        ),
                      ],
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

        // Espaciado entre carrusel e indicadores
        const SizedBox(height: 20),

        // Indicadores circulares (solo si hay imágenes)
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
                  color: _currentIndex == index ? Colors.blueAccent : Colors.grey,
                ),
              );
            }),
          ),
      ],
    );
  }
}
