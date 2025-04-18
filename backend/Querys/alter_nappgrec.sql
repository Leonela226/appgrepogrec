


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
