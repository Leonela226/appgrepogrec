const express = require("express");
const router = express.Router();
const giveawayController = require("../controllers/view_giveaway_controller");

// Ruta para crear un nuevo sorteo
router.post("/create", giveawayController.createGiveaway);

// Ruta para obtener todos los sorteos
router.get("/all", giveawayController.getAllGiveaways);


module.exports = router;