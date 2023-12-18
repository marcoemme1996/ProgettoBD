CREATE OR REPLACE FUNCTION az.ChiusuraLaboratorio() RETURNS TRIGGER AS
$$
DECLARE

BEGIN

UPDATE az.Laboratorio 
SET ResponsabileScientifico = NULL,
Aperto = 'N'
WHERE ResponsabileScientifico = OLD.CodImpiegato;

RETURN NEW;

END
$$ LANGUAGE plpgsql;