require("dotenv").config(); // Cargar variables de entorno al inicio

const express = require("express");
const cors = require("cors"); // Importar cors
const sequelize = require("./config/database");
const authRoutes = require("./routes/routes"); // Importas las rutas

const app = express();
const port = process.env.PORT || 3000;

// Middleware global
app.use(express.json());
app.use(cors({ origin: process.env.FRONTEND_URL, credentials: true }));

// Rutas
app.use('/api', authRoutes); // Aquí aplicas las rutas relacionadas con la API

// Conectar con la base de datos y sincronizar
sequelize.sync()
  .then(() => console.log("Conectado a la base de datos y sincronizado"))
  .catch((err) => console.error("Error al conectar a la DB:", err));

// Iniciar servidor
app.listen(port, () => {
  console.log(`🚀 Servidor corriendo en http://localhost:${port}`);
});
