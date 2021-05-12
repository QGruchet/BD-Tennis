 

--POUR LES REQUETES SIMPLE

--R1
SELECT J.nom, J.prenom
FROM Joueurs J
WHERE J.nom = 'Roger'

--R2
SELECT DISTINCT R.lieutournoi, R.annee
FROM Rencontre R
WHERE R.lieutournoi = 'Rolland-Garros'

--R3
SELECT J.nom, J.age
FROM Joueurs J, Rencontre R
WHERE R.nomgagnant = J.nom
AND R.lieutournoi = 'Roland-Garros'

--R4
SELECT S.nom
FROM Sponsor S
WHERE S.adresse = 'France'

--R5
SELECT DISTINCT J.nom, J.prenom, G.rang, G.lieutournoi, G.annee
FROM Joueurs J, Rencontre R, Gain G 
WHERE R.nomgagnant = J.nom
AND G.rang = 1
AND G.prime = 1000000
AND G.nomsponsor = 'HEAD'


--POUR LES REQUETES ENSEMBLISTE

--R1
SELECT DISTINCT J.nom 
FROM Joueurs J, Rencontre R 
WHERE R.nomgagnant = J.nom OR R.nomperdant = J.nom

--R2
SELECT DISTINCT J.nom
FROM Rencontre R, Joueurs J
WHERE R.lieutournoi LIKE 'Wimbledon'
AND (R.nomgagnant = J.nom OR R.nomperdant = J.nom)

--R3
SELECT DISTINCT J.nom, J.prenom
FROM Joueurs J
WHERE J.nom = R.nomgagnant
AND J.nom NOT IN (SELECT R.nom_perdant
                  FROM rencontre R)

--R4
SELECT DISTINCT J.nom
FROM Joueurs J, Gain G
WHERE J.nom = G.nomjoueur 
AND J.nom NOT IN (SELECT nomjoueur
FROM Gain G
WHERE G.prime < 1000000)

--R5
SELECT COUNT(R.score) AS nbmatchs
FROM rencontre R
WHERE R.lieu_tournoi = "Wimbledon"

--R6
SELECT sum(prime) AS gaintotal
FROM Gain G 
WHERE G.nomjoueur = "Nadal"

--R7
SELECT DISTINCT G.nomjoueur, SUM(G.prime) AS gaintotal
FROM Gain G
GROUP BY G.nomjoueur
HAVING SUM(G.prime) >= 2000000

--R8
SELECT S.nom, S.lieutournoi, S.annee, S.montant, SUM(G.prime) AS gaintotal
FROM Sponsor S, Gain G
WHERE G.nomsponsor = S.nom AND G.lieutournoi = S.lieutournoi AND G.annee = S.annee
GROUP BY G.annee, G.nomsponsor, G.lieutournoi
HAVING SUM(G.prime) < S.montant
ORDER BY S.montant DESC

--//////////////////////////////////////////////////
--QUESTION 4
--/////////////////////////////////////////////////

--a)
ALTER TABLE Joueur ADD COLUMN taille INT ; 

--c)
--par exemple avec taille :
ALTER TABLE `Joueur` CHANGE `taille` `taille` INT NOT NULL;
--ou sur l'adresse du sponsor :
ALTER TABLE `Sponsor` CHANGE `adresse` `adresse` VARCHAR(60) NULL;

--4d :
ALTER TABLE Gain
DROP PRIMARY KEY,
ADD PRIMARY KEY(`nomjoueur`,`lieutournoi`,`annee`);

--dans mon cas avec la contrainte de nomjoueur
ALTER TABLE Gain DROP FOREIGN KEY `Gain_ibfk_1`;
-- ou
ALTER TABLE Gain DROP CONSTRAINT `Gain_ibfk_1`;
ALTER TABLE Gain ADD FOREIGN KEY (nomjoueur) REFERENCES Joueur (nom);
--ou
ALTER TABLE Gain 
ADD FOREIGN KEY (nomsponsor, lieutournoi, annee) REFERENCES Sponsor(nom, lieutournoi, annee) ON DELETE CASCADE ON UPDATE CASCADE

SHOW CREATE TABLE Gain; --permet d'afficher la definition de la table avec les nom des contrainte

--Autorise les modif si sql fais chier
SET SQL_SAFE_UPDATES = 0;

-- vérifier la variable SQL_SAFE_UPDATES et la modifier si nécessaire pour permettre les requêtes d'UPDATE (mettre à 0 ou OFF)
SHOW VARIABLES LIKE 'sql_safe_updates';


--////////////////////////////////////////////////////////////
--QUESTION 5
--///////////////////////////////////////////////////////////

--Vue Joueur_francais
CREATE VIEW Joueurs_francais AS
SELECT J.nom, J.prenom, J.age
FROM Joueurs J
WHERE J.nationalite LIKE 'France'

-- Vue Match_perdu
CREATE VIEW Match_perdus (nom_perdant, prenom_perdant, lieu, année, score, nom_gagnant, prenom_gagnant)
AS (SELECT J1.nom, J1.prenom, R.lieutournoi, R.annee, R.score, J2.nom, J2.prenom
    FROM Joueur J1, Rencontre R, Joueur J2
    WHERE J1.nom = R.nomperdant AND J2.nom = R.nomgagnant
   )

-- Matchs_gagnés
CREATE VIEW Matchs_gagnés AS
        SELECT J.nom, J.prenom, R.lieutournoi, R.score, JP.nom AS nom_perdant, JP.prenom AS prenom_perdant
        FROM Joueur J, Rencontre R, Joueur JP
        WHERE J.nom = R.nomgagnant AND JP.nom = R.nomperdant

--Vue total_gain_joueurs
CREATE VIEW Total_gain_joueurs AS 
SELECT J.nom, J.prenom, sum(G.prime) 
FROM Joueurs J, Gain G 
WHERE J.nom = G.nomjoueur
GROUP BY G.nomjoueur
ORDER BY J.nom

--R1
SELECT G.nom_gagnant, G.prenom_gagnant, G.lieu
FROM matchs_gagnés G, Joueurs_francais J
WHERE G.année = '2011' AND G.nom_gagnant = J.nom

--R2
SELECT P.lieu, P.score
FROM matchs_perdus P
WHERE P.nom_perdant LIKE 'NADAL' AND P.année = '2010'

--R3
SELECT T.Gain_total
FROM Total_gain_joueurs T
WHERE T.Gain_total > 1000000

--R4
SELECT M.*
FROM Matchs_perdus M, Joueurs_suisses J, Total_gain_joueurs T
WHERE M.nom = J.nom AND J.nom = T.nom AND T.Gain_total = 1000000

--////////////////////////////////////////////////////
--QUESTION 6
--////////////////////////////////////////////////////

--Pour se connecter en root sur le terminal
--mysql -u root -p

CREATE USER 'Alice'@'localhost' IDENTIFIED BY 'Alice';
CREATE DATABASE BD_Alice; 
GRANT ALL ON BD_Alice.* to 'Alice'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
SHOW GRANTS FOR 'Alice'@'localhost';

CREATE TABLE pour_select_bob ( hello int );
GRANT SELECT ON pour_select_bob TO 'Bob'@'localhost' ;

SELECT M.Zone, SUM(P.Somme_total) as Benefice
FROM Magasin M, Panier P
WHERE M.Zone = 'Normandie'
AND M.Identifiant = P.Id_mag;
    
select P.Nom_produit, P.Marque, P.EAN
FROM Produit P 
WHERE Id_f = '707dbd';

select b.Benefice, b.Zone, RANK() OVER (ORDER by b.Benefice DESC) as rang
from benefice_par_region b ;