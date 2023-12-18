CREATE TRIGGER TriggerPromozioneImpiegato
AFTER UPDATE ON az.Impiegato
FOR EACH ROW
EXECUTE FUNCTION az.PromozioneImpiegato();