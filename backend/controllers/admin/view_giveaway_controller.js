const multer = require('multer');
const path = require('path');
const fs = require('fs');
const crypto = require('crypto');  // Para generar cadenas alfanuméricas aleatorias
const Giveaway = require("../../models/admin/view_giveaway_model");

// Configuración de almacenamiento para multer
const storage = multer.diskStorage({
    destination: async (req, file, cb) => {
        const dir = path.join(__dirname, '..', 'uploads', 'giveaway_images');
        try {
            await fs.promises.mkdir(dir, { recursive: true });  // Crear el directorio si no existe
            cb(null, dir);
        } catch (error) {
            console.error("Error al crear el directorio:", error);
            cb(new Error("No se pudo crear el directorio para las imágenes de los sorteos."));
        }
    },
    filename: (req, file, cb) => {
        const ext = path.extname(file.originalname).toLowerCase(); // Asegurar extensión en minúsculas
        const filename = `${Date.now()}${ext}`;
        cb(null, filename);
    }
});

// Configuración de multer con un límite de tamaño y filtro de tipos de archivo
const upload = multer({
    storage: storage,
    limits: { fileSize: 10 * 1024 * 1024 }, // Limitar tamaño a 10 MB
    fileFilter: (req, file, cb) => {
        //console.log("Tipo MIME recibido:", file.mimetype); // Log para verificar el tipo MIME
        const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'];
        if (allowedTypes.includes(file.mimetype)) {
            cb(null, true);
        } else {
            cb(new Error('Solo se permiten imágenes de tipo JPEG, PNG o GIF'), false);
        }
    }
});

exports.createGiveaway = async (req, res) => {
    upload.single('giveaway_image')(req, res, async (err) => {
        if (err instanceof multer.MulterError) {
            console.error("MulterError:", err);  // Log para errores de Multer
            return res.status(400).json({ message: "Error al cargar la imagen del sorteo.", error: err.message });
        } else if (err) {
            console.error("Error general en Multer:", err);  // Log para errores generales
            return res.status(500).json({ message: "Error interno del servidor.", error: err.message });
        }

        if (!req.file) {
            return res.status(400).json({ message: "No se ha cargado ninguna imagen del sorteo." });
        }

        // Logs para depuración
       // console.log("Body recibido:", req.body);
        //console.log("Archivo recibido:", req.file);

        const { name, description, start_date, end_date, draw_date, prize_count } = req.body;

        if (!name || !prize_count || !start_date || !end_date || !draw_date) {
            return res.status(400).json({ message: "Faltan datos requeridos." });
        }

        try {
            // Verificar existencia por nombre
            const existingGiveaway = await Giveaway.findOne({ where: { name_giveaway: name.trim() } });
            if (existingGiveaway) {
                return res.status(400).json({ message: "El sorteo ya existe." });
            }

            const startDate = new Date(start_date);
            const endDate = new Date(end_date);
            const drawDate = new Date(draw_date);

            if (isNaN(startDate) || isNaN(endDate) || isNaN(drawDate)) {
                return res.status(400).json({ message: "Las fechas proporcionadas no son válidas." });
            }

            const formattedStart = startDate.toISOString().split('T')[0];
            const formattedEnd = endDate.toISOString().split('T')[0];
            const formattedDraw = drawDate.toISOString().split('T')[0];
            const currentDate = new Date();
            const status = startDate <= currentDate ? 'activo' : 'pendiente';

            // Generar el code_giveaway
            const code_giveaway = generateGiveawayCode(name.trim(), currentDate.getFullYear());

            const newGiveaway = await Giveaway.create({
                name_giveaway: name.trim(),
                image_url: req.file.filename,
                description_giveaway: description,
                start_date_giveaway: formattedStart,
                end_date_giveaway: formattedEnd,
                draw_date_giveaway: formattedDraw,
                status_giveaway: status,
                prize_count: prize_count,
                code_giveaway: code_giveaway  // Asignar el código generado
            });

            return res.status(201).json({
                message: "Sorteo creado correctamente.",
                data: newGiveaway
            });

        } catch (error) {
            console.error("Error al crear el sorteo:", error);  // Log completo del error
            if (error.name === 'SequelizeValidationError') {
                return res.status(400).json({
                    message: "Error de validación en la base de datos.",
                    error: error.errors.map(e => e.message)  // Mensajes de error de validación
                });
            }
            return res.status(500).json({
                message: "Error al guardar el sorteo en la base de datos.",
                error: error.message,
                stack: error.stack  // Registra el stack trace para más detalles
            });
        }
    });
};

// Generar el código del sorteo
function generateGiveawayCode(name, year) {
    const firstLetters = name.slice(0, 2).toUpperCase();  // Tomamos las primeras dos letras del nombre
    const randomString = crypto.randomBytes(3).toString('hex').toUpperCase();  // Generar cadena aleatoria
    return `${firstLetters}${year}${randomString}`;
}


// Obtener todos los sorteos con fechas formateadas
exports.getAllGiveaways = async (req, res) => {
    try {
        const giveaways = await Giveaway.findAll();

        // Función auxiliar para formatear fechas
        const formatDate = (val) => val ? new Date(val).toISOString().split('T')[0] : null;

        const formatted = giveaways.map(g => {
            const gData = g.toJSON();

            return {
                ...gData,
                id_giveaway: gData.id_giveaway,
                name_giveaway: gData.name_giveaway,
                start_date_giveaway: formatDate(gData.start_date_giveaway),
                end_date_giveaway: formatDate(gData.end_date_giveaway),
                draw_date_giveaway: formatDate(gData.draw_date_giveaway),
                prize_count: gData.prize_count,
                status_giveaway: gData.status_giveaway,
                code_giveaway: gData.code_giveaway  
            };
        });

        return res.status(200).json({
            message: "Sorteos obtenidos correctamente.",
            data: formatted
        });
    } catch (error) {
        console.error("Error al obtener los sorteos:", error);
        return res.status(500).json({ message: "Error al obtener los sorteos.", error: error.message });
    }
};

// Obtener un sorteo por ID con fechas formateadas
exports.getGiveawayById = async (req, res) => {
    const { id } = req.params;

    // Función auxiliar para formatear fechas
    const formatDate = (val) => val ? new Date(val).toISOString().split('T')[0] : null;

    try {
        const giveaway = await Giveaway.findByPk(id);

        if (!giveaway) {
            return res.status(404).json({ message: "Sorteo no encontrado." });
        }

        const gData = giveaway.toJSON();
        const formatted = {
            ...gData,
            id_giveaway: gData.id_giveaway,
            name_giveaway: gData.name_giveaway,
            start_date_giveaway: formatDate(gData.start_date_giveaway),
            end_date_giveaway: formatDate(gData.end_date_giveaway),
            draw_date_giveaway: formatDate(gData.draw_date_giveaway),
            prize_count: gData.prize_count,
            status_giveaway: gData.status_giveaway,
            code_giveaway: gData.code_giveaway 
        };

        return res.status(200).json({
            message: "Sorteo obtenido correctamente.",
            data: formatted
        });
    } catch (error) {
        console.error("Error al obtener el sorteo:", error);
        return res.status(500).json({ message: "Error al obtener el sorteo.", error: error.message });
    }
};
