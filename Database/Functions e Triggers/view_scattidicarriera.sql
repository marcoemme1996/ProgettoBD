CREATE VIEW az.ScattiDiCarriera (CodImpiegato, Nome, Cognome, Tipo, Grado,
Stipendio, AnnoDiPromozione) AS
SELECT I.CodImpiegato, I.Nome, I.Cognome, I.Tipo, I.Grado, I.Stipendio, date_part('year'::text, CURRENT_DATE)
FROM az.Impiegato AS I