CREATE TRIGGER TriggerProgettoAttivo
BEFORE INSERT ON az.Progetto
FOR EACH ROW
EXECUTE FUNCTION az.ProgettoAttivo();