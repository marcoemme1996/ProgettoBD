CREATE OR REPLACE FUNCTION az.CorreggiGrado () RETURNS TRIGGER AS
$$
DECLARE

AnniDiServizio integer;
GradoImpiegato az.Impiegato.Grado%Type;
TipoImpiegato az.Impiegato.Tipo%Type;

BEGIN

SELECT EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM I.DataAssunzione) INTO AnniDiServizio
FROM az.Impiegato AS I
WHERE I.CodImpiegato = NEW.CodImpiegato;

SELECT I.Grado, I.Tipo INTO GradoImpiegato, TipoImpiegato
FROM az.Impiegato AS I
WHERE I.CodImpiegato = NEW.CodImpiegato;

IF (TipoImpiegato = 'Dipendente') THEN
    IF (AnniDiServizio < 3 AND GradoImpiegato <> 'Junior') THEN
       UPDATE az.Impiegato AS I
       SET I.Grado = 'Junior'
       WHERE I.CodImpiegato = NEW.CodImpiegato;
    END IF;

    IF (AnniDiServizio >=3 AND AnniDiServizio < 7 AND GradoImpiegato <> 'Middle') THEN
	UPDATE az.Impiegato AS I
	SET I.Grado = 'Middle'
	WHERE I.CodImpiegato = NEW.CodImpiegato;
    END IF;

    IF (AnniDiServizio >= 7 AND GradoImpiegato <> 'Senior') THEN
	UPDATE az.Impiegato AS I
	SET I.Grado = 'Senior'
	WHERE I.CodImpiegato = NEW.CodImpiegato;
	END IF;
END IF;

RETURN NEW;

END
$$ LANGUAGE plpgsql;