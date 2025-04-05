const Giveaway = require("../models/view_giveaway_model");
const { Op } = require('sequelize'); // Importar el operador para comparar fechas si es necesario

// Crear un nuevo sorteo
exports.createGiveaway = async (req, res) => {
    const { name, description, start_date, end_date, draw_date, prize_count } = req.body;

    // Validar campos requeridos
    if (!name || !prize_count || !start_date || !end_date || !draw_date) {
        return res.status(400).json({ message: "Faltan datos requeridos." });
    }

    // Validar formato de fechas
    const startDate = new Date(start_date);
    const endDate = new Date(end_date);
    const drawDate = new Date(draw_date);

    // Comprobar si las fechas son válidas
    if (isNaN(startDate.getTime()) || isNaN(endDate.getTime()) || isNaN(drawDate.getTime())) {
        return res.status(400).json({ message: "Las fechas proporcionadas no son válidas." });
    }

    // Obtener solo la parte de la fecha (sin la hora)
    const startDateFormatted = startDate.toISOString().split('T')[0]; // yyyy-mm-dd
    const endDateFormatted = endDate.toISOString().split('T')[0]; // yyyy-mm-dd
    const drawDateFormatted = drawDate.toISOString().split('T')[0]; // yyyy-mm-dd

    try {
        // Obtener la fecha actual
        const currentDate = new Date();

        // Determinar el estado del sorteo
        const status = startDate <= currentDate ? 'activo' : 'pendiente';

        // Crear el nuevo sorteo con las fechas formateadas
        const newGiveaway = await Giveaway.create({
            name_giveaway: name,
            description_giveaway: description,
            start_date_giveaway: startDateFormatted,
            end_date_giveaway: endDateFormatted,
            draw_date_giveaway: drawDateFormatted,
            status_giveaway: status,
            prize_count: prize_count
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

// Obtener un sorteo por ID
exports.getGiveawayById = async (req, res) => {
    const { id } = req.params;

    try {
        const giveaway = await Giveaway.findByPk(id);
        
        if (!giveaway) {
            return res.status(404).json({ message: "Sorteo no encontrado." });
        }

        return res.status(200).json({
            message: "Sorteo obtenido correctamente.",
            data: giveaway
        });
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: "Error al obtener el sorteo.", error: error.message });
    }
};
