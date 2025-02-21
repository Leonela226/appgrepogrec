require('dotenv').config(); // Carga las variables de entorno

const { Sequelize } = require('sequelize');

const sequelize = new Sequelize(
  process.env.DB_NAME, 
  process.env.DB_USER, 
  process.env.DB_PASSWORD, 
  {
    host: process.env.DB_HOST,
    dialect: 'mysql',
    port: 3306,  // Puerto de MySQL
    logging: console.log  // Muestra consultas SQL en consola
  }
);

module.exports = sequelize; // Exportación corregida
