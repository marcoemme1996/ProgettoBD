CREATE TRIGGER TriggerLaboratorioAperto
BEFORE INSERT ON az.Laboratorio
FOR EACH ROW
EXECUTE FUNCTION az.LaboratorioAperto();