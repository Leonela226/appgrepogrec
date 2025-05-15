const { DataTypes } = require("sequelize");
const sequelize = require("../../config/database");

const Carousel = sequelize.define("Carousel", {
  id_carousel_image: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true
  },
  url_carousel_image: {
    type: DataTypes.STRING(100),
    allowNull: false
  },
}, {
  timestamps: true,
  createdAt: "created_at",
  updatedAt: "updated_at",
  tableName: "carousel_images",
});

module.exports = Carousel;

