// participation_prize_route.js
const express = require('express');
const router = express.Router();
const participationPrizeController = require('../../controllers/admin/participation_prize_controller');

// Ruta para obtener los sorteos con el conteo de participaciones
router.get('/getGivAvailable', participationPrizeController.getActiveGiveaways);

router.post('/roulette', participationPrizeController.startRoulette);

module.exports = router;
