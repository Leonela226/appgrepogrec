require("dotenv").config(); // Cargar variables de entorno desde .env
const express = require("express");
const app = express();
const port = 3000;

// Importar la configuración de Sequelize
const sequelize = require("./config/database"); // configuración de Sequelize en config/database.js

app.use(express.json());

// Ruta de prueba para verificar que la API está funcionando
app.get("/", (req, res) => {
  res.send("API funcionando correctamente");
});

// Conectar la base de datos MySQL con Sequelize
sequelize
  .authenticate() // Verificar la conexión
  .then(() => {
    console.log("Conexión a la base de datos establecida correctamente.");
  })
  .catch((err) => {
    console.error("No se pudo conectar a la base de datos:", err);
  });

// Iniciar el servidor
app.listen(port, () => {
  console.log(`Servidor corriendo en http://localhost:${port}`);
});
