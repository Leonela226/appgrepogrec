const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

const User = sequelize.define("User", {
  id_user: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  firebase_uid: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
  },
  name_user: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  email_user: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
    validate: {
      isEmail: true, // Validación para asegurar que es un correo electrónico
    },
  },
  phone_number: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  date_birth: {
    type: DataTypes.DATEONLY,
    allowNull: false,
  },
  status_user: {
    type: DataTypes.ENUM("activo", "inactivo"),
    defaultValue: "activo",
  },
  id_rol: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  createdAt: {
    type: DataTypes.DATE,
    field: "created_at", // 👈 Mapea `createdAt` a `created_at`
  },
  updatedAt: {
    type: DataTypes.DATE,
    field: "updated_at", // 👈 Mapea `updatedAt` a `updated_at`
  },
}, {
  timestamps: true, // Sequelize manejará los timestamps
  tableName: "users", // Nombre real de la tabla en la BD
});

module.exports = User;
