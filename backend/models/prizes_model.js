const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

const Prize = sequelize.define("Prize", {
  id_prize: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  name_prize: {
    type: DataTypes.STRING(100),
    allowNull: false
  },
  description_prize: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  image_url: {
    type: DataTypes.STRING(500),
    allowNull: true
  }
}, {
  timestamps: true,              // Sequelize manejará los timestamps
  createdAt: "created_at",       // Mapea `createdAt` a `created_at`
  updatedAt: "updated_at",       // Mapea `updatedAt` a `updated_at`
  tableName: "prizes"            // Nombre real de la tabla en la BD
});

module.exports = Prize;
