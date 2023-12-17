CREATE OR REPLACE FUNCTION az.CheckLaboratorio () RETURNS TRIGGER AS
$$
DECLARE

RespScientifico az.Impiegato.CodImpiegato%Type;
Imp az.Impiegato.CodImpiegato%Type;
GradoImp az.Impiegato.Grado%Type;
TipoImp az.Impiegato.Tipo%Type;

BEGIN

SELECT I.Grado INTO GradoImp
FROM az.Impiegato AS I JOIN az.Laboratorio AS L ON I.CodImpiegato =
L.ResponsabileScientifico
WHERE L.CodLab = NEW.CodLab;

IF(GradoImp <> 'Senior') THEN
    RAISE EXCEPTION 'Non valido: deve essere un dipendente senior';
END IF;

RETURN NEW;

END
$$ LANGUAGE plpgsql;