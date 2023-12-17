CREATE FUNCTION az.GradoTipoValido() RETURNS TRIGGER AS
$$
DECLARE

TipoCapo az.Impiegato.Tipo%Type;
TipoSottoposto az.Impiegato.Tipo%Type;
GradoCapo az.Impiegato.Grado%Type;
GradoSottoposto az.Impiegato.Grado%Type;

BEGIN

SELECT I1.Tipo, I2.Tipo, I1.Grado, I2.Grado INTO TipoSottoposto,
TipoCapo, GradoSottoposto, GradoCapo
FROM az.Impiegato AS I1, az.Impiegato AS I2
WHERE I1.Capo = I2.CodImpiegato;

IF(TipoCapo = 'Dipendente' AND TipoSottoposto = 'Dirigente') THEN
    RAISE EXCEPTION 'Non valido: impossibile che un Dirigente abbia
    un Capo Dipendente';
END IF;
IF (TipoCapo = 'Dipendente' AND TipoSottoposto = 'Dipendente') THEN
    IF (GradoCapo = 'Junior') THEN
	RAISE EXCEPTION 'Non valido: impossibile che un Dipendente
        Junior sia Capo di qualcuno';
    END IF;
    ELSE IF (GradoCapo = 'Middle' AND GradoSottoposto = 'Senior') THEN
        RAISE EXCEPTION 'Non valido: impossibile che un Dipendente
        Middle sia il Capo di un Dipendente Senior';
    END IF;
END IF;

RETURN NEW;

END
$$ LANGUAGE plpgsql;