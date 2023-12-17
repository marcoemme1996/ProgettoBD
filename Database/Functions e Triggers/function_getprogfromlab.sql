CREATE OR REPLACE FUNCTION az.getprogfromlab(lab az.Laboratorio.CodLab%TYPE)
RETURNS az.Progetto.Nome%TYPE AS
$$
DECLARE
NomeProg az.Progetto.Nome%TYPE;
res VARCHAR(100) = " ";

cursprogfromlab CURSOR FOR(
SELECT P.Nome
FROM az.Progetto AS P
WHERE P.Lab1 = lab OR P.Lab2 = lab OR P.Lab3 = lab);

BEGIN

  OPEN cursprogfromlab;
  LOOP
	   FETCH cursprogfromlab INTO NomeProg;
	   EXIT WHEN cursprogfromlab %NOT FOUND;

	   res = res || NomeProg;
  END LOOP;
  CLOSE cursprogfromlab;
RETURN res;
END
$$ LANGUAGE plpgsql;