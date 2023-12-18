CREATE OR REPLACE FUNCTION az.ChiusuraProgLaboratorio() RETURNS TRIGGER AS
$$
DECLARE

LabCancellato az.Laboratorio.CodLab%Type;
PrimoLaboratorio az.Laboratorio.CodLab%Type;
SecondoLaboratorio az.Laboratorio.CodLab%Type;
TerzoLaboratorio az.Laboratorio.CodLab%Type;

BEGIN

SELECT L.CodLab, P.Lab1, P.Lab2, P.Lab3 INTO LabCancellato, PrimoLaboratorio, SecondoLaboratorio, TerzoLaboratorio
FROM az.Laboratorio AS L JOIN az.Progetto AS P ON L.CodLab = P.Lab1 OR L.CodLab = P.Lab2 OR L.CodLab = P.Lab3  
WHERE L.CodLab = OLD.CodLab;

IF(LabCancellato = PrimoLaboratorio AND SecondoLaboratorio = NULL AND
TerzoLaboratorio = NULL) THEN
    UPDATE az.Progetto AS P
    SET P.Lab1 = NULL, P.Attivo = 'N'
    WHERE P.Lab1 = OLD.CodLab;
END IF;

IF(LabCancellato = SecondoLaboratorio AND PrimoLaboratorio = NULL AND
TerzoLaboratorio = NULL) THEN
    UPDATE az.Progetto AS P
    SET P.Lab2 = NULL, P.Attivo = 'N'
    WHERE P.Lab2 = OLD.CodLab;
END IF;

IF(LabCancellato = TerzoLaboratorio AND PrimoLaboratorio = NULL AND
SecondoLaboratorio = NULL) THEN
    UPDATE az.Progetto AS P
    SET P.Lab3 = NULL, P.Attivo = 'N'
    WHERE P.Lab3 = OLD.CodLab;
END IF;

RETURN NEW;

END
$$ LANGUAGE plpgsql;