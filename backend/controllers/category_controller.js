const Category = require("../models/category_model");

// Crear una nueva categoría
const createCategory = async (req, res) => {
  try {
    const { name_category } = req.body;

    // Validar que el nombre de la categoría no esté vacío
    if (!name_category) {
      return res.status(400).json({ message: "El nombre de la categoría es obligatorio." });
    }

    // Crear la categoría (Si la categoría ya existe, Sequelize lanzará un error)
    const newCategory = await Category.create({ name_category });

    return res.status(201).json(newCategory);
  } catch (error) {
    console.error(error);

    // Si el error es un error de unicidad
    if (error.name === 'SequelizeUniqueConstraintError') {
      return res.status(400).json({ message: 'La categoría con ese nombre ya existe.' });
    }

    return res.status(500).json({ message: "Error al crear la categoría." });
  }
};

// Obtener una categoría por su ID
const getCategoryById = async (req, res) => {
  try {
    const { id_category } = req.params;

    // Buscar la categoría por ID
    const category = await Category.findByPk(id_category);

    if (!category) {
      return res.status(404).json({ message: "Categoría no encontrada." });
    }

    return res.status(200).json(category);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Error al obtener la categoría." });
  }
};

// Obtener todas las categorías
const getAllCategories = async (req, res) => {
  try {
    const categories = await Category.findAll();
    return res.status(200).json(categories);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Error al obtener las categorías." });
  }
};

// Actualizar una categoría
const updateCategory = async (req, res) => {
  try {
    const { id_category } = req.params;
    const { name_category } = req.body;

    // Buscar la categoría por ID
    const category = await Category.findByPk(id_category);

    if (!category) {
      return res.status(404).json({ message: "Categoría no encontrada." });
    }

    // Actualizar el nombre de la categoría
    category.name_category = name_category || category.name_category;
    await category.save();

    return res.status(200).json(category);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Error al actualizar la categoría." });
  }
};

// Eliminar una categoría
const deleteCategory = async (req, res) => {
  try {
    const { id_category } = req.params;

    // Buscar la categoría por ID
    const category = await Category.findByPk(id_category);

    if (!category) {
      return res.status(404).json({ message: "Categoría no encontrada." });
    }

    // Eliminar la categoría
    await category.destroy();

    return res.status(200).json({ message: "Categoría eliminada correctamente." });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: "Error al eliminar la categoría." });
  }
};

module.exports = {
  createCategory,
  getCategoryById,
  getAllCategories,
  updateCategory,
  deleteCategory
};
