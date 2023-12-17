CREATE FUNCTION az.ScattiDiCarriera() RETURNS TRIGGER AS
$$
DECLARE

BEGIN

INSERT INTO az.ScattiDiCarriera(
SELECT I.CodImpiegato, I.Nome, I.Cognome, I.Tipo, I.Grado, I.Stipendio,
EXTRACT(YEAR FROM CURRENT_DATE)
FROM az.Impiegato AS I
WHERE I.CodImpiegato = NEW.CodImpiegato AND OLD.Grado <> NEW.Grado);

RETURN NEW;
END

$$ LANGUAGE plpgsql;