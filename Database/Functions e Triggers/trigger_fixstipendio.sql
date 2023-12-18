CREATE TRIGGER TriggerFixStipendio
AFTER UPDATE ON az.Impiegato
FOR EACH ROW
EXECUTE FUNCTION az.FixStipendio();