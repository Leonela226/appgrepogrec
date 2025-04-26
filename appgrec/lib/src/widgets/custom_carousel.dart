import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CustomCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final Function(int) onDelete;
  final Function(int) onSelect;
  final int? selectedIndex;  // Agregar el parámetro selectedIndex

  const CustomCarousel({
    super.key, 
    required this.imageUrls, 
    required this.onDelete, 
    required this.onSelect,
    this.selectedIndex,  // Inicializar el parámetro
  });

  @override
  CustomCarouselState createState() => CustomCarouselState();
}

class CustomCarouselState extends State<CustomCarousel> {
  @override
  Widget build(BuildContext context) {
    // Usar screenWidth para la visualización dinámica del ancho
    //double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double carouselHeight = screenHeight * 0.20;

    bool isEmpty = widget.imageUrls.isEmpty;

    return Column(
      children: [
        const SizedBox(height: 20),
        isEmpty
            ? SizedBox(
                height: carouselHeight,
                child: const Center(
                  child: Icon(Icons.broken_image, size: 55, color: Colors.grey),
                ),
              )
            : CarouselSlider(
                items: widget.imageUrls.map((imageUrl) {
                  int index = widget.imageUrls.indexOf(imageUrl);
                  return GestureDetector(
                    onTap: () {
                      widget.onSelect(index); // Seleccionar la imagen
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.2),
                            blurRadius: 9,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: widget.selectedIndex == index 
                              ? Colors.blueAccent // Color del borde si está seleccionado
                              : Colors.transparent, // Sin borde si no está seleccionado
                          width: 3,
                        ),
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
                                return const Center(child: CircularProgressIndicator(
                                  color: Color(0xFF434244),
                                ));
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: carouselHeight,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  enlargeCenterPage: true, // Enfatiza la imagen central
                  viewportFraction: 0.75, // Muestra parcialmente las imágenes a los laterales
                ),
              ),
        const SizedBox(height: 20),
      ],
    );
  }
}
