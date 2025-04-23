
SHOW DATABASES;

SELECT DATABASE();

USE nappgrec;

INSERT INTO roles (name_rol)
VALUES ('Administrador'),
        ('cliente');

INSERT INTO permissions (name_permission)
VALUES ('Acceder al panel de administración'),
       ('Acceder al panel de clientes'),
       ('Crear contenido'),
       ('Editar contenido'),
       ('Actualizar contenido'),
       ('Eliminar contenido'),
       ('Editar usuarios'),
       ('Actualizar usuarios');

INSERT INTO roles_permissions (id_rol, id_permission)
VALUES 
    (1, 1),  -- Administrador tiene acceso al panel de administración
    (1, 3),  -- Administrador puede crear contenido
    (1, 4),  -- Administrador puede editar contenido
    (1, 5),  -- Administrador puede actualizar contenido
    (1, 6),  -- Administrador puede eliminar contenido
    (1, 7),  -- Administrador puede editar usuarios
    (1, 8),  -- Administrador puede actualizar usuarios
    (2, 2);  -- Cliente solo tiene acceso al panel de clientes

INSERT INTO city (name_city)
VALUES ('Choluteca'),
       ('San Lorenzo, Valle'),
       ('Nacaome, Valle');

INSERT INTO businesses (name_business)
VALUES ('Gasolineras UNO'),
       ('Gasolineras TEXACO'),
       ('Tiendas FRESSCO'),
       ('Grec Inmobiliaria');

INSERT INTO branches (name_branch, direccion_branch, id_city, id_business)
VALUES 
    ('Estación El Puente', 'Barrio la Cruz, contiguo a CEMCOL', 1, 1),
    ('Estación Miramonte', 'Colonia Miramonte, boulevard Mauricio Oliva, contiguo a bodega Herco', 1, 1),
    ('Estación Vizcaya', 'Salida a San Marcos de Colón', 1, 1),
    ('Estación PortoSur', 'Barrio Alto Verde, boulevard Tomas Zambrano', 2, 2),
    ('Estación Nacaome', 'Barrio San José contiguo al Parque los Garrobos', 3, 2),
    ('Fressco Puente', 'Barrio la Cruz, contiguo a CEMCOL', 1, 3),
    ('Fressco Miramonte', 'Colonia Miramonte, boulevard Mauricio Oliva, contiguo a bodega Herco', 1, 3),
    ('Fressco Vizcaya', 'Salida a San Marcos de Colón', 1, 3),
    ('Fressco PortoSur', 'Barrio Alto Verde, boulevard Tomas Zambrano', 2, 3),
    ('Fressco Nacaome', 'Barrio San José contiguo al Parque los Garrobos', 3, 3);


SELECT * from users;       

INSERT INTO users (
    name_user, email_user, firebase_uid, profile_photo_url,
    phone_number, date_birth, status_user, id_rol
) VALUES (
    'user admin', 'useradmin@gmail.com', 'SteUbe2DPWNYLdTMRM8N84uw92T2',
    NULL, '99000100', '2000-12-15', 'activo', 1
);

INSERT INTO users (
    name_user, email_user, firebase_uid, profile_photo_url,
    phone_number, date_birth, status_user, id_rol
) VALUES (
    'cliente', 'cliente@gmail.com', 'K4XzsDAPpsVwdtayMVgtfQ9yn532',
    NULL, '98007105', '2000-11-10', 'activo', 2
);








