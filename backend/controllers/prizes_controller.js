const multer = require('multer');
const path = require('path');
const fs = require('fs');
const Prize = require("../models/prizes_model");

// Configuración de almacenamiento para multer
const storage = multer.diskStorage({
  destination: async (req, file, cb) => {
    const dir = path.join(__dirname, '..', 'uploads', 'prizes_images');
    try {
      await fs.promises.mkdir(dir, { recursive: true });  // Crear el directorio si no existe
      cb(null, dir);
    } catch (error) {
      console.error("Error al crear el directorio:", error);
      cb(new Error("No se pudo crear el directorio para las imágenes de los premios."));
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

    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Solo se permiten imágenes de tipo JPEG, PNG o GIF'), false);
    }
  }
});

// Crear un nuevo premio
exports.createPrize = async (req, res) => {
  upload.single('prize_image')(req, res, async (err) => {  // Aquí estamos usando el middleware directamente
    if (err instanceof multer.MulterError) {
      return res.status(400).json({ message: "Error al cargar la imagen del premio.", error: err.message });
    } else if (err) {
      return res.status(500).json({ message: "Error interno del servidor.", error: err.message });
    }

    // Verifica si el archivo fue cargado
    if (!req.file) {
      return res.status(400).json({ message: "No se ha cargado ninguna imagen del premio." });
    }

    // Extrae los datos del cuerpo de la solicitud
    const { name_prize, description_prize } = req.body;

    // Verifica que los datos necesarios estén presentes
    if (!name_prize || !description_prize) {
      return res.status(400).json({ message: "Faltan datos requeridos." });
    }

    // Generar la URL de la imagen
    const baseSUrl = process.env.FRONTEND_URL;
    const image_url = `${baseSUrl}/uploads/prizes_images/${req.file.filename}`;

    try {
      // Guardar el premio en la base de datos
      const newPrize = await Prize.create({ name_prize, description_prize, image_url });

      return res.status(201).json({
        message: "Premio creado correctamente.",
        data: newPrize
      });
    } catch (error) {
      console.error("Error al guardar en la base de datos:", error);
      return res.status(500).json({ message: "Error al guardar el premio en la base de datos.", error: error.message });
    }
  });
};

// Obtener todos los premios los nombres
exports.getAllPrizes = async (req, res) => {
  try {
    const prizes = await Prize.findAll();
    const prizeNames = prizes.map(prize => prize.name_prize); // Extraemos solo los nombres
    return res.status(200).json({
      message: "Premios obtenidos correctamente.",
      data: prizeNames // Devolvemos solo los nombres
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Error al obtener los premios.", error: error.message });
  }
};

// Obtener un premio por ID
exports.getPrizeById = async (req, res) => {
  try {
    const { id } = req.params;
    const prize = await Prize.findByPk(id);

    if (!prize) {
      return res.status(404).json({ message: "Premio no encontrado." });
    }

    return res.status(200).json({
      message: "Premio obtenido correctamente.",
      data: prize
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Error al obtener el premio.", error: error.message });
  }
};

// Eliminar un premio por ID
exports.deletePrizeById = async (req, res) => {
  const { id } = req.params;

  try {
    // Buscar el premio por ID
    const prize = await Prize.findByPk(id);

    if (!prize) {
      return res.status(404).json({ message: "Premio no encontrado." });
    }

    // Eliminar la imagen del premio del sistema de archivos
    const imagePath = path.join(__dirname, '..', 'uploads', 'prizes_images', path.basename(prize.image_url));
    if (fs.existsSync(imagePath)) {
      fs.unlinkSync(imagePath);  // Eliminar la imagen
    }

    // Eliminar el premio de la base de datos
    await prize.destroy();

    return res.status(200).json({
      message: "Premio eliminado correctamente."
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Error al eliminar el premio.", error: error.message });
  }
};
