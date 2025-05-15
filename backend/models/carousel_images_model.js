const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

const Carousel = sequelize.define("Carousel", {
  id_carousel_image: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  url_carousel_image: {
    type: DataTypes.STRING(255),
    allowNull: false
  },
  title_carousel_image: {
    type: DataTypes.STRING(100),
    allowNull: true,
    validate: {
      len: {
        args: [0, 100],
        msg: "El título no puede tener más de 100 caracteres."
      }
    }
  },
  description_carousel_image: {
    type: DataTypes.TEXT,
    allowNull: true
  }
}, {
  timestamps: true,           // Sequelize manejará los timestamps
  createdAt: "created_at",    // Mapea `createdAt` a `created_at`
  updatedAt: "updated_at",    // Mapea `updatedAt` a `updated_at`
  tableName: "carousel_images" // Nombre real de la tabla en la BD
});

module.exports = Carousel;
