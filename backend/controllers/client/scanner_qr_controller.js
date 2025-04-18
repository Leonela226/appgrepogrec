const CodeQR = require("../../models/client/scanner_qr_model");
const Giveaway = require("../../models/admin/view_giveaway_model"); // Importamos el modelo de sorteo

// Crear un nuevo código QR
exports.createCodeQR = async (req, res) => {
    // Extrae el dato del cuerpo de la solicitud (un solo string con el value y el code separados por un guion)
    const { qr_code_value } = req.body;
  
    // Verifica que el qr_code_value esté presente
    if (!qr_code_value) {
      return res.status(400).json({ message: "Faltan datos requeridos." });
    }
  
    try {
      // Dividir el qr_code_value en dos partes (value_code_qr y code_giveaway) usando el guión como separador
      const parts = qr_code_value.split("-");
  
      // Verifica si la división fue correcta (debe haber exactamente dos partes)
      if (parts.length !== 2) {
        return res.status(400).json({ message: "El valor del código QR no es válido. Debe estar separado por un guion." });
      }
  
      const value_code_qr = parts[0]; // La primera parte será el value_code_qr
      const code_giveaway = parts[1]; // La segunda parte será el code_giveaway
  
      // Verifica si el sorteo proporcionado existe
      const giveaway = await Giveaway.findOne({ where: { code_giveaway } });
      if (!giveaway) {
        return res.status(404).json({ message: "Sorteo no encontrado." });
      }

      // 🚫 Verifica si ya existe un código QR con ese value
      const existingCodeQR = await CodeQR.findOne({ where: { value_code_qr } });
      if (existingCodeQR) {
        return res.status(409).json({
            message: "Este código QR ya ha sido registrado.",
            data: existingCodeQR,
        });
      }
  
      // Crear un nuevo código QR en la base de datos
      const newCodeQR = await CodeQR.create({
        value_code_qr: value_code_qr,
        code_giveaway: code_giveaway
      });
  
      return res.status(201).json({
        message: "Código QR creado correctamente.",
        data: newCodeQR
      });
    } catch (error) {
      console.error("Error al guardar en la base de datos:", error);

      if (error.name === 'SequelizeUniqueConstraintError') {
        return res.status(409).json({
          message: "Este código QR ya ha sido registrado.",
        });
      }

      return res.status(500).json({ message: "Error al guardar el código QR.", 
        error: error.message });
    }
  };
  
  // Obtener todos los códigos QR
  exports.getAllCodesQR = async (req, res) => {
    try {
      const codesQR = await CodeQR.findAll();
      return res.status(200).json({
        message: "Códigos QR obtenidos correctamente.",
        data: codesQR
      });
    } catch (error) {
      console.error(error);
      return res.status(500).json({ message: "Error al obtener los códigos QR.", error: error.message });
    }
  };
  
  // Obtener un código QR por ID
  exports.getCodeQRById = async (req, res) => {
    try {
      const { id } = req.params;
      const codeQR = await CodeQR.findByPk(id);
  
      if (!codeQR) {
        return res.status(404).json({ message: "Código QR no encontrado." });
      }
  
      return res.status(200).json({
        message: "Código QR obtenido correctamente.",
        data: codeQR
      });
    } catch (error) {
      console.error(error);
      return res.status(500).json({ message: "Error al obtener el código QR.", error: error.message });
    }
  };