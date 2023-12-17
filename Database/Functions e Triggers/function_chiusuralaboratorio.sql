CREATE FUNCTION az.ChiusuraLaboratorio() RETURNS TRIGGER AS
$$
DECLARE

BEGIN

UPDATE az.Laboratorio AS L
SET L.ResponsabileScientifico = NULL,
Aperto = 'N'
WHERE L.ResponsabileScientifico = OLD.CodImpiegato;

RETURN NEW;

END
$$ LANGUAGE plpgsql;