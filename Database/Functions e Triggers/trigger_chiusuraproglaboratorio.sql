CREATE TRIGGER TriggerChiusuraProgLaboratorio
AFTER DELETE ON az.Laboratorio
FOR EACH ROW
EXECUTE FUNCTION az.ChiusuraProgLaboratorio();