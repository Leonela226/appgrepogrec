require("dotenv").config(); // Cargar variables de entorno al inicio

const express = require("express");
const cors = require("cors");
const path = require("path");
const http = require("http"); // Para crear el servidor HTTP
const { Server } = require("socket.io"); // Importar socket.io
const sequelize = require("./config/database");
const authRoute = require("./routes/auth_route");
const userRoleRoute = require("./routes/user_rol_route");
const carouselRoute = require("./routes/carousel_images_route");

const app = express();
const port = process.env.PORT || 3000;

// Crear servidor HTTP
const server = http.createServer(app);

// Configurar WebSocket con CORS
const io = new Server(server, {
  cors: {
    origin: process.env.FRONTEND_URL, // Permitir conexiones desde el frontend
    credentials: true
  }
});

// Middleware global
app.use(express.json());
app.use(cors({ origin: process.env.FRONTEND_URL, credentials: true }));

// Servir archivos estáticos (imágenes)
app.use('/uploads/carousel_images', express.static(path.join(__dirname, 'uploads', 'carousel_images')));

// Rutas
app.use('/api/auth', authRoute);
app.use('/api/user', userRoleRoute);
app.use('/api/carousel', carouselRoute);

// WebSockets: escuchar conexiones
io.on("connection", (socket) => {
  console.log("🟢 Cliente conectado a WebSocket");

  socket.on("disconnect", () => {
    console.log("🔴 Cliente desconectado");
  });
});

// Exponer io para usarlo en otros archivos
app.set("io", io);

// Conectar con la base de datos y sincronizar
sequelize.sync()
  .then(() => {
    console.log("Conectado a la base de datos y sincronizado");
    server.listen(port, () => { // Iniciar el servidor con WebSocket
      console.log(`🚀 Servidor corriendo en http://localhost:${port}`);
    });
  })
  .catch((err) => console.error("Error al conectar a la DB:", err));
