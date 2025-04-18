const User = require("../../models/common/user_model");
const admin = require("../../config/firebase");
const sequelize = require('../../config/database'); // Importación corregida

// Ruta para registrar un usuario
exports.registerUser = async (req, res) => {
  const t = await sequelize.transaction(); // Iniciar una transacción

  try {
    // Desestructuración del cuerpo de la solicitud
    const { firebase_uid, name_user, email_user, phone_number, date_birth } = req.body;
    const id_role = req.body.id_role || 3;  // Valor predeterminado para "cliente"
    const status_user = req.body.status_user || 'activo';  // Valor predeterminado "activo"

    // 1️⃣ Verificar si el correo electrónico ya está registrado en MySQL
    const existingUserEmail = await User.findOne({ where: { email_user }, transaction: t });
    if (existingUserEmail) {
      await t.rollback();
      return res.status(400).json({ error: "El correo electrónico ya está registrado" });
    }

    // 2️⃣ Verificar si el usuario existe en Firebase usando el firebase_uid
    try {
      await admin.auth().getUser(firebase_uid);
    } catch (firebaseError) {
      await t.rollback();
      return res.status(400).json({ error: "Usuario no registrado en Firebase o UID inválido" });
    }

    // 3️⃣ Verificar si el usuario ya existe en MySQL por UID de Firebase
    const existingUser = await User.findOne({ where: { firebase_uid }, transaction: t });
    if (existingUser) {
      await t.rollback();
      return res.status(400).json({ error: "El usuario ya está registrado en la base de datos" });
    }

    // 4️⃣ Registrar en MySQL con los datos adicionales
    const newUser = await User.create({
      firebase_uid,
      name_user,
      email_user,
      phone_number,
      date_birth,
      status_user,  // Usar el valor por defecto o proporcionado
      id_rol: id_role,  // Usar el rol proporcionado o el valor predeterminado
    }, { transaction: t });

    // 5️⃣ Confirmar la transacción si todo salió bien
    await t.commit();

    res.status(201).json({ message: "Usuario registrado exitosamente", user: newUser });
    
  } catch (error) {
    await t.rollback();  // Deshacer cambios si hubo error
    console.error("Error en el registro:", error);
    res.status(500).json({ error: "Error interno del servidor" });
  }
};

// Obtener ID del usuario por UID de Firebase
exports.getUserIdByFirebaseUid = async (req, res) => {
  const { firebase_uid } = req.params;

  try {
    const user = await User.findOne({
      where: { firebase_uid },
      attributes: ['id_user'],
    });

    if (!user) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }

    res.status(200).json({ id_user: user.id_user });
  } catch (error) {
    console.error('Error al buscar el usuario:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};

