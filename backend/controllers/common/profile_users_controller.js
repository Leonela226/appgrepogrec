
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


module.exports = { getUser };