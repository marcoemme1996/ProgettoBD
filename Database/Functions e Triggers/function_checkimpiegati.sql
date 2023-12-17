CREATE FUNCTION az.CheckImpiegati() RETURNS TRIGGER AS
$$
DECLARE

GradoImp az.Impiegato.Grado%Type;
TipoImp az.Impiegato.Tipo%Type;

BEGIN

SELECT I.Grado, I.Tipo INTO GradoImp, TipoImp
FROM az.Impiegato AS I
WHERE I.CodImpiegato = NEW.CodImpiegato;

IF(TipoImp = 'Dipendente' AND GradoImp = NULL) THEN
   RAISE EXCEPTION 'Non valido: deve avere un grado';
END IF;

IF(TipoImp = 'Dirigente' AND GradoImp <> NULL) THEN
   RAISE EXCEPTION 'Non valido: non deve avere un grado';
END IF;

RETURN NEW;

END
$$ LANGUAGE plpgsql;