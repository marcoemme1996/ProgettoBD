CREATE SCHEMA az;

----------------------
Creazione tabelle
----------------------

CREATE TABLE az.Azienda(
CodAzienda INTEGER,
Nome VARCHAR(20),
Sede VARCHAR(20),

CONSTRAINT PKA1 PRIMARY KEY (CodAzienda));

CREATE TABLE az.Impiegato(
CodImpiegato INTEGER,
Nome VARCHAR(20) NOT NULL,
Cognome VARCHAR(20) NOT NULL,
Residenza VARCHAR(20) NOT NULL,
EMail VARCHAR(30) NOT NULL,
Stipendio FLOAT NOT NULL,
DataAssunzione DATE NOT NULL,
Tipo VARCHAR(15) NOT NULL CHECK(Tipo IN ('Dipendente', 'Dirigente')),
Grado VARCHAR(15) NOT NULL CHECK(Grado IN ('Junior', 'Middle', 'Senior')),
CodAzienda INTEGER NOT NULL,
Capo INTEGER,

CONSTRAINT PKI1 PRIMARY KEY (CodImpiegato),
CONSTRAINT UNQI1 UNIQUE (EMail),
CONSTRAINT FKI1 FOREIGN KEY(CodAzienda) REFERENCES az.Azienda(CodAzienda) ON DELETE CASCADE,
CONSTRAINT FKI2 FOREIGN KEY(Capo) REFERENCES az.Impiegato(CodImpiegato));

CREATE TABLE az.Laboratorio(
CodLab INTEGER,
Nome VARCHAR(20) NOT NULL,
Piano INTEGER NOT NULL,
Topic VARCHAR(30) NOT NULL,
NumeroAfferenti INTEGER NOT NULL,
Aperto CHAR(1) NOT NULL CHECK(Aperto IN ('S', 'N')),
ResponsabileScientifico INTEGER,

CONSTRAINT PKL1 PRIMARY KEY (CodLab),
CONSTRAINT FKL1 FOREIGN KEY(ResponsabileScientifico) REFERENCES az.Impiegato(CodImpiegato));

CREATE TABLE az.Progetto(
CUP INTEGER,
Nome VARCHAR(20),
Budget FLOAT,
Attivo CHAR(1) CHECK(Attivo IN ('S', 'N')),
ReferenteScientifico INTEGER,
Responsabile INTEGER,
Lab1 INTEGER,
Lab2 INTEGER,
Lab3 INTEGER,

CONSTRAINT PKP1 PRIMARY KEY (CUP),
CONSTRAINT UNQP1 UNIQUE (Nome),
CONSTRAINT FKP1 FOREIGN KEY(ReferenteScientifico) REFERENCES az.Impiegato(CodImpiegato),
CONSTRAINT FKP2 FOREIGN KEY(Responsabile) REFERENCES az.Impiegato(CodImpiegato),
CONSTRAINT FKP3 FOREIGN KEY(Lab1) REFERENCES az.Laboratorio(CodLab),
CONSTRAINT FKP4 FOREIGN KEY(Lab2) REFERENCES az.Laboratorio(CodLab),
CONSTRAINT FKP5 FOREIGN KEY(Lab2) REFERENCES az.Laboratorio(CodLab));

------------------------------
Funzioni e Triggers
------------------------------
CREATE OR REPLACE FUNCTION az.StipValido() RETURNS TRIGGER AS
$$
DECLARE
    Stip_Sottoposto az.Impiegato.Stipendio%Type;
    Stip_Capo az.Impiegato.Stipendio%Type;
BEGIN
   SELECT  I1.Stipendio, I2.Stipendio INTO Stip_Sottoposto, Stip_Capo
   FROM az.Impiegato AS I1, az.Impiegato AS I2
   WHERE I1.CodImpiegato = CodImp AND I1.Capo = I2.CodImpiegato;

    IF (Stip_Sottoposto >= StipCapo) THEN
    RAISE EXCEPTION 'Non valido: impossibile che lo stipendio di un
    sottoposto sia maggiore o uguale di quello del suo capo';
    END IF;

RETURN NEW;

END
$$ LANGUAGE plpgsql;

-------------------

CREATE TRIGGER TriggerStipValido
BEFORE INSERT ON az.Impiegato
FOR EACH ROW
EXECUTE FUNCTION az.StipValido();

-----------------------------------------------

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

-------------------

