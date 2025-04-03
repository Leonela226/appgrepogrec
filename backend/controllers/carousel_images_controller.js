const multer = require('multer');
const path = require('path');
const fs = require('fs');
const Carousel = require("../models/carousel_images_model");

// Configuración de almacenamiento para multer
const storage = multer.diskStorage({
  destination: async (req, file, cb) => {
    const dir = path.join(__dirname, '..', 'uploads', 'carousel_images');
    try {
      await fs.promises.mkdir(dir, { recursive: true });  // Crear el directorio si no existe
      cb(null, dir);
    } catch (error) {
      console.error("Error al crear el directorio:", error);
      cb(new Error("No se pudo crear el directorio para las imágenes."));
    }
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase(); // Asegurar extensión en minúsculas
    const filename = `${Date.now()}${ext}`;
    cb(null, filename);
  }
});

// Configuración de multer con un límite de tamaño y filtro de tipos de archivo
const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // Limitar tamaño a 5 MB
  fileFilter: (req, file, cb) => {
    console.log("Tipo MIME recibido:", file.mimetype); // Depuración del tipo MIME

    const allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Solo se permiten imágenes de tipo JPEG, PNG o GIF'), false);
    }
  }
});

// Crear una nueva imagen en el carrusel
exports.createCarouselImage = async (req, res) => {
  upload.single('carousel_image')(req, res, async (err) => {
    if (err instanceof multer.MulterError) {
      return res.status(400).json({ message: "Error al cargar la imagen.", error: err.message });
    } else if (err) {
      return res.status(500).json({ message: "Error interno del servidor.", error: err.message });
    }

    if (!req.file) {
      return res.status(400).json({ message: "No se ha cargado ninguna imagen." });
    }

    console.log("Archivo recibido:", req.file); // Depuración de archivo recibido
    console.log("Datos del cuerpo:", req.body); // Depuración de los datos recibidos

    // Extraer los datos del cuerpo de la solicitud
    const { title_carousel_image, description_carousel_image } = req.body;
    
    // Generar la URL de la imagen
    const url_carousel_image = req.file.filename;

    //const baseSUrl = process.env.FRONTEND_URL; 
    //const url_carousel_image = `${baseSUrl}/uploads/carousel_images/${req.file.filename}`;

    try {
      // Guardar la URL de la imagen en la base de datos
      const newCarouselImage = await Carousel.create({
        url_carousel_image,
        title_carousel_image,
        description_carousel_image
      });

      // Emitir evento a WebSocket para actualizar a los clientes en tiempo real
      const io = req.app.get("io");
      io.emit("carouselUpdated", { message: "Nueva imagen en el carrusel", data: newCarouselImage });

      return res.status(201).json({
        message: "Imagen del carrusel creada correctamente.",
        data: newCarouselImage
      });
    } catch (error) {
      console.error("Error al guardar en la base de datos:", error);
      return res.status(500).json({ message: "Error al guardar la imagen en la base de datos.", error: error.message });
    }
  });
};

// Obtener todas las imágenes del carrusel
exports.getAllCarouselImages = async (req, res) => {
  try {
    const carouselImages = await Carousel.findAll();
    return res.status(200).json({
      message: "Imágenes obtenidas correctamente.",
      data: carouselImages
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Error al obtener las imágenes.", error: error.message });
  }
};

// Obtener una imagen del carrusel por ID
exports.getCarouselImageById = async (req, res) => {
  try {
    const { id } = req.params;
    const carouselImage = await Carousel.findByPk(id);

    if (!carouselImage) {
      return res.status(404).json({ message: "Imagen no encontrada." });
    }

    return res.status(200).json({
      message: "Imagen obtenida correctamente.",
      data: carouselImage
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Error al obtener la imagen.", error: error.message });
  }
};
