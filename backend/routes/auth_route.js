// routes/auth_routes.js
const express = require("express");
const router = express.Router();
const { registerUser } = require("../controllers/auth_controller");

// Ruta para el registro de usuarios
router.post('/register', registerUser);


module.exports = router;
