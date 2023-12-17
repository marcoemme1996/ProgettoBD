CREATE OR REPLACE FUNCTION SetStipendio() RETURNS TRIGGER AS
$$
DECLARE

GradoImp az.Impiegato.Grado%TYPE;
TipoImp az.Impiegato.Tipo%TYPE;
StipendioImp az.Impiegato.Stipendio%TYPE;

BEGIN

SELECT NEW.Grado, NEW.Tipo, NEW.Stipendio INTO GradoImp, TipoImp, StipendioImp
FROM az.Impiegato AS I
WHERE I.CodImpiegato = NEW.CodImpiegato;


IF (TipoImp = 'Dipendente' AND GradoImp = 'Junior' AND StipendioImp <> 5000) THEN
  UPDATE az.Impiegato AS I
  SET I.Stipendio = 5000
  WHERE I.CodImpiegato = NEW.CodImpiegato;

ELSE IF (TipoImp = 'Dipendente' AND GradoImp = 'Middle' AND StipendioImp <> 10000) THEN
  UPDATE az.Impiegato AS I
  SET I.Stipendio = 10000
  WHERE I.CodImpiegato = NEW.CodImpiegato;

ELSE IF (TipoImp = 'Dipendente' AND GradoImp = 'Senior' AND StipendioImp <> 15000) THEN
  UPDATE az.Impiegato AS I
  SET I.Stipendio = 15000
  WHERE I.CodImpiegato = NEW.CodImpiegato;

ELSE IF (TipoImp = 'Dirigente' AND StipendioImp <> 20000) THEN
  UPDATE az.Impiegato AS I
  SET I.Stipendio = 20000
  WHERE I.CodImpiegato = NEW.CodImpiegato;

END IF;

RETURN NEW;
END
$$ LANGUAGE plpgsql;