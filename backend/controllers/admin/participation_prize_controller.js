const { Sequelize } = require('sequelize');
const Giveaway = require('../../models/admin/view_giveaway_model');
const CodeQR = require('../../models/client/scanner_qr_model');
const Participation = require('../../models/client/participation_model');

exports.getGiveawaysWithParticipationCount = async (req, res) => {
  try {
    const giveaways = await Giveaway.findAll({
      include: [
        {
          model: CodeQR,
          as: 'codesQR',
          required: false,
          include: [
            {
              model: Participation,
              as: 'participations',
              required: false,
              attributes: [],
            },
          ],
          attributes: [],
        },
      ],
      attributes: [
        'id_giveaway',
        'name_giveaway',
        'draw_date_giveaway',
        // Subconsulta de conteo de participaciones
        [Sequelize.literal(`
          (SELECT COUNT(*) 
           FROM participations 
           INNER JOIN codes_qr 
           ON codes_qr.id_codes_qr = participations.id_code_qr 
           WHERE codes_qr.code_giveaway = Giveaway.id_giveaway)
        `), 'participation_count'],
      ],
    });

    return res.status(200).json({
      message: 'Sorteos con conteo de participaciones obtenidos correctamente.',
      data: giveaways,
    });
  } catch (error) {
    console.error("Error al obtener sorteos con conteo de participaciones:", error);
    return res.status(500).json({
      message: "Error al obtener los sorteos con participaciones.",
      error: error.message,
    });
  }
};
