const { DataTypes } = require("sequelize");
const sequelize = require("../../config/database");
const Branch = require("../admin/branches_model");
const CodeQR = require("../client/scanner_qr_model");
const GiveawayPrize = require("../admin/assign_prizes_model");

const Giveaway = sequelize.define("Giveaway", {
    id_giveaway: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
    },
    code_giveaway: {
        type: DataTypes.STRING(100),
        allowNull: false,  // O true si no es obligatorio al crear
        unique: true,  // Aseguramos que cada código sea único
    },
    name_giveaway: {
        type: DataTypes.STRING(100),
        allowNull: false,
    },
    image_url: {
        type: DataTypes.STRING(100),
        allowNull: true,
    },
    description_giveaway: {
        type: DataTypes.TEXT,
        allowNull: true,
    },
    start_date_giveaway: {
        type: DataTypes.DATEONLY, 
        allowNull: false,
    },
    end_date_giveaway: {
        type: DataTypes.DATEONLY, 
        allowNull: false,
    },
    draw_date_giveaway: {
        type: DataTypes.DATEONLY, 
        allowNull: false,
    },
    id_branch: {
        type: DataTypes.INTEGER,
        allowNull: true // o false si  es obligatorio
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
    created_at: {
        type: DataTypes.DATE,
        allowNull: false,
    },
    updated_at: {
        type: DataTypes.DATE,
        allowNull: false,
    },
}, {
    tableName: "giveaways",
    timestamps: true,
    createdAt: "created_at",
    updatedAt: "updated_at",
});


module.exports = Giveaway;


