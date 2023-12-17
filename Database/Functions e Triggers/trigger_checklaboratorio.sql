CREATE TRIGGER TriggerCheckLaboratorio
BEFORE INSERT ON az.Laboratorio
FOR EACH ROW
EXECUTE FUNCTION az.CheckLaboratorio();
