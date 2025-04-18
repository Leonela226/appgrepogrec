const express = require("express");
const router = express.Router();
const participationController = require("../../controllers/client/participation_controller");

router.post("/create", participationController.createParticipation);

router.get("/all", participationController.getAllParticipations);

router.get("/get/:id", participationController.getParticipationById);

module.exports = router;
