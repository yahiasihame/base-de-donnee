-- Création de la base
CREATE DATABASE HotelDB;
USE HotelDB;

-- Table: Hotel
CREATE TABLE Hotel (
    id INT PRIMARY KEY,
    ville VARCHAR(50),
    pays VARCHAR(50),
    code_postal INT
);

desc Hotel ; 

-- Table: Client
CREATE TABLE Client (
    id INT PRIMARY KEY,
    adresse VARCHAR(100),
    ville VARCHAR(50),
    code_postal INT,
    email VARCHAR(100),
    telephone VARCHAR(20),
    nom_complet VARCHAR(100)
);

desc Client ; 

-- Table: Prestation
CREATE TABLE Prestation (
    id INT PRIMARY KEY,
    prix DECIMAL(10,2),
    description VARCHAR(100)
);


desc Prestation ; 


-- Table: TypeChambre
CREATE TABLE TypeChambre (
    id INT PRIMARY KEY,
    nom VARCHAR(50),
    prix DECIMAL(10,2)
);


desc TypeChambre ;


-- Table: Chambre
CREATE TABLE Chambre (
    id INT PRIMARY KEY,
    numero INT,
    etage INT,
    est_reserve BOOLEAN,
    id_type INT,
    id_hotel INT,
    FOREIGN KEY (id_type) REFERENCES TypeChambre(id),
    FOREIGN KEY (id_hotel) REFERENCES Hotel(id)
);


desc Chambre ; 


-- Table: Reservation
CREATE TABLE Reservation (
    id INT PRIMARY KEY,
    date_debut DATE,
    date_fin DATE,
    id_client INT,
    id_chambre INT,
    FOREIGN KEY (id_client) REFERENCES Client(id),
    FOREIGN KEY (id_chambre) REFERENCES Chambre(id)
);

desc Reservation ; 


-- Table: Evaluation
CREATE TABLE Evaluation (
    id INT PRIMARY KEY,
    date_eval DATE,
    note INT,
    commentaire TEXT,
    id_client INT,
    FOREIGN KEY (id_client) REFERENCES Client(id)
);

desc Evaluation ; 


-- Insertion des données

-- Hôtel
INSERT INTO Hotel VALUES
(1, 'Paris', 'France', 75001),
(2, 'Lyon', 'France', 69002);

-- Clients
INSERT INTO Client VALUES
(1, '12 Rue de Paris', 'Paris', 75001, 'jean.dupont@email.fr', '0612345678', 'Jean Dupont'),
(2, '5 Avenue Victor Hugo', 'Lyon', 69002, 'marie.leroy@email.fr', '0623456789', 'Marie Leroy'),
(3, '8 Boulevard Saint-Michel', 'Marseille', 13005, 'paul.moreau@email.fr', '0634567890', 'Paul Moreau'),
(4, '27 Rue Nationale', 'Lille', 59800, 'lucie.martin@email.fr', '0645678901', 'Lucie Martin'),
(5, '3 Rue des Fleurs', 'Nice', 6000, 'emma.giraud@email.fr', '0656789012', 'Emma Giraud');

-- Prestations
INSERT INTO Prestation VALUES
(1, 15, 'Petit-déjeuner'),
(2, 30, 'Navette aéroport'),
(3, 0, 'Wi-Fi gratuit'),
(4, 50, 'Spa et bien-être'),
(5, 20, 'Parking sécurisé');

-- Types de chambres
INSERT INTO TypeChambre VALUES
(1, 'Simple', 80),
(2, 'Double', 120);

-- Chambres
INSERT INTO Chambre VALUES
(1, 201, 2, 0, 1, 1),
(2, 502, 5, 1, 1, 2),
(3, 305, 3, 0, 2, 1),
(4, 410, 4, 0, 2, 2),
(5, 104, 1, 1, 2, 2),
(6, 202, 2, 0, 1, 1),
(7, 307, 3, 1, 1, 2),
(8, 101, 1, 0, 1, 1);

-- Réservations
INSERT INTO Reservation VALUES
(1, '2025-06-15', '2025-06-18', 1, 1),
(2, '2025-07-01', '2025-07-05', 2, 2),
(3, '2025-08-10', '2025-08-14', 3, 3),
(4, '2025-09-05', '2025-09-07', 4, 4),
(5, '2025-09-20', '2025-09-25', 5, 5),
(7, '2025-11-12', '2025-11-14', 2, 6),
(9, '2026-01-15', '2026-01-18', 4, 7),
(10, '2026-02-01', '2026-02-05', 2, 8);

-- Évaluations
INSERT INTO Evaluation VALUES
(1, '2025-06-15', 5, 'Excellent séjour, personnel très accueillant.', 1),
(2, '2025-07-01', 4, 'Chambre propre, bon rapport qualité/prix.', 2),
(3, '2025-08-10', 3, 'Séjour correct mais bruyant la nuit.', 3),
(4, '2025-09-05', 5, 'Service impeccable, je recommande.', 4),
(5, '2025-09-20', 4, 'Très bon petit-déjeuner, hôtel bien situé.', 5);
 

-- Afficher la liste des réservations avec le nom du client et la ville de l’hôtel réservé.

SELECT R.id, C.nom_complet, H.ville
FROM Reservation R
JOIN Client C ON R.id_client = C.id
JOIN Chambre CH ON R.id_chambre = CH.id
JOIN Hotel H ON CH.id_hotel = H.id;


--  Afficher les clients qui habitent à Paris.

SELECT * FROM Client
WHERE ville = 'Paris';

-- Calculer le nombre de réservations faites par chaque client.


SELECT C.nom_complet, COUNT(R.id) AS nb_reservations
FROM Client C
LEFT JOIN Reservation R ON R.id_client = C.id
GROUP BY C.nom_complet;



-- Donner le nombre de chambres pour chaque type de chambre


SELECT T.nom, COUNT(*) AS nb_chambres
FROM Chambre C
JOIN TypeChambre T ON C.id_type = T.id
GROUP BY T.nom;


-- Afficher la liste des chambres qui ne sont pas réservées pour une période


SELECT * FROM Chambre
WHERE id NOT IN (
    SELECT id_chambre
    FROM Reservation
    WHERE ('2025-07-01' BETWEEN date_debut AND date_fin)
       OR ('2025-07-05' BETWEEN date_debut AND date_fin)
);


