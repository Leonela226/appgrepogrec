
CREATE DATABASE nappgrec;

USE nappgrec;

SELECT DATABASE();

SHOW DATABASES;


CREATE TABLE permissions(
    id_permission INT AUTO_INCREMENT PRIMARY KEY,
    name_permission VARCHAR(50) NOT NULL, /*tipo de permiso*/
    description_permission VARCHAR(100), /*descripción del permiso*/
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  /* Fecha de creación del registro */
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP  /*Fecha de última actualización */
);

CREATE TABLE roles(
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    name_rol VARCHAR(50) NOT NULL, /*tipo de rol*/
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, /*Fecha de creación del registro*/
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP /*Fecha de última actualización*/
);

CREATE TABLE roles_permissions(
    id_rol_permission INT AUTO_INCREMENT PRIMARY KEY,
    id_rol INT, /*relaciona el rol */
    id_permission INT, /*relaciona el permiso */
    FOREIGN KEY (id_rol) REFERENCES roles(id_rol),
    FOREIGN KEY (id_permission) REFERENCES permissions(id_permission),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, /*Fecha de creación del registro */
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- Fecha de última actualización */
);

CREATE TABLE carousel_images (
  id_carousel_image INT AUTO_INCREMENT PRIMARY KEY,
  url_carousel_image VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


CREATE TABLE city(
    id_city INT AUTO_INCREMENT PRIMARY KEY,
    name_city VARCHAR(50) NOT NULL, /* nombre de la ciudad */
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, /* Fecha de creación del registro */
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP /*Fecha de última actualización */
);

CREATE TABLE businesses(
    id_business INT AUTO_INCREMENT PRIMARY KEY,
    name_business VARCHAR(50) NOT NULL, /*nombre de la unidad de negocio*/
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, /*Fecha de creación del registro*/
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP /*Fecha de última actualización*/
);

CREATE TABLE branches(
    id_branch INT AUTO_INCREMENT PRIMARY KEY,
    name_branch VARCHAR(50) NOT NULL, /* nombre de la sucursal*/
    direccion_branch VARCHAR(200), /* dirección de la sucursal*/
    id_city INT, /* relaciona la ciudad con la sucursal*/
    id_business INT, /* realaciona la unidad de negocio con la sucursal*/
    FOREIGN KEY (id_city) REFERENCES city(id_city),
    FOREIGN KEY (id_business) REFERENCES businesses(id_business),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, /*Fecha de creación del registro*/
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP /*Fecha de última actualización*/
);

CREATE TABLE users (
    id_user INT AUTO_INCREMENT PRIMARY KEY,              -- Identificador único en la base de datos
    name_user VARCHAR(150) NOT NULL,                       -- Nombre del usuario
    email_user VARCHAR(150) NOT NULL UNIQUE,              -- Correo electrónico del usuario
    firebase_uid VARCHAR(100) UNIQUE,                     -- UID alternativo si el usuario se autentica con otro proveedor
    profile_photo_url VARCHAR(100),                       -- URL de la foto de perfil
    phone_number VARCHAR(20),                             -- Número de teléfono del usuario 
    date_birth DATE,                                      -- Fecha de nacimiento del usuario
    status_user ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo',  -- Estado del usuario (activo o inactivo)
    id_rol INT,                                           -- Relación con la tabla de roles
    FOREIGN KEY (id_rol) REFERENCES roles(id_rol),        -- Referencia a la tabla de roles
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,       -- Fecha de creación del registro
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- Fecha de última actualización
);



CREATE TABLE giveaways(
    id_giveaway INT AUTO_INCREMENT PRIMARY KEY,
    code_giveaway VARCHAR(100) UNIQUE, /*código relacionado con la creaación del código qr*/
    name_giveaway VARCHAR(100) NOT NULL, /* nombre del sorteo*/
    image_url VARCHAR(100),
    description_giveaway TEXT, /* descripción del sorteo*/
    start_date_giveaway DATE, /* Inicio del periodo de participación*/
    end_date_giveaway DATE, /* Fin del periodo de participación*/
    draw_date_giveaway DATE, /* Momento exacto del sorteo*/
    id_branch INT,
    status_giveaway ENUM('pendiente', 'activo', 'realizado', 'cancelado') NOT NULL DEFAULT 'activo', /*Estado del sorteo*/
    prize_count INT NOT NULL,  /*total de premios que se sortearán en el evento, (puede ser 1 o más)*/
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, /*Fecha de creación del registro*/
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP /*Fecha de última actualización*/
);

CREATE TABLE codes_qr(
    id_codes_qr INT AUTO_INCREMENT PRIMARY KEY,
    value_code_qr VARCHAR(100) NOT NULL UNIQUE,
    code_giveaway VARCHAR(100) NOT NULL, /*relaciona el código QR con el sorteo*/
    FOREIGN KEY (code_giveaway) REFERENCES giveaways(code_giveaway),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, /*Fecha de creación del registro*/
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP /*Fecha de última actualización*/
);

    
CREATE TABLE prizes(
    id_prize INT AUTO_INCREMENT PRIMARY KEY,
    name_prize VARCHAR(100) NOT NULL,
    description_prize TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, /*Fecha de creación del registro*/
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP /*Fecha de última actualización*/
);

CREATE TABLE giveaways_prizes(
    id_giveaway_prize INT AUTO_INCREMENT PRIMARY KEY,
    id_giveaway INT,
    id_prize INT,
    rank INT, /* Indica el orden (1=primer lugar, 2=segundo lugar, etc.)*/
    FOREIGN KEY (id_giveaway) REFERENCES giveaways(id_giveaway),
    FOREIGN KEY (id_prize) REFERENCES prizes(id_prize),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, /* Fecha de creación del registro*/
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP /* Fecha de última actualización */
);

CREATE TABLE participations(
    id_participation INT AUTO_INCREMENT PRIMARY KEY,
    id_user INT,
    id_codes_qr INT,
    participation_date DATETIME DEFAULT CURRENT_TIMESTAMP, /* momento de la participación */
    FOREIGN KEY (id_user) REFERENCES users(id_user),
    FOREIGN KEY (id_codes_qr) REFERENCES codes_qr(id_codes_qr),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, /*  Fecha de creación del registro*/
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP /*  Fecha de última actualización*/
);

CREATE TABLE participations_prizes(
    id_participation_prize INT AUTO_INCREMENT PRIMARY KEY,
    id_participation INT,
    id_giveaway_prize  INT,
    FOREIGN KEY (id_participation) REFERENCES participations(id_participation),
    FOREIGN KEY (id_giveaway_prize) REFERENCES giveaways_prizes(id_giveaway_prize),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, /* Fecha de creación del registro */
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP /* Fecha de última actualización */
);
