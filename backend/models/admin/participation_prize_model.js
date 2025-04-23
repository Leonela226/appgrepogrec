const { DataTypes } = require("sequelize");
const sequelize = require("../../config/database");
const Participation = require("../client/participation_model");  // Importa el modelo de participaciones
const GiveawayPrize = require("../../models/admin/assign_prizes_model");  // Importa el modelo de premios

const ParticipationPrize = sequelize.define("ParticipationPrize", {
  id_participation_prize: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
    allowNull: false,
  },
  id_participation: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: Participation, // Relación con el modelo 'participations'
      key: 'id_participation',
    },
  },
  id_giveaway_prize: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: GiveawayPrize, // Relación con el modelo 'giveaways_prizes'
      key: 'id_giveaway_prize',
    },
  },
}, {
  tableName: 'participations_prizes',   // El nombre real de la tabla en la BD
  timestamps: true,                     // Sequelize manejará los timestamps
  createdAt: "created_at",              // Mapea `createdAt` a `created_at`
  updatedAt: "updated_at",              // Mapea `updatedAt` a `updated_at`
});

module.exports = ParticipationPrize;
