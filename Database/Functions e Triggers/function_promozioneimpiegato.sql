CREATE FUNCTION az.PromozioneImpiegato() RETURNS TRIGGER AS
$$
DECLARE

Imp az.Impiegato.CodImpiegato%Type;

BEGIN
SELECT I.CodImpiegato INTO Imp
FROM az.Impiegato AS I
WHERE I.CodImpiegato = NEW.CodImpiegato;

UPDATE az.Impiegato AS I
SET I.Grado = NULL
WHERE I.CodImpiegato = Imp AND OLD.Tipo = 'Dipendente' AND NEW.Tipo = 'Dirigente';

RETURN NEW;

END
$$ LANGUAGE plpgsql;