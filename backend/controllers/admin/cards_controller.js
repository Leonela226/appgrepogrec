const Giveaway = require("../../models/admin/view_giveaway_model");
const GiveawayPrize = require("../../models/admin/assign_prizes_model"); // Modelo de la relación
const Prize = require("../../models/admin/prizes_model"); // Modelo de premios

exports.cardsGiveaway = async (req, res) => {
  try {
    // Obtener sorteos activos junto con los premios asociados
    const giveaways = await Giveaway.findAll({
      where: { status_giveaway: 'activo' },  // Filtrar sorteos activos
      attributes: [  // Seleccionar solo los campos necesarios del sorteo
        'name_giveaway', 
        'image_url', 
        'start_date_giveaway', 
        'end_date_giveaway', 
        'draw_date_giveaway',
        'status_giveaway' // Añadido para devolver el estado
      ],
      include: [  // Incluir la relación con los premios
        {
          model: GiveawayPrize,
          as: 'giveawayPrizes',  // Alias de la relación
          attributes: [],  // No necesitamos atributos de GiveawayPrize, solo su relación
          include: [
            {
              model: Prize,
              as: 'prize', // Alias para la relación con el premio
              attributes: ['name_prize'],  // Obtener solo el nombre del premio
            }
          ]
        }
      ]
    });

    // Si no se encuentran sorteos activos
    if (!giveaways.length) {
      return res.status(404).json({ message: "No hay sorteos activos" });
    }

    // Extraer los nombres de los premios de los resultados
    const formattedGiveaways = giveaways.map(giveaway => {
      // Asegurarse de que giveaway.giveawayPrizes sea un array
      const prizeNames = (giveaway.giveawayPrizes || []).map(giveawayPrize => giveawayPrize.prize.name_prize);

      // Formatear los datos de manera que se ajusten a lo que espera Flutter
      return {
        imageUrl: giveaway.image_url,
        title: giveaway.name_giveaway,
        startParticipation: giveaway.start_date_giveaway,
        endParticipation: giveaway.end_date_giveaway,
        drawDate: giveaway.draw_date_giveaway,
        prizes: prizeNames,
        status: giveaway.status_giveaway, // Se añade el estado aquí
      };
    });

    // Retornar los sorteos activos con los nombres de los premios
    res.json(formattedGiveaways);
  } catch (error) {
    console.error("Error al obtener sorteos activos:", error);
    res.status(500).json({ error: 'Error al obtener los sorteos activos' });
  }
};
