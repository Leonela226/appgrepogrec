const express = require("express");
const router = express.Router();
const carouselController = require("../../controllers/admin/carousel_images_controller");

// Crear una nueva imagen en el carrusel
router.post("/create", carouselController.createCarouselImage);

// Obtener todas las imágenes del carrusel
router.get("/all", carouselController.getAllCarouselImages);

// Obtener una imagen del carrusel por ID
router.get("/get/:id", carouselController.getCarouselImageById);

//eliminar imagen del carrusel
router.delete('/delete/:imageName', carouselController.deleteCarouselImage);

module.exports = router;
