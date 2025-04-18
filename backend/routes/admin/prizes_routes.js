const express = require('express');
const router = express.Router();
const prizeController = require('../../controllers/admin/prizes_controller'); 

// Ruta para crear un nuevo premio (sin necesidad de aplicar 'upload' aquí, ya lo maneja el controlador)
router.post('/create', prizeController.createPrize);

// Ruta para obtener todos los premios
router.get('/all', prizeController.getAllPrizes);

// Ruta para obtener un premio por ID
router.get('/get/:id', prizeController.getPrizeById);

module.exports = router;
