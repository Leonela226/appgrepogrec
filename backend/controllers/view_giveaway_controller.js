const Giveaway = require("../models/view_giveaway_model");

// Crear un nuevo sorteo
exports.createGiveaway = async (req, res) => {
    const { name_giveaway, description_giveaway, start_date_giveaway, end_date_giveaway, draw_date_giveaway, status_giveaway, prize_count } = req.body;
    
    if (!name_giveaway || !prize_count) {
        return res.status(400).json({ message: "Faltan datos requeridos." });
    }
    
    try {
        const newGiveaway = await Giveaway.create({
            name_giveaway,
            description_giveaway,
            start_date_giveaway,
            end_date_giveaway,
            draw_date_giveaway,
            status_giveaway,
            prize_count
        });
        return res.status(201).json({
            message: "Sorteo creado correctamente.",
            data: newGiveaway
        });
    } catch (error) {
        console.error("Error al crear el sorteo:", error);
        return res.status(500).json({ message: "Error al guardar el sorteo en la base de datos.", error: error.message });
    }
};

// Obtener todos los sorteos
exports.getAllGiveaways = async (req, res) => {
    try {
        const giveaways = await Giveaway.findAll();
        return res.status(200).json({
            message: "Sorteos obtenidos correctamente.",
            data: giveaways
        });
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: "Error al obtener los sorteos.", error: error.message });
    }
};

