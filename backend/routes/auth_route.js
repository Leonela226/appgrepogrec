// routes/auth_routes.js
const express = require("express");
const router = express.Router();

// Ruta para el registro de usuarios
router.post('/register', registerUser);


module.exports = router;
