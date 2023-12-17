CREATE TRIGGER TriggerChiusuraLab
AFTER DELETE ON az.Impiegato
FOR EACH ROW
EXECUTE FUNCTION az.ChiusuraLaboratorio();