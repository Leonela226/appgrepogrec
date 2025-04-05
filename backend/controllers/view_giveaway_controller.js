const Giveaway = require("../models/view_giveaway_model");
const { Op } = require('sequelize');

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

    if (isNaN(startDate.getTime()) || isNaN(endDate.getTime()) || isNaN(drawDate.getTime())) {
        return res.status(400).json({ message: "Las fechas proporcionadas no son válidas." });
    }

    // Formatear fechas a YYYY-MM-DD
    const startDateFormatted = startDate.toISOString().split('T')[0];
    const endDateFormatted = endDate.toISOString().split('T')[0];
    const drawDateFormatted = drawDate.toISOString().split('T')[0];

    try {
        const currentDate = new Date();
        const status = startDate <= currentDate ? 'activo' : 'pendiente';

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

// Obtener todos los sorteos con fechas formateadas
// Obtener todos los sorteos con fechas formateadas
exports.getAllGiveaways = async (req, res) => {
    try {
        const giveaways = await Giveaway.findAll();

        const formatted = giveaways.map(g => {
            const gData = g.toJSON();
            const formattedGiveaway = {
                ...gData,
                name_giveaway: gData.name_giveaway,
                start_date_giveaway: gData.start_date_giveaway?.toISOString().split('T')[0],
                end_date_giveaway: gData.end_date_giveaway?.toISOString().split('T')[0],
                draw_date_giveaway: gData.draw_date_giveaway?.toISOString().split('T')[0],
                prize_count: gData.prize_count,  // Asegúrate de que esto esté presente
                status_giveaway: gData.status_giveaway,
                createdAt: gData.createdAt?.toISOString().split('T')[0],
                updatedAt: gData.updatedAt?.toISOString().split('T')[0],
            };

            // Agrega un console.log para verificar las fechas formateadas
            console.log('Sorteo Formateado:', formattedGiveaway);

            return formattedGiveaway;
        });

        return res.status(200).json({
            message: "Sorteos obtenidos correctamente.",
            data: formatted
        });
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: "Error al obtener los sorteos.", error: error.message });
    }
};



// Obtener un sorteo por ID con fechas formateadas
exports.getGiveawayById = async (req, res) => {
    const { id } = req.params;

    try {
        const giveaway = await Giveaway.findByPk(id);

        if (!giveaway) {
            return res.status(404).json({ message: "Sorteo no encontrado." });
        }

        const gData = giveaway.toJSON();
        const formatted = {
            ...gData,
            start_date_giveaway: gData.start_date_giveaway?.toISOString().split('T')[0],
            end_date_giveaway: gData.end_date_giveaway?.toISOString().split('T')[0],
            draw_date_giveaway: gData.draw_date_giveaway?.toISOString().split('T')[0],
            createdAt: gData.createdAt?.toISOString().split('T')[0],
            updatedAt: gData.updatedAt?.toISOString().split('T')[0],
        };

        return res.status(200).json({
            message: "Sorteo obtenido correctamente.",
            data: formatted
        });
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: "Error al obtener el sorteo.", error: error.message });
    }
};