CREATE TRIGGER TriggerGradoTipiValido
BEFORE INSERT ON az.Impiegato
FOR EACH ROW
EXECUTE FUNCTION az.GradoTipoValido();

-----------------------------------------------

CREATE FUNCTION az.CheckImpiegati() RETURNS TRIGGER AS
$$
DECLARE

GradoImp az.Impiegato.Grado%Type;
TipoImp az.Impiegato.Tipo%Type;

BEGIN

SELECT I.Grado, I.Tipo INTO GradoImp, TipoImp
FROM az.Impiegato AS I
WHERE I.CodImpiegato = NEW.CodImpiegato;

IF(TipoImp = 'Dipendente' AND GradoImp = NULL) THEN
   RAISE EXCEPTION 'Non valido: deve avere un grado';
END IF;

IF(TipoImp = 'Dirigente' AND GradoImp <> NULL) THEN
   RAISE EXCEPTION 'Non valido: non deve avere un grado';
END IF;

RETURN NEW;

END
$$ LANGUAGE plpgsql;

-------------------

CREATE TRIGGER TriggerCheckImpiegati
BEFORE INSERT ON az.Impiegato
FOR EACH ROW
EXECUTE FUNCTION az.CheckImpiegati();

-----------------------------------------------

CREATE FUNCTION az.PromozioneImpiegato() RETURNS TRIGGER AS
$$
DECLARE

Imp az.Impiegato.CodImpiegato%Type;

BEGIN
SELECT I.CodImpiegato INTO Imp
FROM az.Impiegato AS I
WHERE I.CodImpiegato = NEW.CodImpiegato;

UPDATE az.Impiegato AS I
SET I.Grado = NULL
WHERE I.CodImpiegato = Imp AND OLD.Tipo = 'Dipendente' AND NEW.Tipo = 'Dirigente';

RETURN NEW;

END
$$ LANGUAGE plpgsql;

-------------------

CREATE TRIGGER TriggerPromozioneImpiegato
AFTER UPDATE ON az.Impiegato
FOR EACH ROW
EXECUTE FUNCTION az.PromozioneImpiegato();

-----------------------------------------------

CREATE OR REPLACE FUNCTION az.CorreggiGrado () RETURNS TRIGGER AS
$$
DECLARE

AnniDiServizio integer;
GradoImpiegato az.Impiegato.Grado%Type;
TipoImpiegato az.Impiegato.Tipo%Type;

BEGIN

SELECT YEAR(SYSDATE) - YEAR(I.DataAssunzione) INTO AnniDiServizio
FROM az.Impiegato AS I
WHERE I.CodImpiegato = NEW.CodImpiegato;

SELECT I.Grado, I.Tipo INTO GradoImpiegato, TipoImpiegato
FROM az.Impiegato AS I
WHERE I.CodImpiegato = NEW.CodImpiegato;

IF (TipoImpiegato = 'Dipendente') THEN
    IF (AnniDiServizio < 3 AND Grado <> 'Junior') THEN
       UPDATE az.Impiegato AS I
       SET I.Grado = 'Junior'
       WHERE I.CodImpiegato = NEW.CodImpiegato;
    END IF;

    IF (AnniDiServizio >=3 AND AnniDiServizio < 7 AND Grado <> 'Middle') THEN
	UPDATE az.Impiegato AS I
	SET I.Grado = 'Middle'
	WHERE I.CodImpiegato = NEW.CodImpiegato;
    END IF;

    IF (AnniDiServizio >= 7 AND Grado <> 'Senior') THEN
	UPDATE az.Impiegato AS I
	SET I.Grado = 'Senior'
	WHERE I.CodImpiegato = NEW.CodImpiegato;
	END IF;
END IF;

RETURN NEW;

END
$$ LANGUAGE plpgsql;

-------------------

CREATE TRIGGER TriggerCorreggiGrado
BEFORE INSERT ON az.Impiegato
FOR EACH ROW
EXECUTE FUNCTION az.CorreggiGrado();

-----------------------------------------------

CREATE OR REPLACE FUNCTION az.FixStipendio() RETURNS TRIGGER AS
$$
DECLARE
TipoImp az.Impiegato.Tipo%TYPE;
GradoImp az.Impiegato.Grado%TYPE;

BEGIN
SELECT I.Grado, I.Tipo INTO GradoImp, TipoImp
FROM az.Impiegato AS I
WHERE OLD.Grado <> NEW.Grado OR OLD.Tipo <> NEW.Tipo;

