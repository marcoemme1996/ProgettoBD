CREATE OR REPLACE FUNCTION az.LaboratorioAperto() RETURNS TRIGGER AS
$$
DECLARE

BEGIN

IF(NEW.ResponsabileScientifico = NULL) THEN
    UPDATE az.Laboratorio 
    SET Aperto = 'N';

ELSE
    UPDATE az.Laboratorio 
    SET Aperto = 'S';
END IF;

RETURN NEW;

END
$$ LANGUAGE plpgsql;