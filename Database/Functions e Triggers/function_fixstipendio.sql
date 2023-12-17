CREATE OR REPLACE FUNCTION az.FixStipendio() RETURNS TRIGGER AS
$$
DECLARE
TipoImp az.Impiegato.Tipo%TYPE;
GradoImp az.Impiegato.Grado%TYPE;

BEGIN
SELECT I.Grado, I.Tipo INTO GradoImp, TipoImp
FROM az.Impiegato AS I
WHERE OLD.Grado <> NEW.Grado OR OLD.Tipo <> NEW.Tipo;

IF ((OLD.Tipo = 'Dirigente' AND NEW.Tipo = 'Dipendente') OR (OLD.Grado = 'Senior' AND (NEW.Grado = 'Junior' OR NEW.Grado = 'Middle')) OR (OLD.Grado = 'Middle' AND NEW.Grado = 'Junior')) THEN
  RAISE EXCEPTION 'Passaggio non valido';

ELSE
  IF (OLD.Tipo = 'Dipendente' AND NEW.Tipo = 'Dipendente') THEN
  UPDATE az.Impiegato AS I
  SET I.Stipendio = I.Stipendio + 5000
  WHERE OLD.CodImpiegato = NEW.CodImpiegato;

  ELSE IF (OLD.Tipo = 'Dipendente' AND NEW.Tipo = 'Dirigente') THEN
  UPDATE az.Impiegato AS I
  SET I.Stipendio = 20000
  WHERE OLD.CodImpiegato = NEW.CodImpiegato;

  END IF;
END IF;

RETURN NEW;

END
$$ LANGUAGE plpgsql;