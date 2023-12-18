CREATE OR REPLACE FUNCTION az.StipValido() RETURNS TRIGGER AS
$$
DECLARE
    Stip_Sottoposto az.Impiegato.Stipendio%Type;
    Stip_Capo az.Impiegato.Stipendio%Type;
BEGIN
   SELECT  I1.Stipendio, I2.Stipendio INTO Stip_Sottoposto, Stip_Capo
   FROM az.Impiegato AS I1, az.Impiegato AS I2
   WHERE I1.CodImpiegato = NEW.CodImpiegato AND I1.Capo = I2.CodImpiegato;

    IF (Stip_Sottoposto >= Stip_Capo) THEN
    RAISE EXCEPTION 'Non valido: impossibile che lo stipendio di un
    sottoposto sia maggiore o uguale di quello del suo capo';
    END IF;

RETURN NEW;

END
$$ LANGUAGE plpgsql;