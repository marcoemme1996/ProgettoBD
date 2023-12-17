CREATE OR REPLACE FUNCTION az.getimpiegato(az az.Azienda.CodAzienda%TYPE)
RETURNS VARCHAR(1000) AS
$$
DECLARE
NomeImp az.Impiegato.Nome%TYPE;
CognomeImp az.Impiegato.Cognome%TYPE;
res VARCHAR(100) = "Per la suddetta azienda lavorano: ";
ris VARCHAR(1000) = " ";
risultatofinale VARCHAR(1000) = " ";

cursaz CURSOR FOR(
SELECT I.Nome, I.Cognome
FROM az.Impiegato AS I JOIN az.Azienda AS A ON I.CodAzienda = A.CodAzienda
WHERE A.CodAzienda = az);

BEGIN

  OPEN cursaz;
  LOOP
	   FETCH cursaz INTO NomeImp, CognomeImp;
	   EXIT WHEN cursprogfromlab %NOT FOUND;

	   ris = ris || NomeImp || CognomeImp;
  END LOOP;
  risultatofinale = res || ris;
  CLOSE cursaz;
RETURN risultatofinale;
END
$$ LANGUAGE plpgsql;