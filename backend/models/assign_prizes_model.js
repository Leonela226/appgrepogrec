const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");
const Giveaway = require("./view_giveaway_model");  //   importar el modelo correctamente
const Prize = require("./prizes_model");

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
      model: 'giveaways', // Nombre de la tabla relacionada
      key: 'id_giveaway', // Nombre de la clave primaria de la tabla relacionada
    },
  },
  id_prize: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'prizes', // Nombre de la tabla relacionada
      key: 'id_prize', // Nombre de la clave primaria de la tabla relacionada
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

// Definir las relaciones
GiveawayPrize.belongsTo(Giveaway, { foreignKey: 'id_giveaway' }); // Un GiveawayPrize pertenece a un Giveaway
GiveawayPrize.belongsTo(Prize, { foreignKey: 'id_prize' }); // Un GiveawayPrize pertenece a un Prize

module.exports = GiveawayPrize;