IF ((OLD.Tipo = 'Dirigente' AND NEW.Tipo = 'Dipendente') OR (OLD.Grado = 'Senior' AND (NEW.Grado = 'Junior' OR NEW.Grado = 'Middle')) OR (OLD.Grado = 'Middle' AND NEW.Grado = 'Junior')) THEN
  RAISE EXCEPTION 'Passaggio non valido';

ELSE
  IF (OLD.Tipo = 'Dipendente' AND NEW.Tipo = 'Dipendente') THEN
  UPDATE az.Impiegato AS I
  SET I.Stipendio = I.Stipendio + 5000
  WHERE OLD.CodImpiegato = NEW.CodImpiegato;

  ELSE IF (OLD.Tipo = 'Dipendente' AND NEW.Tipo = 'Dirigente') THEN
  UPDATE az.Impiegato AS I
  SET I.Stipendio = 20000
  WHERE OLD.CodImpiegato = NEW.CodImpiegato;

  END IF;
END IF;

RETURN NEW;

END
$$ LANGUAGE plpgsql;

---------------

CREATE TRIGGER TriggerFixStipendio
AFTER UPDATE ON az.Impiegato
FOR EACH ROW
EXECUTE FUNCTION az.FixStipendio();

-----------------------------------------------

CREATE OR REPLACE FUNCTION SetStipendio() RETURNS TRIGGER AS
$$
DECLARE

GradoImp az.Impiegato.Grado%TYPE;
TipoImp az.Impiegato.Tipo%TYPE;
StipendioImp az.Impiegato.Stipendio%TYPE;

BEGIN

SELECT NEW.Grado, NEW.Tipo, NEW.Stipendio INTO GradoImp, TipoImp, StipendioImp
FROM az.Impiegato AS I
WHERE I.CodImpiegato = NEW.CodImpiegato;


IF (TipoImp = 'Dipendente' AND GradoImp = 'Junior' AND StipendioImp <> 5000) THEN
  UPDATE az.Impiegato AS I
  SET I.Stipendio = 5000
  WHERE I.CodImpiegato = NEW.CodImpiegato;

ELSE IF (TipoImp = 'Dipendente' AND GradoImp = 'Middle' AND StipendioImp <> 10000) THEN
  UPDATE az.Impiegato AS I
  SET I.Stipendio = 10000
  WHERE I.CodImpiegato = NEW.CodImpiegato;

ELSE IF (TipoImp = 'Dipendente' AND GradoImp = 'Senior' AND StipendioImp <> 15000) THEN
  UPDATE az.Impiegato AS I
  SET I.Stipendio = 15000
  WHERE I.CodImpiegato = NEW.CodImpiegato;

ELSE IF (TipoImp = 'Dirigente' AND StipendioImp <> 20000) THEN
  UPDATE az.Impiegato AS I
  SET I.Stipendio = 20000
  WHERE I.CodImpiegato = NEW.CodImpiegato;

END IF;

RETURN NEW;
END
$$ LANGUAGE plpgsql;

-----------------

CREATE TRIGGER TriggerSetStipendio
AFTER INSERT ON az.Impiegato
FOR EACH ROW
EXECUTE FUNCTION az.SetStipendio();

-----------------------------------------------

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

-----------------------------------------------

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

-----------------------------------------------

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

-----------------------------------------------

CREATE OR REPLACE FUNCTION az.CheckLaboratorio () RETURNS TRIGGER AS
$$
DECLARE

RespScientifico az.Impiegato.CodImpiegato%Type;
Imp az.Impiegato.CodImpiegato%Type;
GradoImp az.Impiegato.Grado%Type;
TipoImp az.Impiegato.Tipo%Type;

BEGIN

SELECT I.Grado INTO GradoImp
FROM az.Impiegato AS I JOIN Laboratorio AS L ON I.CodImpiegato =
L.ResponsabileScientifico
WHERE L.CodLab = NEW.CodLab;

IF(GradoImp <> 'Senior') THEN
    RAISE EXCEPTION 'Non valido: deve essere un dipendente senior';
END IF;

RETURN NEW;

END
$$ LANGUAGE plpgsql;

-------------------

CREATE TRIGGER TriggerCheckLaboratorio
BEFORE INSERT ON az.Laboratorio
FOR EACH ROW
EXECUTE FUNCTION az.CheckLaboratorio();

