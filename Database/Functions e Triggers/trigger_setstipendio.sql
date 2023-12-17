CREATE TRIGGER TriggerSetStipendio
AFTER INSERT ON az.Impiegato
FOR EACH ROW
EXECUTE FUNCTION az.SetStipendio();