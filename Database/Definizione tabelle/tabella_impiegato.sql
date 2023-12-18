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