-----------------------------------------------

CREATE OR REPLACE FUNCTION az.LaboratorioAperto() RETURNS TRIGGER AS
$$
DECLARE

BEGIN

IF(NEW.ResponsabileScientifico = NULL) THEN
    UPDATE Laboratorio
    SET NEW.Aperto = 'N';

ELSE
    UPDATE Laboratorio
    SET NEW.Aperto = 'S';
END IF;

RETURN NEW;

END
$$ LANGUAGE plpgsql;

-------------------

CREATE TRIGGER TriggerLaboratorioAperto
BEFORE INSERT ON az.Laboratorio
FOR EACH ROW
EXECUTE FUNCTION az.LaboratorioAperto();

-----------------------------------------------

CREATE FUNCTION az.ChiusuraLaboratorio() RETURNS TRIGGER AS
$$
DECLARE

BEGIN

UPDATE az.Laboratorio AS L
SET L.ResponsabileScientifico = NULL,
Aperto = 'N'
WHERE L.ResponsabileScientifico = OLD.CodImpiegato;

RETURN NEW;

END
$$ LANGUAGE plpgsql;

-------------------

CREATE TRIGGER TriggerChiusuraLab
AFTER DELETE ON az.Impiegato
FOR EACH ROW
EXECUTE FUNCTION az.ChiusuraLaboratorio();

-----------------------------------------------

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

-----------------------------------------------

CREATE FUNCTION az.CheckProgetto() RETURNS TRIGGER AS
$$
DECLARE

GradoResp az.Impiegato.Grado%Type;
GradoReferente az.Impiegato.Grado%Type;
TipoResp az.Impiegato.Tipo%Type;
TipoReferente az.Impiegato.Tipo%Type;

BEGIN

SELECT I.Grado, I.Tipo INTO GradoResp, TipoResp
FROM az.Impiegato AS I JOIN az.Laboratorio AS L ON I.CodImpiegato = L.Responsabile
WHERE I.CodImpiegato = NEW.CodImpiegato;

SELECT I.Grado, I.Tipo INTO GradoReferente, TipoReferente
FROM az.Impiegato AS I JOIN az.Laboratorio AS L ON I.CodImpiegato = L.ReferenteScientifico
WHERE I.CodImpiegato = NEW.CodImpiegato;

IF(TipoReferente = 'Dirigente' OR (TipoReferente = 'Dipendente' AND GradoReferente <> 'Senior') ) THEN
RAISE EXCEPTION 'Non valido: il referente scientifico deve essere un dipendente senior';
END IF;

IF(TipoResp <> 'Dirigente')THEN
RAISE EXCEPTION 'Non valido: il responsabile deve essere un dirigente';
END IF;

RETURN NEW;

END
$$ LANGUAGE plpgsql;

-------------------

CREATE TRIGGER TriggerCheckProgetto
BEFORE INSERT ON az.Progetto
FOR EACH ROW
EXECUTE FUNCTION az.CheckProgetto();

-----------------------------------------------

CREATE FUNCTION az.ProgettoAttivo() RETURNS TRIGGER AS
$$
DECLARE

RefScientifico az.Impiegato.CodImpiegato%Type;
Resp az.Impiegato.CodImpiegato%Type;
PrimoLaboratorio az.Laboratorio.CodLab%Type;
SecondoLaboratorio az.Laboratorio.CodLab%Type;
TerzoLaboratorio az.Laboratorio.CodLab%Type;

BEGIN

SELECT P.ReferenteScientifico, P.Responsabile, P.Lab1, P.Lab2, P.Lab3
INTO RefScientifico, Resp, PrimoLaboratorio, SecondoLaboratorio, TerzoLaboratorio
FROM az.Progetto AS P
WHERE P.CUP = NEW.CUP;

IF ((RefScientifico = NULL OR Resp = NULL) OR (PrimoLaboratorio = NULL
AND SecondoLaboratorio = NULL AND TerzoLaboratorio = NULL)) THEN
    UPDATE az.Progetto AS P
    SET Attivo = 'N'
    WHERE P.CUP = NEW.CUP;

ELSE
    UPDATE az.Progetto AS P
    SET Attivo = 'S'
    WHERE P.CUP = NEW.CUP;
END IF;

RETURN NEW;

END
$$ LANGUAGE plpgsql;

-------------------

