const express = require('express');
const router = express.Router();
const prizeController = require('../../controllers/admin/prizes_controller'); 

// Ruta para crear un nuevo premio
router.post('/create', prizeController.createPrize);

// Ruta para obtener todos los premios
router.get('/all', prizeController.getAllPrizes);

// Ruta para obtener un premio por ID
router.get('/get/:id', prizeController.getPrizeByIdSub);

// Ruta para actualizar datos del premio
router.put('/update/:id', prizeController.updatePrize);


module.exports = router;
