const express = require('express');
const router = express.Router();
const cardsController= require('../../controllers/admin/cards_controller');  // Importa el controlador

// Ruta para obtener los sorteos activos con los premios
router.get('/active', cardsController.cardsGiveaway);

module.exports = router;