CREATE TRIGGER TriggerProgettoAttivo
BEFORE INSERT ON az.Progetto
FOR EACH ROW
EXECUTE FUNCTION az.ProgettoAttivo();

-----------------------------------------------

CREATE FUNCTION az.ChiusuraProgettoImpiegato() RETURNS TRIGGER AS
$$
DECLARE

ImpiegatoCancellato az.Impiegato.CodImpiegato%Type;

BEGIN

SELECT I.CodImpiegato INTO ImpiegatoCancellato
FROM az.Impiegato AS I
WHERE I.CodImpiegato = OLD.CodImpiegato;

IF(ImpiegatoCancellato = ReferenteScientifico) THEN
    UPDATE az.Progetto AS P
    SET P.ReferenteScientifico = NULL, P.Attivo = 'N'
    WHERE P.ReferenteScientifico = OLD.CodImpiegato;
END IF;

IF(ImpiegatoCancellato = Responsabile) THEN
    UPDATE az.Progetto AS P
    SET P.Responsabile = NULL, P.Attivo = 'N'
    WHERE P.Responsabile = OLD.CodImpiegato;
END IF;

RETURN NEW;

END
$$ LANGUAGE plpgsql;

-------------------

CREATE TRIGGER TriggerChiusuraProgettoImpiegato
AFTER DELETE ON az.Impiegato
FOR EACH ROW
EXECUTE FUNCTION az.ChiusuraProgettoImpiegato();

-----------------------------------------------

CREATE FUNCTION az.ChiusuraProgLaboratorio() RETURNS TRIGGER AS
$$
DECLARE

LabCancellato az.Laboratorio.CodLab%Type;
PrimoLaboratorio az.Laboratorio.CodLab%Type;
SecondoLaboratorio az.Laboratorio.CodLab%Type;
TerzoLaboratorio az.Laboratorio.CodLab%Type;

BEGIN

SELECT L.CodLab, L.Lab1, L.Lab2, L.Lab3 INTO LabCancellato, PrimoLaboratorio, SecondoLaboratorio, TerzoLaboratorio
FROM az.Laboratorio AS L
WHERE L.CodLab = OLD.CodLab;

IF(LabCancellato = PrimoLaboratorio AND SecondoLaboratorio = NULL AND
TerzoLaboratorio = NULL) THEN
    UPDATE az.Progetto AS P
    SET P.Lab1 = NULL, P.Attivo = 'N'
    WHERE P.Lab1 = OLD.CodLab;
END IF;

IF(LabCancellato = SecondoLaboratorio AND PrimoLaboratorio = NULL AND
TerzoLaboratorio = NULL) THEN
    UPDATE az.Progetto AS P
    SET P.Lab2 = NULL, P.Attivo = 'N'
    WHERE P.Lab2 = OLD.CodLab;
END IF;

IF(LabCancellato = TerzoLaboratorio AND PrimoLaboratorio = NULL AND
SecondoLaboratorio = NULL) THEN
    UPDATE az.Progetto AS P
    SET P.Lab3 = NULL, P.Attivo = 'N'
    WHERE P.Lab3 = OLD.CodLab;
END IF;

RETURN NEW;

END
$$ LANGUAGE plpgsql;

-------------------

CREATE TRIGGER TriggerChiusuraProgLaboratorio
AFTER DELETE ON az.Laboratorio
FOR EACH ROW
EXECUTE FUNCTION az.ChiusuraProgLaboratorio();

-----------------------------------------------

CREATE VIEW az.ScattiDiCarriera (CodImpiegato, Nome, Cognome, Tipo, Grado,
Stipendio, AnnoDiPromozione) AS
SELECT I.CodImpiegato, I.Nome, I.Cognome, I.Tipo, I.Grado, I.Stipendio, date_part('year'::text, CURRENT_DATE)
FROM az.Impiegato AS I

-------------------

CREATE FUNCTION az.ScattiDiCarriera() RETURNS TRIGGER AS
$$
DECLARE

BEGIN

INSERT INTO az.ScattiDiCarriera(
SELECT I.CodImpiegato, I.Nome, I.Cognome, I.Tipo, I.Grado, I.Stipendio,
EXTRACT(YEAR FROM CURRENT_DATE)
FROM az.Impiegato AS I
WHERE I.CodImpiegato = NEW.CodImpiegato AND OLD.Grado <> NEW.Grado);

RETURN NEW;
END

