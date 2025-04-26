const { Op } = require('sequelize');
const sequelize = require("../../config/database");

const Giveaway = require("../../models/admin/view_giveaway_model");
const Participation = require("../../models/client/participation_model");
const GiveawayPrize = require("../../models/admin/assign_prizes_model");
const Prize  = require("../../models/admin/prizes_model");
const CodeQR = require("../../models/client/scanner_qr_model"); 


//contenido en tarjetas 
async function getActiveGiveaways(req, res) {
  try {
    const giveaways = await Giveaway.findAll({
      where: {
        status_giveaway: 'activo',
      },
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
            }
          ]
        },
        {
          model: GiveawayPrize,
          as: 'giveawayPrizes',
          attributes: ['id_giveaway_prize', 'id_prize', 'rank'],
          include: [
            {
              model: Prize,
              as: 'prize',
              attributes: ['name_prize'],
            }
          ]
        }
      ],
      attributes: {
        include: [
          [sequelize.fn('COUNT', sequelize.col('codesQR.participations.id_participation')), 'total_participations']
        ]
      },
      group: [
        'Giveaway.id_giveaway',
        'giveawayPrizes.id_giveaway_prize',
        'giveawayPrizes->prize.id_prize'
      ]
    });

    const formattedGiveaways = giveaways.map(giveaway => {
      return {
        id: giveaway.id_giveaway,
        name: giveaway.name_giveaway,
        drawDate: giveaway.draw_date_giveaway,
        totalParticipations: giveaway.dataValues.total_participations || 0,
        prizes: giveaway.giveawayPrizes
        .filter(prize => prize.prize !== null)
        .map(prize => prize.prize.name_prize),
      };
    });

    return res.status(200).json(formattedGiveaways);

  } catch (error) {
    console.error('Error al obtener los sorteos activos:', error);
    return res.status(500).json({ error: 'Error al obtener los sorteos activos' });
  }
}



// obtener participaciones mostrar los correos











//selccionar aleatoriamente ganadores

module.exports = {
  getActiveGiveaways,
};
