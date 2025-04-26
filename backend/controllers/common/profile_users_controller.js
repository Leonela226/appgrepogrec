
const User = require('../../models/common/user_model');
// Obtener un usuario por ID
// Obtener el id_user basado en el firebase_uid
const getUser = async (req, res) => {
  try {
    const { firebase_uid } = req.params;
    const user = await User.findOne({ where: { firebase_uid } });

    if (!user) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }

    //console.log('Usuario encontrado:', user);

    res.json({
      id: user.id_user,
      name: user.name_user,
      email: user.email_user,
      phone: user.phone_number,
      birthDate: user.date_birth,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error al obtener los datos del usuario' });
  }
};

// Actualizar los datos del usuario
const updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const { name_user, email_user, phone_number, date_birth } = req.body;

    const user = await User.findByPk(id);

    if (!user) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }

    await user.update({
      name_user,
      email_user,
      phone_number,
      date_birth,
    });

    res.json({ message: 'Usuario actualizado correctamente' });
  } catch (error) {
    console.error('Error al actualizar usuario:', error);
    res.status(500).json({ message: 'Error al actualizar el usuario' });
  }
};

module.exports = {
  getUser,
  updateUser, 
};
