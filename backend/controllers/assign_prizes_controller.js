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

// Obtener todos los premios disponibles
exports.getAllPrizes = async (req, res) => {
  try {
    // Obtener todos los premios de la base de datos
    const allPrizes = await Prize.findAll({
      attributes: ['id_prize', 'name_prize'] // Solo obtener el nombre del premio
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


// Asignar múltiples premios al sorteo
exports.saveAssignedPrizes = async (req, res) => {
  const { id_giveaway, assignedPrizes } = req.body;

  try {
    // Verificar que el sorteo existe
    const giveaway = await Giveaway.findByPk(id_giveaway);
    if (!giveaway) {
      return res.status(404).json({ message: 'Sorteo no encontrado' });
    }

    // Verificar que no se exceda la cantidad máxima de premios
    const assignedPrizesCount = assignedPrizes.length;
    if (assignedPrizesCount < giveaway.prize_count) {
      return res.status(400).json({
        message: `Faltan premios por asignar. Este sorteo tiene ${giveaway.prize_count} premios en total.`
      });
    }

    // Verificar que no se asignen más premios de los permitidos
    if (assignedPrizesCount > giveaway.prize_count) {
      return res.status(400).json({
        message: `No se pueden asignar más de ${giveaway.prize_count} premios.`
      });
    }

    // Verificar si ya existen premios asignados para este sorteo
    const existingAssignments = await GiveawayPrize.findAll({
      where: {
        id_giveaway: id_giveaway,
        id_prize: assignedPrizes.map(prize => prize.prize_id),
      },
    });

    if (existingAssignments.length > 0) {
      return res.status(400).json({
        message: 'Algunos premios ya han sido asignados a este sorteo.',
      });
    }

    // Guardar los premios asignados
    const assignments = await GiveawayPrize.bulkCreate(assignedPrizes.map((prize) => ({
      id_giveaway: id_giveaway,
      id_prize: prize.prize_id,
      rank: prize.rank,
    })));

    return res.status(201).json({
      message: 'Premios asignados correctamente.',
      data: assignments,
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Error al guardar los premios asignados', error: error.message });
  }
};