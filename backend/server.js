require("dotenv").config(); // Cargar variables de entorno al inicio

// Modelos y relaciones
require('./models/associations')();

const express = require("express");
const cors = require("cors");
const path = require("path");
const http = require("http"); // Para crear el servidor HTTP
const { Server } = require("socket.io"); // Importar socket.io
const sequelize = require("./config/database");
const authRoute = require("./routes/common/auth_route");
const userRoleRoute = require("./routes/common/user_rol_route");
const carouselRoute = require("./routes/admin/carousel_images_route");
const prizeRoute = require("./routes/admin/prizes_routes");
const giveawayRoute = require("./routes/admin/view_giveaway_route");
const assignRoute = require("./routes/admin/assign_prizes_route");
const scannerRoute = require("./routes/client/scanner_qr_route");
const participationRoute = require("./routes/client/participation_route");
const branchRoute = require("./routes/admin/branches_route");
const participationPrizeRoute = require("./routes/admin/participation_prize_route");
const profileUsersRoute = require("./routes/common/profile_users_route");
const cardsRoute = require("./routes/admin/cards_route");

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
//app.use('/uploads/carousel_images', express.static(path.join(__dirname, 'uploads', 'carousel_images')));
app.use("/uploads", express.static(path.join(__dirname, "uploads")));
//app.use('/uploads/prizes_images', express.static(path.join(__dirname, 'uploads', 'prizes_images')));

// Rutas admin
app.use('/api/auth', authRoute);
app.use('/api/user', userRoleRoute);
app.use('/api/carousel', carouselRoute);
app.use('/api/prizes',prizeRoute); 
app.use('/api/giveaways',giveawayRoute); 
app.use('/api/assign',assignRoute);
app.use('/api/branch', branchRoute);
app.use('/api/participationPrize', participationPrizeRoute);
app.use('/api/profileUsers', profileUsersRoute);
app.use('/api/cards', cardsRoute);


//rutas cliente
app.use('/api/scanner', scannerRoute);
app.use('/api/participation', participationRoute);


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
