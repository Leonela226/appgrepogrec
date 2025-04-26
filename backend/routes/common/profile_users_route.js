// src/routes/userRoutes.js
const express = require('express');
const { getUser, updateUser} = require('../../controllers/common/profile_users_controller');

const router = express.Router();

// Obtener un usuario por ID
router.get('/firebase/:firebase_uid', getUser);

//actualizar datos de usuario
router.put('/updateUsers/:id', updateUser);



module.exports = router;