$$ LANGUAGE plpgsql;

-------------------

CREATE TRIGGER TriggerScattiDiCarriera
AFTER UPDATE ON az.Impiegato
FOR EACH ROW
EXECUTE FUNCTION az.ScattiDiCarriera();

-------------------
Inserimenti
-------------------

INSERT INTO az.Azienda (CodAzienda, Nome, Sede) VALUES (1, 'Apple', 'Napoli');
INSERT INTO az.Azienda (CodAzienda, Nome, Sede) VALUES (2, 'Microsoft', 'Roma');
INSERT INTO az.Azienda (CodAzienda, Nome, Sede) VALUES (3, 'Amazon', 'Milano');
INSERT INTO az.Azienda (CodAzienda, Nome, Sede) VALUES (4, 'Mastercard', 'Firenze');
INSERT INTO az.Azienda (CodAzienda, Nome, Sede) VALUES (5, 'Adobe', 'Venezia');	
	
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (1, 'Angelo', 'Ricci', 'Napoli', 'angelo.ricci@gmail.com', '2002-5-5', 'Dirigente', 20000, NULL, NULL, 1);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (2, 'Alessandro', 'Milani', 'Firenze', 'ale.mil@hotmail.com', '2000-10-22', 'Dipendente', 15000, 'Senior', NULL, 4);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (3, 'Antonio', 'Rizzi', 'Firenze', 'rizziant@gmail.com', '2021-4-8', 'Dipendente', 5000, 'Junior', 2, 4);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (4, 'Eleonora', 'Cappiello', 'Roma', 'elecap@gmail.com', '2010-6-12', 'Dirigente', 20000, NULL, NULL, 2);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (5, 'Giovanni', 'Iacovino', 'giovanni.iacovino@gmail.com', 'Napoli', '2018-9-20', 'Dipendente', 15000, 'Senior', 1, 1);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (6, 'Ludovica', 'Catellani', 'Venezia', 'catellaniludo@gmail.com', '2018-7-2', 'Dipendente', 15000, 'Senior', NULL, 5);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (7, 'Giulio', 'DAmico', 'Roma', 'giul123@gmail.com', '2022-3-18', 'Dipendente', 5000, 'Junior', 4, 2);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (8, 'Mario', 'Rossi', 'Venezia', 'rossimario@gmail.com', '2015-4-2', 'Dipendente', 15000, 'Senior', NULL, 5);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, AnniDiServizio, Grado, Capo, CodAzienda) VALUES (9, 'Sara', 'Romano', 'Milano', 'sararomano@gmail.com', '2013-5-7', 'Dipendente', 15000, 'Senior', NULL, 3);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, AnniDiServizio, Grado, Capo, CodAzienda) VALUES (10, 'Ilario', 'Barbieri', 'Venezia', 'barbieriI@gmail.com', '2019-6-19', 'Dipendente', 10000, 'Middle', 8, 5);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (11, 'Luca', 'Borsari', 'Milano', 'lucaborsari@gmail.com', '2012-11-22', 'Dirigente', 20000, NULL, NULL, 3);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (12, 'Maria', 'Venturelli', 'Firenze', 'v.maria@gmail.com', '3-18-2022', 'Dirigente', 20000, NULL, NULL, 4);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (13, 'Davide', 'Russo', 'Napoli', 'russodavide@gmail.com', '2014-1-28', 'Dipendente', 15000, 'Senior', NULL, 1);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (14, 'Chiara', 'Galli', 'Roma', 'giul123@gmail.com', '2015-5-6', 'Dipendente', 15000, 'Senior', 4, 2);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (15, 'Guglielmo', 'Lodi', 'Milano', 'lodiguglielmo85@gmail.com', '2020-2-7', 'Dipendente', 5000, 'Junior', 11, 3);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (16, 'Lucia', 'Cuoghi', 'Napoli', 'luciacuoghi@gmail.com', '2014-6-29', 'Dipendente', 15000, 'Senior', 1, 1);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (17, 'Giacomo', 'Rinaldi', 'Venezia', 'lodiguglielmo85@gmail.com', '2013-5-12', 'Dirigente', 20000, NULL, NULL, 5);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (18, 'Marco', 'Leonardi', 'Firenze', 'marcleonardi@gmail.com', '2016-4-14', 'Dipendente', 15000, 'Senior', 12, 4);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (19, 'Umberto', 'Fontana', 'Roma', 'fontana999@gmail.com', '2018-1-29', 'Dipendente', 10000, 'Middle', 14, 2);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (20, 'Carlo', 'Borghi', 'Milano', 'carloborghi@gmail.com', '2014-9-18', 'Dipendente', 15000, 'Senior', 11, 3);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (21, 'Alessandra', 'Sala', 'Venezia', 'salaale@gmail.com', '2015-3-15', 'Dirigente', 20000, NULL, NULL, 5);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (22, 'Dino', 'Vaccari', 'Firenze', 'dino@gmail.com', '2016-5-19', 'Dirigente', 20000, NULL, NULL, 4);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (23, 'Gianni', 'Vecchi', 'Napoli', 'gianniv85@gmail.com', '2018-7-12', 'Dipendente', 10000, 'Middle', 1, 1);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (24, 'Valeria', 'Baraldi', 'Roma', 'barvale@gmail.com', '2014-6-6', 'Dirigente', 20000, NULL, NULL, 2);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (25, 'Silvio', 'Cavazzuti', 'Milano', 'silviocavazzuti85@gmail.com', '2013-9-9', 'Dirigente', 20000, NULL, NULL, 3);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (26, 'Bruno', 'Panini', 'Firenze', 'bruno.pan@gmail.com', '2019-5-2', 'Dipendente', 20000, 'Middle', 22, 4);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (27, 'Melissa', 'Garuti', 'Venezia', 'mel.gar@gmail.com', '2022-6-30', 'Dipendente', 5000, 'Junior', 8, 5);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (28, 'Marzia', 'Venturelli', 'Napoli', 'ventur.marzia@gmail.com', '2014-10-20', 'Dirigente', 20000, NULL, NULL, 1);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (29, 'Gioacchino', 'Morandi', 'Roma', 'gioacchinomorandi@gmail.com', '2015-11-11', 'Dipendente', 15000, 'Senior', NULL, 2);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (30, 'Massimo', 'Martinelli', 'Milano', 'martmax@gmail.com', '2017-3-18', 'Dirigente', 20000, NULL, NULL, 3);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (31, 'Pasquale', 'Ferrari', 'Firenze', 'pasquale.ferrari@gmail.com', '2015-12-1', 'Dirigente', 20000, NULL, NULL, 4);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (32, 'Jessica', 'Massari', 'Venezia', 'jessicamassari85@gmail.com', '2014-10-25', 'Dipendente', 15000, 'Senior', 17, 5);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (33, 'Gianluca', 'Piccinini', 'Napoli', 'gianlucapic@gmail.com', '2018-11-9', 'Dipendente', 10000, 'Middle', 16, 1);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (34, 'Michele', 'Franchini', 'Roma', 'michelefranchinigmail.com', '2010-9-10', 'Dipendente', 15000, 'Senior', 24, 2);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (35, 'Alberto', 'Cisse', 'Milano', 'albertociss@gmail.com', '2014-12-18', 'Dipendente', 15000, 'Senior', 25, 3);
INSERT INTO az.Impiegato(CodImpiegato, Nome, Cognome, Residenza, EMail, DataAssunzione, Tipo,
Stipendio, Grado, Capo, CodAzienda) VALUES (36, 'Luca', 'Bellei', 'Firenze', 'belleiluca@gmail.com', '2013-11-3', 'Dirigente', 20000, NULL, NULL, 4);

