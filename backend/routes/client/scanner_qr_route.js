// routes/client/scanner_qr_routes.js
const express = require("express");
const router = express.Router();
const scannerQRController = require("../../controllers/client/scanner_qr_controller");

// Crear un nuevo código QR
router.post("/create", scannerQRController.createCodeQR);

// Obtener todos los códigos QR
router.get("/allqr", scannerQRController.getAllCodesQR);

// Obtener un código QR por ID
router.get("/qr/:id", scannerQRController.getCodeQRById);

module.exports = router;
