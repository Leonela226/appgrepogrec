const { Sequelize, Op } = require('sequelize');  // Importa Sequelize y Op
const sequelize = require("../../config/database");

const Giveaway = require("../../models/admin/view_giveaway_model");
const Participation = require("../../models/client/participation_model");
const GiveawayPrize = require("../../models/admin/assign_prizes_model");
const Prize  = require("../../models/admin/prizes_model");
const CodeQR = require("../../models/client/scanner_qr_model");
const User = require("../../models/common/user_model"); 
const ParticipationPrize = require("../../models/admin/participation_prize_model"); 


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
        codeGiveaway: giveaway.code_giveaway,
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



// realización del sorteo 
async function startRoulette(req, res) {
  try {
    const { code_giveaway } = req.body;
    console.log("[INFO] Código del sorteo recibido:", code_giveaway);

    if (!code_giveaway) {
      console.warn("[WARN] Código de sorteo no proporcionado.");
      return res.status(400).json({ error: 'El código del sorteo (code_giveaway) es obligatorio' });
    }

    // Buscar el sorteo
    const giveaway = await Giveaway.findOne({ where: { code_giveaway } });
    if (!giveaway) {
      console.warn("[WARN] No se encontró el sorteo para el código:", code_giveaway);
      return res.status(400).json({ error: 'No se encontró el sorteo correspondiente al código proporcionado' });
    }

    const id_giveaway = giveaway.id_giveaway;
    console.log("[INFO] ID del sorteo encontrado:", id_giveaway);

    // Obtener códigos QR relacionados
    const codesQR = await CodeQR.findAll({ where: { code_giveaway } });
    if (codesQR.length === 0) {
      console.warn("[WARN] No se encontraron códigos QR para el sorteo:", code_giveaway);
      return res.status(400).json({ error: 'No se encontraron códigos QR para este sorteo' });
    }

    const codesQRIds = codesQR.map(code => code.id_codes_qr);
    console.log("[INFO] IDs de códigos QR encontrados:", codesQRIds);

    // Obtener participaciones
    const participations = await Participation.findAll({
      where: { id_codes_qr: { [Sequelize.Op.in]: codesQRIds } },
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['id_user','email_user', 'name_user']
        }
      ]
    });

    if (participations.length === 0) {
      console.warn("[WARN] No hay participaciones registradas para el sorteo:", code_giveaway);
      return res.status(400).json({ error: 'No hay participaciones para este sorteo' });
    }

    console.log("[INFO] Total de participaciones encontradas:", participations.length);

    // Contar participaciones por correo
    const emailParticipationCount = {};
    participations.forEach(participation => {
      if (participation.user) {
        const email = participation.user.email_user;
        emailParticipationCount[email] = (emailParticipationCount[email] || 0) + 1;
      }
    });
    console.log("[INFO] Conteo de participaciones por correo:", emailParticipationCount);

    // Función para censurar correos
    const censorEmail = (email) => {
      const [user, domain] = email.split('@');
      const censoredUser = user.substring(0, 5) + '******';
      const censoredDomain = domain.substring(0, 3) + '**';
      return censoredUser + '@' + censoredDomain;
    };

    // Expandir participaciones
    const participantsExpanded = [];
    participations.forEach(participation => {
      if (participation.user) {
        for (let i = 0; i < emailParticipationCount[participation.user.email_user]; i++) {
          participantsExpanded.push({
            realEmail: participation.user.email_user,
            censoredEmail: censorEmail(participation.user.email_user),
            nameUser: participation.user.name_user,
            userId: participation.user.id_user
          });
        }
      }
    });

    console.log("[INFO] Participantes expandidos:", participantsExpanded.length);

    // Aleatorizar lista (pero no asignar premios aún)
    for (let i = participantsExpanded.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [participantsExpanded[i], participantsExpanded[j]] = [participantsExpanded[j], participantsExpanded[i]];
    }

    // Obtener premios (no asignar todavía)
    const giveawayPrizes = await GiveawayPrize.findAll({
      where: { id_giveaway },
      include: [{ model: Prize, as: 'prize', attributes: ['name_prize'] }],
      order: [['rank', 'DESC']]
    });

    if (giveawayPrizes.length === 0) {
      console.warn("[WARN] No hay premios asignados para el sorteo:", id_giveaway);
      return res.status(400).json({ error: 'No hay premios asignados para este sorteo' });
    }

    console.log("[INFO] Premios disponibles:", giveawayPrizes.map(p => p.prize.name_prize));

    // Guardamos los participantes y premios, pero no asignamos todavía
    return res.status(200).json({
      participants: participantsExpanded.map(p => ({
        censoredEmail: p.censoredEmail,
        nameUser: p.nameUser,
        realEmail: p.realEmail, // para que Flutter pueda usarlo internamente 
        userId: p.userId 
      })),
      prizes: giveawayPrizes.map(p => ({
        namePrize: p.prize.name_prize,
        rank: p.rank
      }))
    });

  } catch (error) {
    console.error('[ERROR] Error en startRoulette:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}




module.exports = {
  getActiveGiveaways,
  startRoulette,
};
