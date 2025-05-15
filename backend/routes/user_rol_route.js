//routes/user_rol_route.js
const express = require('express');
const router = express.Router();
const User = require('../models/user_model'); // Modelo de usuario

// Ruta para obtener el rol del usuario basado en su firebase_uid
router.get('/user_role', async (req, res) => {
  const firebaseUid = req.query.firebase_uid;

  if (!firebaseUid) {
    return res.status(400).json({ message: 'firebase_uid es requerido' });
  }

  try {
    console.log("Buscando usuario con firebase_uid:", firebaseUid);
    const user = await User.findOne({ where: { firebase_uid: firebaseUid } });
    if (!user) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }
    return res.status(200).json({ id_rol: user.id_rol });
  } catch (error) {
    console.error("Error al obtener el rol:", error); // Log de error
    return res.status(500).json({ message: 'Error en el servidor', error: error.message });
  }
});

module.exports = router;
