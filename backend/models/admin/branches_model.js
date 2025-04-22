// models/branch_model.js
const { DataTypes } = require("sequelize");
const sequelize = require("../../config/database");

const Branch = sequelize.define("Branch", {
  id_branch: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  name_branch: {
    type: DataTypes.STRING,
    allowNull: false
  }
}, {
  timestamps: true,                // Sequelize manejará los timestamps
  createdAt: "created_at",         // Mapea `createdAt` a `created_at`
  updatedAt: "updated_at",         // Mapea `updatedAt` a `updated_at`
  tableName: "branches"            // Nombre real de la tabla en la BD
});

module.exports = Branch;
