const Branch = require("../../models/admin/branches_model"); // Ajusta la ruta si es necesario

// Obtener todas las sucursales
exports.getAllBranches = async (req, res) => {
    try {
        const branches = await Branch.findAll();
        return res.status(200).json({
            message: "Sucursales obtenidas correctamente.",
            data: branches
        });
    } catch (error) {
        console.error("Error al obtener las sucursales:", error);
        return res.status(500).json({ message: "Error al obtener las sucursales.", error: error.message });
    }
};

// Obtener una sucursal por ID
exports.getBranchById = async (req, res) => {
    const { id } = req.params;

    try {
        const branch = await Branch.findByPk(id);

        if (!branch) {
            return res.status(404).json({ message: "Sucursal no encontrada." });
        }

        return res.status(200).json({
            message: "Sucursal obtenida correctamente.",
            data: branch
        });
    } catch (error) {
        console.error("Error al obtener la sucursal:", error);
        return res.status(500).json({ message: "Error al obtener la sucursal.", error: error.message });
    }
};

