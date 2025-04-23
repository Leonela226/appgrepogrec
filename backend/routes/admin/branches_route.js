const express = require('express');
const router = express.Router();
const branchesController = require('../../controllers/admin/branches_controller');  // Asegúrate de importar correctamente el controlador


router.get('/all', branchesController.getAllBranches);


router.get('/get/:id_giveaway', branchesController.getBranchById);  // Usa el controlador 


module.exports = router;