const Participation = require("../../models/client/participation_model");
const User = require("../../models/common/user_model"); 
const CodeQR = require("../../models/client/scanner_qr_model");

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

    // (Opcional) Podrías verificar si ya existe una participación de este usuario con ese código QR
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

// Obtener todas las participaciones
exports.getAllParticipations = async (req, res) => {
  try {
    const participations = await Participation.findAll({
      include: [
        { model: User, attributes: ["id_user", "first_name", "email"] },
        { model: CodeQR, attributes: ["id_codes_qr", "value_code_qr"] }
      ],
      order: [["participation_date", "DESC"]]
    });

    return res.status(200).json({
      message: "Participaciones obtenidas correctamente.",
      data: participations
    });
  } catch (error) {
    console.error("Error al obtener participaciones:", error);
    return res.status(500).json({
      message: "Error al obtener las participaciones.",
      error: error.message
    });
  }
};

// Obtener una participación por ID
exports.getParticipationById = async (req, res) => {
  const { id } = req.params;

  try {
    const participation = await Participation.findByPk(id, {
      include: [
        { model: User, attributes: ["id_user", "first_name", "email"] },
        { model: CodeQR, attributes: ["id_codes_qr", "value_code_qr"] }
      ]
    });

    if (!participation) {
      return res.status(404).json({ message: "Participación no encontrada." });
    }

    return res.status(200).json({
      message: "Participación obtenida correctamente.",
      data: participation
    });
  } catch (error) {
    console.error("Error al obtener participación:", error);
    return res.status(500).json({
      message: "Error al obtener la participación.",
      error: error.message
    });
  }
};
