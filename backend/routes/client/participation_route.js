const express = require("express");
const router = express.Router();
const participationController = require("../../controllers/client/participation_controller");

router.post("/create", participationController.createParticipation);

router.post("/participationSummary", participationController.getUserParticipationSummary);


module.exports = router;
