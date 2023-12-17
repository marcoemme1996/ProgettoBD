CREATE TRIGGER TriggerCheckProgetto
BEFORE INSERT ON az.Progetto
FOR EACH ROW
EXECUTE FUNCTION az.CheckProgetto();