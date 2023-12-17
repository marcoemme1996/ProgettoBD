CREATE OR REPLACE FUNCTION az.getprog(imp az.Impiegato.CodImpiegato%TYPE)
RETURNS az.Progetto.Nome%TYPE AS
$$
DECLARE
NomeProg az.Progetto.Nome%TYPE;
TipoImp az.Impiegato.Tipo%TYPE;
GradoImp az.Impiegato.Grado%TYPE;
res1 CHAR(100) = "Il suddetto impiegato è il referente scientifico di: ";
res2 CHAR(100) = "Il suddetto impiegato è il responsabile di: ";
ris VARCHAR(1000) =  " ";
risultatofinale VARCHAR(1000) = " ";
cursprog CURSOR FOR(
SELECT P.Nome
FROM az.Progetto AS P
WHERE P.ReferenteScientifico = imp OR P.Responsabile = imp);

BEGIN
  SELECT I.Tipo, I.Grado INTO TipoImp, GradoImp
  FROM az.Impiegato AS I
  WHERE CodImpiegato = imp;

  IF ((TipoImp = 'Dipendente' AND GradoImp <> 'Senior') OR (TipoImp <> 'Dirigente')) THEN
     RAISE EXCEPTION 'Non valido: deve essere un dipendente senior o un dirigente';
  END IF;


  OPEN cursprog;
  IF (TipoImp = 'Dipendente' AND GradoImp = 'Senior') THEN
     LOOP
	   FETCH cursprog INTO NomeProg;
	   EXIT WHEN curslab %NOT FOUND;

	   ris = ris || NomeProg;
     END LOOP;
	 risultatofinale = res1 || ris;

  ELSE IF (TipoImp = 'Dirigente') THEN
     LOOP
	   FETCH cursprog INTO NomeProg;
	   EXIT WHEN curslab %NOT FOUND;

	   ris = ris || NomeProg;
     END LOOP;
	 risultatofinale = res2 || ris;
  END IF;
  CLOSE cursprog;

RETURN risultatofinale;
END
$$ LANGUAGE plpgsql;