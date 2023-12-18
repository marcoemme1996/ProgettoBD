CREATE OR REPLACE FUNCTION az.CheckProgetto() RETURNS TRIGGER AS
$$
DECLARE

GradoResp az.Impiegato.Grado%Type;
GradoReferente az.Impiegato.Grado%Type;
TipoResp az.Impiegato.Tipo%Type;
TipoReferente az.Impiegato.Tipo%Type;

BEGIN

SELECT I.Grado, I.Tipo INTO GradoResp, TipoResp
FROM az.Impiegato AS I JOIN az.Progetto AS PR ON I.CodImpiegato = PR.Responsabile
WHERE I.CodImpiegato = NEW.Responsabile;

SELECT I.Grado, I.Tipo INTO GradoReferente, TipoReferente
FROM az.Impiegato AS I JOIN az.Progetto AS PR ON I.CodImpiegato = PR.ReferenteScientifico
WHERE I.CodImpiegato = NEW.ReferenteScientifico;

IF(TipoReferente = 'Dirigente' OR (TipoReferente = 'Dipendente' AND GradoReferente <> 'Senior') ) THEN
RAISE EXCEPTION 'Non valido: il referente scientifico deve essere un dipendente senior';
END IF;

IF(TipoResp <> 'Dirigente')THEN
RAISE EXCEPTION 'Non valido: il responsabile deve essere un dirigente';
END IF;

RETURN NEW;

END
$$ LANGUAGE plpgsql;