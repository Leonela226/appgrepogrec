// src/routes/userRoutes.js
const express = require('express');
const { getUser } = require('../../controllers/common/profile_users_controller');

const router = express.Router();

// Obtener un usuario por ID
router.get('/firebase/:firebase_uid', getUser);


module.exports = router;
