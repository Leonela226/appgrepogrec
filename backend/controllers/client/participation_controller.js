const Participation = require("../../models/client/participation_model"); 
const User = require("../../models/common/user_model"); 
const CodeQR = require("../../models/client/scanner_qr_model");
const Giveaway = require("../../models/admin/view_giveaway_model");

// Crear una nueva participación
exports.createParticipation = async (req, res) => {
  const { id_user, id_codes_qr } = req.body;

  if (!id_user || !id_codes_qr) {
    return res.status(400).json({ message: "Faltan datos requeridos." });
  }

  try {
    // Verifica que el usuario exista
    const user = await User.findByPk(id_user);
    if (!user) {
      return res.status(404).json({ message: "Usuario no encontrado." });
    }

    // Verifica que el código QR exista
    const codeQR = await CodeQR.findByPk(id_codes_qr);
    if (!codeQR) {
      return res.status(404).json({ message: "Código QR no encontrado." });
    }

    // verificar si ya existe una participación de este usuario con ese código QR
    const existingParticipation = await Participation.findOne({
      where: { id_user, id_codes_qr }
    });

    if (existingParticipation) {
      return res.status(409).json({
        message: "Ya existe una participación con este código QR para el usuario.",
        data: existingParticipation
      });
    }

    // Crear la participación
    const newParticipation = await Participation.create({
      id_user,
      id_codes_qr
    });

    return res.status(201).json({
      message: "Participación registrada correctamente.",
      data: newParticipation
    });
  } catch (error) {
    console.error("Error al registrar la participación:", error);
    return res.status(500).json({
      message: "Error al registrar la participación.",
      error: error.message
    });
  }
};

// Resumen de participaciones por usuario (usando firebase_uid)
exports.getUserParticipationSummary = async (req, res) => {
  const { firebase_uid } = req.body;

  //console.log("DEBUG: UID recibido:", firebase_uid);

  if (!firebase_uid) {
    return res.status(400).json({ message: "El UID de Firebase es requerido." });
  }

  try {
    const user = await User.findOne({ where: { firebase_uid } });

    //console.log("DEBUG: Usuario encontrado:", user?.id_user);

    if (!user) {
      return res.status(404).json({ message: "Usuario no encontrado." });
    }

    const participations = await Participation.findAll({
      where: { id_user: user.id_user },
      include: [
        {
          model: CodeQR,
          as: "codeQR",
          include: [
            {
              model: Giveaway,
              as: "giveaway",
              attributes: ["code_giveaway", "name_giveaway"]
            }
          ]
        }
      ],
      order: [["participation_date", "ASC"]]
    });

    //console.log("DEBUG: Cantidad de participaciones encontradas:", participations.length);

    if (!participations.length) {
      return res.status(404).json({ message: "El usuario no tiene participaciones registradas." });
    }

    const summaryMap = {};

    participations.forEach((participation) => {
      const giveaway = participation.codeQR?.giveaway || { name_giveaway: "No Disponible", code_giveaway: "N/A" };

      const participationDate = new Date(participation.participation_date).toISOString().split('T')[0]; // Solo la fecha
      const code = giveaway.code_giveaway;

      if (!summaryMap[code]) {
        summaryMap[code] = {
          giveaway_name: giveaway.name_giveaway,
          first_participation_date: participationDate,
          total_participations: 1
        };
      } else {
        summaryMap[code].total_participations++;
      }
    });

    const summaryArray = Object.values(summaryMap);

    console.log("DEBUG: Resumen generado:", summaryArray);

    return res.status(200).json({
      message: "Resumen de participaciones obtenido correctamente.",
      data: summaryArray
    });
  } catch (error) {
    console.error("ERROR al obtener el resumen de participaciones:", error);
    return res.status(500).json({
      message: "Error al obtener el resumen de participaciones.",
      error: error.message
    });
  }
};