INSERT INTO az.Laboratorio(CodLab, Nome, Piano, Topic, NumeroAfferenti, Aperto, ResponsabileScientifico) VALUES (1, 'Clear Results', 5 , 'Analisi statistica dei dati', 20 , 'S', 32);
INSERT INTO az.Laboratorio(CodLab, Nome, Piano, Topic, NumeroAfferenti, Aperto, ResponsabileScientifico) VALUES (2, 'GreenWave', 3, 'Ricerca fonti di energia alternative', 30, 'S', 35);
INSERT INTO az.Laboratorio(CodLab, Nome, Piano, Topic, NumeroAfferenti, Aperto, ResponsabileScientifico) VALUES (3, 'DiagnostiLabs', 6, 'Impatto della tecnologia su economia', 25, 'N', NULL);
INSERT INTO az.Laboratorio(CodLab, Nome, Piano, Topic, NumeroAfferenti, Aperto, ResponsabileScientifico) VALUES (4, 'Prexis', 3, 'Sviluppo e design dispositivi elettronici', 35 'N', NULL);
INSERT INTO az.Laboratorio(CodLab, Nome, Piano, Topic, NumeroAfferenti, Aperto, ResponsabileScientifico) VALUES (5, 'IALAB', 5, 'Applicazione e benefici intelligenza artificiale' , 50 'S', 16);
INSERT INTO az.Laboratorio(CodLab, Nome, Piano, Topic, NumeroAfferenti, Aperto, ResponsabileScientifico) VALUES (6, 'ProQuery Laboratory', 3, 'Analisi e miglioramento delle query', 20, 'S', 32);
INSERT INTO az.Laboratorio(CodLab, Nome, Piano, Topic, NumeroAfferenti, Aperto, ResponsabileScientifico) VALUES (7, 'SocLab', 4, 'Impatto dei social media', 20 'S', 20);
INSERT INTO az.Laboratorio(CodLab, Nome, Piano, Topic, NumeroAfferenti, Aperto, ResponsabileScientifico) VALUES (8, 'Realab', 5, 'Uso di reti di computer utilizzando reti wireless', 30 'S', 18);
INSERT INTO az.Laboratorio(CodLab, Nome, Piano, Topic, NumeroAfferenti, Aperto, ResponsabileScientifico) VALUES (9, 'Clark Lab', 3, 'Impedire infezioni da virus', 30, 'N', NULL);
INSERT INTO az.Laboratorio(CodLab, Nome, Piano, Topic, NumeroAfferenti, Aperto, ResponsabileScientifico) VALUES (10, 'InternetDiagnostic', 3, 'Impatto della rete internet sulla società' , 40, 'S', 34);
INSERT INTO az.Laboratorio(CodLab, Nome, Piano, Topic, NumeroAfferenti, Aperto, ResponsabileScientifico) VALUES (11, 'MatrixTest Laboratory', 2, 'Sviluppo funzioni matematiche' , 40, 'S', 13);
INSERT INTO az.Laboratorio(CodLab, Nome, Piano, Topic, NumeroAfferenti, Aperto, ResponsabileScientifico) VALUES (12, 'AlphaLab', 3, 'Costruzione e assemblamento sistemi computazionali', 30, 'S', 14);
INSERT INTO az.Laboratorio(CodLab, Nome, Piano, Topic, NumeroAfferenti, Aperto, ResponsabileScientifico) VALUES (13, 'Labworks', 3, 'Tecnologia usata per creare opportunità di lavoro', 40, 'S', 35);
INSERT INTO az.Laboratorio(CodLab, Nome, Piano, Topic, NumeroAfferenti, Aperto, ResponsabileScientifico) VALUES (14, 'Acoustic Laboratory', 2, 'Sviluppo sistemi acustici' , 25, 'S', 18);
INSERT INTO az.Laboratorio(CodLab, Nome, Piano, Topic, NumeroAfferenti, Aperto, ResponsabileScientifico) VALUES (15, 'ClariTest Lab', 3, 'Informazioni su studenti universitari', 35, 'S', 29);

