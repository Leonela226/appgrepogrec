const GiveawayPrize = require('../models/assign_prizes_model');
const Giveaway = require('../models/view_giveaway_model');
const Prize = require('../models/prizes_model');

// Verificar la cantidad de premios asignados al sorteo
exports.countAssignedPrizes = async (req, res) => {
  const { id_giveaway } = req.params;

  try {
    // Verificar que el sorteo existe
    const giveaway = await Giveaway.findByPk(id_giveaway);
    if (!giveaway) {
      return res.status(404).json({ message: 'Sorteo no encontrado' });
    }

    // Contar los premios asignados al sorteo
    const assignedPrizes = await GiveawayPrize.count({
      where: { id_giveaway: id_giveaway }
    });

    const maxPrizes = giveaway.prize_count; // Número máximo de premios del sorteo

    // Verificar que no se asignen más premios de los permitidos
    if (assignedPrizes >= maxPrizes) {
      return res.status(400).json({
        message: `No se pueden asignar más premios. El sorteo ya tiene ${maxPrizes} premios asignados.`
      });
    }

    // Responder con la cantidad de premios asignados y el máximo
    return res.status(200).json({
      assignedPrizesCount: assignedPrizes,
      maxPrizes: maxPrizes
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Error al obtener los premios asignados.', error: error.message });
  }
};

// Asignar un premio al sorteo
exports.assignPrize = async (req, res) => {
  const { id_giveaway, prize_id, rank } = req.body; // Datos del premio y sorteo

  try {
    // Verificar que el sorteo existe
    const giveaway = await Giveaway.findByPk(id_giveaway);
    if (!giveaway) {
      return res.status(404).json({ message: 'Sorteo no encontrado' });
    }

    // Verificar que el premio existe
    const prize = await GiveawayPrize.findByPk(prize_id);
    if (!prize) {
      return res.status(404).json({ message: 'Premio no encontrado' });
    }

    // Verificar que el premio no haya sido asignado ya
    const existingAssignment = await GiveawayPrize.findOne({
      where: { id_giveaway: id_giveaway, prize_id: prize_id }
    });

    if (existingAssignment) {
      return res.status(400).json({ message: 'Este premio ya ha sido asignado al sorteo.' });
    }

    // Asignar el premio al sorteo
    await GiveawayPrize.create({
      id_giveaway: id_giveaway,
      prize_id: prize_id,
      rank: rank
    });

    return res.status(200).json({ message: 'Premio asignado correctamente al sorteo.' });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Error al asignar el premio.', error: error.message });
  }
};







/* Controlador para asignar un premio a un sorteo
exports.assignPrize = async (req, res) => {
  const { id_giveaway } = req.params; // ID del sorteo pasado por parámetro
  const { id_prize, rank } = req.body; // Datos enviados para asignar el premio

  try {
    // Verificar que el sorteo existe
    const giveaway = await Giveaway.findByPk(id_giveaway);
    if (!giveaway) {
      return res.status(404).json({ message: 'Sorteo no encontrado' });
    }

    // Verificar la cantidad de premios asignados al sorteo
    const assignPrizes = await GiveawayPrize.count({
      where: { id_giveaway: id_giveaway }
    });

    const maxPrizes = giveaway.prize_count; // Suponiendo que tienes un campo 'prize_count' en Giveaway

    // Verificar que no se asignen más premios de los permitidos
    if (assignPrizes >= maxPrizes) {
      return res.status(400).json({
        message: `No se pueden asignar más premios. El sorteo ya tiene ${maxPrizes} premios asignados.`
      });
    }

    // Verificar que el rank no esté ya asignado
    const rankReal = await GiveawayPrize.findOne({
      where: { id_giveaway: id_giveaway, rank: rank },
    });

    if (rankReal) {
      return res.status(400).json({ message: `El rank ${rank} ya está asignado en este sorteo.` });
    }

    // Verificar que el rank esté dentro del rango permitido
    if (rank < 1 || rank > maxPrizes) {
      return res.status(400).json({ message: `El rank debe estar entre 1 y ${maxPrizes}.` });
    }

    // Crear el nuevo registro de asignación de premio
    const newGiveawayPrize = await GiveawayPrize.create({
      id_giveaway: id_giveaway,
      id_prize: id_prize,
      rank: rank,
    });

    return res.status(201).json({
      message: 'Premio asignado correctamente al sorteo',
      data: newGiveawayPrize,
    });

  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Error al asignar el premio', error: error.message });
  }
}; */

// Obtener todos los premios disponibles
exports.getAllPrizes = async (req, res) => {
  try {
    // Obtener todos los premios de la base de datos
    const allPrizes = await Prize.findAll({
      attributes: ['name_prize'] // Solo obtener el nombre del premio
    });


    if (allPrizes.length === 0) {
      return res.status(404).json({ message: 'No hay premios disponibles' });
    }

    // Devolver los premios encontrados
    return res.status(200).json({
      message: 'Premios obtenidos correctamente.',
      data: allPrizes,
    });
  } catch (error) {
    console.error('Error al obtener los premios:', error);  // Esto muestra el error básico
    console.error('Stack trace:', error.stack);  // Esto te da el trace completo del error
    return res.status(500).json({ message: 'Error al obtener los premios', error: error.message });
  }
};

// Obtener todos los premios asignados a un sorteo
exports.getAllAssignedPrizes = async (req, res) => {
  const { id_giveaway } = req.params; // ID del sorteo pasado por parámetro

  try {
    // Verificar que el sorteo existe
    const giveaway = await Giveaway.findByPk(id_giveaway);
    if (!giveaway) {
      return res.status(404).json({ message: 'Sorteo no encontrado' });
    }

    // Obtener todos los premios asignados a este sorteo
    const assignedPrizes = await GiveawayPrize.findAll({
      where: { id_giveaway: id_giveaway },
      include: [
        { model: Prize, attributes: ['id_prize', 'name_prize'] },  // Incluir los detalles del premio
        { model: Giveaway, attributes: ['id_giveaway', 'name_giveaway'] },  // Incluir los detalles del sorteo
      ],
      order: [['rank', 'ASC']],  // Ordenar por el rango (rank) si lo necesitas
    });

    if (assignedPrizes.length === 0) {
      return res.status(404).json({ message: 'No hay premios asignados a este sorteo.' });
    }

    return res.status(200).json({
      message: 'Premios asignados obtenidos correctamente.',
      data: assignedPrizes,
    });

  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Error al obtener los premios asignados.', error: error.message });
  }
};

// Endpoint para obtener el nombre del sorteo y la cantidad de premios
exports.getGiveawayById = async (req, res) => {
  const { id_giveaway } = req.params; // Obtener el ID del sorteo

  try {
    // Buscar el sorteo en la base de datos
    const giveaway = await Giveaway.findByPk(id_giveaway);
    if (!giveaway) {
      return res.status(404).json({ message: 'Sorteo no encontrado' });
    }

    // Devolver el nombre y la cantidad de premios del sorteo
    return res.status(200).json({
      message: 'Sorteo encontrado',
      name: giveaway.name_giveaway,
      prize_count: giveaway.prize_count, // Asegúrate de que este campo exista en tu modelo
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Error al obtener el sorteo', error: error.message });
  }
};
