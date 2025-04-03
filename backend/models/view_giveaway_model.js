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
        type: DataTypes.DATE,
        allowNull: true,
    },
    end_date_giveaway: {
        type: DataTypes.DATE,
        allowNull: true,
    },
    draw_date_giveaway: {
        type: DataTypes.DATE,
        allowNull: true,
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