INSERT INTO az.Progetto(CUP, Nome, Budget, Attivo, ReferenteScientifico, Responsabile, Lab1, Lab2, Lab3) VALUES (1, 'Progetto Alfa', 5000, 'S', 9, 30, 2, 7, NULL);
INSERT INTO az.Progetto(CUP, Nome, Budget, Attivo, ReferenteScientifico, Responsabile, Lab1, Lab2, Lab3) VALUES (2, 'Progetto Beta', 4300, 'N', 6, 21, NULL, NULL, NULL);
INSERT INTO az.Progetto(CUP, Nome, Budget, Attivo, ReferenteScientifico, Responsabile, Lab1, Lab2, Lab3) VALUES (3, 'Progetto Gamma', 6700, 'S', 24, 4, 15, 12, 34);
INSERT INTO az.Progetto(CUP, Nome, Budget, Attivo, ReferenteScientifico, Responsabile, Lab1, Lab2, Lab3) VALUES (4, 'Progetto Epsilon' , 6000, 'S', 16, 28, 5, NULL, NULL);
INSERT INTO az.Progetto(CUP, Nome, Budget, Attivo, ReferenteScientifico, Responsabile, Lab1, Lab2, Lab3) VALUES (5, 'Progetto Zeta' , 5500, 'S', 18, 22, 14, NULL, NULL);
