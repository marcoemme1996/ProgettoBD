CREATE TRIGGER TriggerChiusuraProgettoImpiegato
AFTER DELETE ON az.Impiegato
FOR EACH ROW
EXECUTE FUNCTION az.ChiusuraProgettoImpiegato();
