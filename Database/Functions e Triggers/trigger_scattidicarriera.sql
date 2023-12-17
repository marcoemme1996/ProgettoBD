CREATE TRIGGER TriggerScattiDiCarriera
AFTER UPDATE ON az.Impiegato
FOR EACH ROW
EXECUTE FUNCTION az.ScattiDiCarriera();