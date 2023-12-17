CREATE TRIGGER TriggerCheckImpiegati
BEFORE INSERT ON az.Impiegato
FOR EACH ROW
EXECUTE FUNCTION az.CheckImpiegati();