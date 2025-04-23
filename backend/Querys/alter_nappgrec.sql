


ALTER TABLE giveaways
ADD COLUMN code_giveaway VARCHAR(100) UNIQUE AFTER id_giveaway;


ALTER TABLE codes_qr DROP FOREIGN KEY codes_qr_ibfk_1;
ALTER TABLE codes_qr DROP COLUMN id_giveaway;



ALTER TABLE codes_qr
ADD COLUMN code_giveaway VARCHAR(100) NOT NULL AFTER value_code_qr;

ALTER TABLE codes_qr
ADD CONSTRAINT fk_code_qr_giveaway
FOREIGN KEY (code_giveaway) REFERENCES giveaways(code_giveaway);

ALTER TABLE codes_qr
ADD CONSTRAINT unique_value_code_qr UNIQUE (value_code_qr);

-- 1. Agregar la columna en la posición deseada
ALTER TABLE giveaways
ADD COLUMN id_branch INT AFTER draw_date_giveaway;

-- 2. Agregar la clave foránea
ALTER TABLE giveaways
ADD FOREIGN KEY (id_branch) REFERENCES branches(id_branch);


-- Desactivar restricciones de claves foráneas temporalmente
SET FOREIGN_KEY_CHECKS = 0;

-- Truncar todas las tablas (reemplazá por tus tablas reales)
TRUNCATE TABLE permissions;
TRUNCATE TABLE roles;
TRUNCATE TABLE roles_permissions;
TRUNCATE TABLE carousel_images;
TRUNCATE TABLE city;
TRUNCATE TABLE businesses;
TRUNCATE TABLE branches;
TRUNCATE TABLE users;
TRUNCATE TABLE giveaways;
TRUNCATE TABLE codes_qr;
TRUNCATE TABLE prizes;
TRUNCATE TABLE giveaways_prizes;
TRUNCATE TABLE participations;
TRUNCATE TABLE participations_prizes;
TRUNCATE TABLE winners;




SHOW CREATE TABLE participations_prizes;

-- 1. Eliminar la clave foránea
ALTER TABLE participations_prizes
DROP FOREIGN KEY participations_prizes_ibfk_2;

-- 2. Eliminar la columna
ALTER TABLE participations_prizes
DROP COLUMN id_prize;



-- Esto genera los comandos DROP automáticamente
SELECT CONCAT('DROP TABLE `', table_name, '`;')
FROM information_schema.tables
WHERE table_schema = 'nappgrec';

SET FOREIGN_KEY_CHECKS = 1;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE `participations_prizes`;
SET FOREIGN_KEY_CHECKS = 1;


SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE `branches`;
DROP TABLE `businesses`;
DROP TABLE `carousel_images`;
DROP TABLE `city`;
DROP TABLE `codes_qr`;
DROP TABLE `giveaways`;
DROP TABLE `giveaways_prizes`;
DROP TABLE `participations`;
DROP TABLE `participations_prizes`;
DROP TABLE `permissions`;
DROP TABLE `prizes`;
DROP TABLE `roles`;
DROP TABLE `roles_permissions`;
DROP TABLE `users`;
DROP TABLE `winners`;
SET FOREIGN_KEY_CHECKS = 1;