const express = require('express');
const router = express.Router();
const assignPrizesController = require('../../controllers/admin/assign_prizes_controller');  // Asegúrate de importar correctamente el controlador

// Ruta para obtener la cantidad de premios asignados a un sorteo específico
router.get('/countPrizes/:id_giveaway', assignPrizesController.countAssignedPrizes);  // Usa el controlador correcto

// Ruta para obtener el nombre de un sorteo
router.get('/giveaway/:id_giveaway',assignPrizesController.getGiveawayById);

// Ruta para obtener todos los premios disponibles
router.get('/prizes', assignPrizesController.getAllPrizes);

// ruta para guardar multiples premios a un sorteo especifico
router.post('/save',assignPrizesController.saveAssignedPrizes)

// ruta para obtener todos los premios asignados a un sorteo en especifico
router.get('/assignPrize/:id_giveaway', assignPrizesController.getAssignedPrizes);


module.exports = router;
