const { DataTypes } = require("sequelize");
const sequelize = require("../../config/database");
const Giveaway = require("../admin/view_giveaway_model");  //   importar el modelo correctamente
const Prize = require("../admin/prizes_model");

const GiveawayPrize = sequelize.define("GiveawayPrize", {
  id_giveaway_prize: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
    allowNull: false,
  },
  id_giveaway: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: Giveaway, // en lugar de 'giveaways'
      key: 'id_giveaway',
    },
  },
  id_prize: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: Prize, // en lugar de 'prizes'
      key: 'id_prize',
    },
  },  
  rank: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
}, {
  tableName: 'giveaways_prizes',   // El nombre real de la tabla en la BD
  timestamps: true,                // Sequelize manejará los timestamps
  createdAt: "created_at",        // Mapea `createdAt` a `created_at`
  updatedAt: "updated_at",        // Mapea `updatedAt` a `updated_at`
});

module.exports = GiveawayPrize;
