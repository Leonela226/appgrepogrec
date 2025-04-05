const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

const Giveaway = sequelize.define("Giveaway", {
    id_giveaway: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
    },
    name_giveaway: {
        type: DataTypes.STRING(100),
        allowNull: false,
    },
    description_giveaway: {
        type: DataTypes.TEXT,
        allowNull: true,
    },
    start_date_giveaway: {
        type: Sequelize.DATEONLY, // Asegura que solo se almacene la fecha
        allowNull: false,
    },
    end_date_giveaway: {
        type: Sequelize.DATEONLY, // Asegura que solo se almacene la fecha
        allowNull: false,
    },
    draw_date_giveaway: {
        type: Sequelize.DATEONLY, // Asegura que solo se almacene la fecha
        allowNull: false,
    },
    status_giveaway: {
        type: DataTypes.ENUM('pendiente', 'activo', 'finalizado', 'cancelado'),
        allowNull: false,
        defaultValue: 'activo',
    },
    prize_count: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
}, {
    tableName: "giveaways",
    timestamps: true,
    createdAt: "created_at",
    updatedAt: "updated_at",
});

module.exports = Giveaway;
