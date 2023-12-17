CREATE OR REPLACE FUNCTION az.getlabs(imp az.Impiegato.CodImpiegato%TYPE)
RETURNS az.Laboratorio.Nome%TYPE AS
$$
DECLARE
NomeLab az.Laboratorio.Nome%TYPE;
TipoImp az.Impiegato.Tipo%TYPE;
GradoImp az.Impiegato.Grado%TYPE;
res VARCHAR(100) = " ";
curslab CURSOR FOR(
SELECT L.Nome
FROM az.Laboratorio AS L
WHERE L.ResponsabileScientifico = imp);

BEGIN
  SELECT I.Tipo, I.Grado INTO TipoImp, GradoImp
  FROM az.Impiegato AS I
  WHERE CodImpiegato = imp;

  IF (TipoImp <> 'Dipendente' AND GradoImp <> 'Senior') THEN
     RAISE EXCEPTION 'Non valido: deve essere un dipendente senior';
  END IF;

  OPEN curslab;
  LOOP
	   FETCH curslab INTO NomeLab;
	   EXIT WHEN curslab %NOT FOUND;
	   res = res || NomeLab;
  END LOOP;
  CLOSE curslab;
RETURN res;
END
$$ LANGUAGE plpgsql;