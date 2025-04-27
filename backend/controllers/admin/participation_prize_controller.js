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
        codeGiveaway: giveaway.code_giveaway, // <-- AGREGAR AQUÍ
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



// realización de
async function startRoulette(req, res) {
  try {
    const { code_giveaway } = req.body;  // Solo necesitamos el código del sorteo
    console.log("Código del sorteo recibido:", code_giveaway);

    if (!code_giveaway) {
      return res.status(400).json({ error: 'El código del sorteo (code_giveaway) es obligatorio' });
    }

    // 1. Obtener todos los códigos QR relacionados con el sorteo
    const codesQR = await CodeQR.findAll({
      where: { code_giveaway }  // Filtramos por el código del sorteo
    });

    if (codesQR.length === 0) {
      return res.status(400).json({ error: 'No se encontraron códigos QR para este sorteo' });
    }

    // 2. Obtener todos los ids de los códigos QR (para buscar las participaciones asociadas)
    const codesQRIds = codesQR.map(code => code.id_codes_qr);

    // 3. Obtener todas las participaciones asociadas a esos códigos QR
    const participations = await Participation.findAll({
      where: { id_codes_qr: { [Sequelize.Op.in]: codesQRIds } },  // Filtramos por los códigos QR obtenidos
      include: [
        {
          model: User,
          as: 'user',
          attributes: ['email_user']  // Traemos el correo del usuario
        }
      ]
    });

    if (participations.length === 0) {
      return res.status(400).json({ error: 'No hay participaciones para este sorteo' });
    }

    // 4. Contamos las participaciones por correo
    const emailParticipationCount = {};

    participations.forEach(participation => {
      const email = participation.user.email_user;
      emailParticipationCount[email] = (emailParticipationCount[email] || 0) + 1;
    });

    console.log("Conteo de participaciones por correo:", emailParticipationCount);

    // 5. Función para censurar parcialmente el correo
    const censorEmail = (email) => {
      const [user, domain] = email.split('@');
      const censoredUser = user.substring(0, 5) + '******';  // Mostrar solo los primeros 5 caracteres
      const censoredDomain = domain.substring(0, 3) + '**';  // Mostrar los primeros 3 caracteres del dominio
      return censoredUser + '@' + censoredDomain;
    };

    // 6. Crear una lista con los correos censurados y las participaciones expandidas
    const emailsExpanded = [];
    for (const [email, count] of Object.entries(emailParticipationCount)) {
      const censoredEmail = censorEmail(email);  // Censuramos el correo
      for (let i = 0; i < count; i++) {
        emailsExpanded.push(censoredEmail);
      }
    }

    // 7. Aleatorizamos el orden de los correos utilizando el algoritmo de Fisher-Yates
    for (let i = emailsExpanded.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [emailsExpanded[i], emailsExpanded[j]] = [emailsExpanded[j], emailsExpanded[i]];  // Intercambiar elementos
    }

    return res.status(200).json({ participants: emailsExpanded });

  } catch (error) {
    console.error('Error en startRoulette:', error);
    return res.status(500).json({ error: 'Error interno del servidor' });
  }
}





module.exports = {
  getActiveGiveaways,
  startRoulette
};
