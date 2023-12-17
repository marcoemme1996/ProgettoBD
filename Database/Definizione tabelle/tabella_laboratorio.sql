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