CREATE FUNCTION az.ProgettoAttivo() RETURNS TRIGGER AS
$$
DECLARE

RefScientifico az.Impiegato.CodImpiegato%Type;
Resp az.Impiegato.CodImpiegato%Type;
PrimoLaboratorio az.Laboratorio.CodLab%Type;
SecondoLaboratorio az.Laboratorio.CodLab%Type;
TerzoLaboratorio az.Laboratorio.CodLab%Type;

BEGIN

SELECT P.ReferenteScientifico, P.Responsabile, P.Lab1, P.Lab2, P.Lab3
INTO RefScientifico, Resp, PrimoLaboratorio, SecondoLaboratorio, TerzoLaboratorio
FROM az.Progetto AS P
WHERE P.CUP = NEW.CUP;

IF ((RefScientifico = NULL OR Resp = NULL) OR (PrimoLaboratorio = NULL
AND SecondoLaboratorio = NULL AND TerzoLaboratorio = NULL)) THEN
    UPDATE az.Progetto AS P
    SET Attivo = 'N'
    WHERE P.CUP = NEW.CUP;

ELSE
    UPDATE az.Progetto AS P
    SET Attivo = 'S'
    WHERE P.CUP = NEW.CUP;
END IF;

RETURN NEW;

END
$$ LANGUAGE plpgsql;