// src/routes/userRoutes.js
const express = require('express');
const { getUser } = require('../../controllers/admin/profile_user_admin_controller');

const router = express.Router();

// Obtener un usuario por ID
router.get('/firebase/:firebase_uid', getUser);


module.exports = router;
