CREATE TRIGGER TriggerCorreggiGrado
BEFORE INSERT ON az.Impiegato
FOR EACH ROW
EXECUTE FUNCTION az.CorreggiGrado();