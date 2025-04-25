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

    // Guardar el premio en la base de datos 
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

    if (!prizes || prizes.length === 0) {
      return res.status(404).json({ message: "No se encontraron premios." });
    }

    return res.status(200).json({
      message: "Premios obtenidos correctamente.",
      data: prizes.map(prize => ({
        id: prize.id_prize,          // Cambiar 'id' por 'id_prize'
        name: prize.name_prize,      // Cambiar 'name' por 'name_prize'
        description: prize.description_prize // Cambiar 'description' por 'description_prize'
      }))
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Error al obtener los premios.", error: error.message });
  }
};



// Endpoint para obtener un premio por su ID
exports.getPrizeByIdSub = async (req, res) => {
  const prizeId = req.params.id;
  
  // Verificar el valor de prizeId
  console.log('ID del premio:', prizeId);

  try {
    const prize = await Prize.findOne({
      where: { id_prize: prizeId }
    });

    if (!prize) {
      return res.status(404).json({ message: "Premio no encontrado." });
    }
    console.log(prize);  // Verifica si prize.id_prize es null

    return res.status(200).json({
      message: "Premio obtenido correctamente.",
      data: prize
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Error al obtener el premio.", error: error.message });
  }
};



// Actualizar un premio existente
exports.updatePrize = async (req, res) => {
  const { name_prize, description_prize } = req.body;
  const prizeId = req.params.id;  // Este es el ID del premio que quieres actualizar.

  if (!name_prize || !description_prize) {
    return res.status(400).json({ message: "Faltan datos requeridos." });
  }

  try {
    // Buscar el premio por ID
    const prize = await Prize.findByPk(prizeId);
    if (!prize) {
      return res.status(404).json({ message: "Premio no encontrado." });
    }

    // Verificar si el nuevo nombre ya está siendo usado por otro premio
    const existingPrize = await Prize.findOne({
      where: { name_prize, id_prize: { [Op.ne]: prizeId } }
    });

    if (existingPrize) {
      return res.status(400).json({ message: "Ya existe otro premio con ese nombre." });
    }

    // Actualizar los valores del premio
    prize.name_prize = name_prize;
    prize.description_prize = description_prize;
    await prize.save();  // Guardamos el premio actualizado

    return res.status(200).json({
      message: "Premio actualizado correctamente.",
      data: prize
    });
  } catch (error) {
    console.error("Error al actualizar el premio:", error);
    return res.status(500).json({ message: "Error al actualizar el premio.", error: error.message });
  }
};



