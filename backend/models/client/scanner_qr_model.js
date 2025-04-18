const { DataTypes } = require("sequelize");
const sequelize = require("../../config/database");
const Giveaway = require("../../models/admin/view_giveaway_model"); // Asegúrate de importar el modelo correcto

const CodeQR = sequelize.define("CodeQR", {
  id_codes_qr: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true,
    allowNull: false
  },
  value_code_qr: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true
  },
  code_giveaway: {
    type: DataTypes.STRING(100), 
    allowNull: false,
    references: {
      model: Giveaway,
      key: "code_giveaway"  
    }
  }
}, {
  tableName: "codes_qr",      // Nombre exacto de la tabla en la base de datos
  timestamps: true,           // Activa created_at y updated_at
  createdAt: "created_at",    // Mapea createdAt a created_at
  updatedAt: "updated_at"     // Mapea updatedAt a updated_at
});

// Relación: un código QR pertenece a un sorteo
CodeQR.belongsTo(Giveaway, { foreignKey: "code_giveaway" });

module.exports = CodeQR;
