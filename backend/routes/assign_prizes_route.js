const express = require('express');
const router = express.Router();
const assignPrizesController = require('../controllers/assign_prizes_controller');  // Asegúrate de importar correctamente el controlador

// Ruta para obtener todos los premios asignados a un sorteo específico
router.get('/assign/:id_giveaway', assignPrizesController.getAllAssignedPrizes);  // Usa el controlador correcto

// Ruta para asignar un premio a un sorteo
router.post('/assign/:id_giveaway', assignPrizesController.assignPrize);  // Usa el controlador correcto

// Ruta para obtener el nombre de un sorteo
router.get('/giveaway/:id_giveaway',assignPrizesController.getGiveawayById);

module.exports = router;
