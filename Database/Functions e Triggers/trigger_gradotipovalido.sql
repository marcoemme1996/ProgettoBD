CREATE TRIGGER TriggerGradoTipiValido
BEFORE INSERT ON az.Impiegato
FOR EACH ROW
EXECUTE FUNCTION az.GradoTipoValido();