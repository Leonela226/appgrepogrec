const { DataTypes } = require("sequelize");
const sequelize = require("../../config/database");

const User = require("../../models/common/user_model");
const CodeQR = require("../../models/client/scanner_qr_model");

const Participation = sequelize.define("Participation", {
  id_participation: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  id_user: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  id_codes_qr: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  participation_date: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
}, {
  tableName: "participations",
  timestamps: true,
  createdAt: "created_at", 
  updatedAt: "updated_at"  
});

module.exports = Participation;
