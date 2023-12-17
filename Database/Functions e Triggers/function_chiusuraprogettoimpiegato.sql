CREATE FUNCTION az.ChiusuraProgettoImpiegato() RETURNS TRIGGER AS
$$
DECLARE

ImpiegatoCancellato az.Impiegato.CodImpiegato%Type;

BEGIN

SELECT I.CodImpiegato INTO ImpiegatoCancellato
FROM az.Impiegato AS I
WHERE I.CodImpiegato = OLD.CodImpiegato;

IF(ImpiegatoCancellato = ReferenteScientifico) THEN
    UPDATE az.Progetto AS P
    SET P.ReferenteScientifico = NULL, P.Attivo = 'N'
    WHERE P.ReferenteScientifico = OLD.CodImpiegato;
END IF;

IF(ImpiegatoCancellato = Responsabile) THEN
    UPDATE az.Progetto AS P
    SET P.Responsabile = NULL, P.Attivo = 'N'
    WHERE P.Responsabile = OLD.CodImpiegato;
END IF;

RETURN NEW;

END
$$ LANGUAGE plpgsql;