const Prize = require("../../models/admin/prizes_model");

// Crear un nuevo premio
exports.createPrize = async (req, res) => {
  // Extrae los datos del cuerpo de la solicitud
  const { name_prize, description_prize } = req.body;

  // Verifica que los datos necesarios estén presentes
  if (!name_prize || !description_prize) {
    return res.status(400).json({ message: "Faltan datos requeridos." });
  }

  try {
    // Verifica si ya existe un premio con el mismo nombre
    const existingPrize = await Prize.findOne({ where: { name_prize } });
    if (existingPrize) {
      return res.status(400).json({ message: "El premio ya existe." });
    }

    // Guardar el premio en la base de datos sin imagen
    const newPrize = await Prize.create({ name_prize, description_prize });

    return res.status(201).json({
      message: "Premio creado correctamente.",
      data: newPrize
    });
  } catch (error) {
    console.error("Error al guardar en la base de datos:", error);
    return res.status(500).json({ message: "Error al guardar el premio en la base de datos.", error: error.message });
  }
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
