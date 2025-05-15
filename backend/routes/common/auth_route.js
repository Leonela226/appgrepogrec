// routes/auth_routes.js
const express = require("express");
const router = express.Router();
const userController  = require("../../controllers/common/auth_controller");

// Ruta para el registro de usuarios
router.post('/register', userController.registerUser);

router.get('/by-uid/:firebase_uid', userController.getUserIdByFirebaseUid);

router.get('/all',userController.getAllUsers)

router.put('/status-user/:id/status', userController.updateUserStatus);

router.get('/user_role_status', userController.getUserRoleAndStatus);



module.exports = router;
