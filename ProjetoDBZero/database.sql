DROP DATABASE IF EXISTS oficina_desafio_dio;
CREATE DATABASE oficina_desafio_dio;
USE oficina_desafio_dio;

CREATE TABLE Clientes (
    cliente_id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(11) UNIQUE NOT NULL,
    telefone VARCHAR(15),
    endereco VARCHAR(255)
);

CREATE TABLE Veiculos (
    veiculo_id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT,
    placa CHAR(7) UNIQUE NOT NULL,
    modelo VARCHAR(50),
    ano INT,
    FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id)
);

CREATE TABLE Equipes (
    equipe_id INT PRIMARY KEY AUTO_INCREMENT,
    especialidade VARCHAR(100) NOT NULL
);

CREATE TABLE Mecanicos (
    mecanico_id INT PRIMARY KEY AUTO_INCREMENT,
    equipe_id INT,
    nome VARCHAR(100) NOT NULL,
    codigo VARCHAR(10) UNIQUE NOT NULL,
    FOREIGN KEY (equipe_id) REFERENCES Equipes(equipe_id)
);

CREATE TABLE Ordens_de_Servico (
    os_id INT PRIMARY KEY AUTO_INCREMENT,
    veiculo_id INT,
    equipe_id INT,
    data_emissao DATE NOT NULL,
    data_conclusao DATE,
    valor_total DECIMAL(10, 2),
    status ENUM('Aguardando', 'Em andamento', 'Concluído', 'Cancelado') NOT NULL,
    FOREIGN KEY (veiculo_id) REFERENCES Veiculos(veiculo_id),
    FOREIGN KEY (equipe_id) REFERENCES Equipes(equipe_id)
);

CREATE TABLE Servicos (
    servico_id INT PRIMARY KEY AUTO_INCREMENT,
    descricao VARCHAR(255) NOT NULL,
    valor_mao_de_obra DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Pecas (
    peca_id INT PRIMARY KEY AUTO_INCREMENT,
    nome_peca VARCHAR(100) NOT NULL,
    valor_unitario DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Servicos_em_OS (
    os_id INT,
    servico_id INT,
    PRIMARY KEY (os_id, servico_id),
    FOREIGN KEY (os_id) REFERENCES Ordens_de_Servico(os_id),
    FOREIGN KEY (servico_id) REFERENCES Servicos(servico_id)
);

CREATE TABLE Pecas_em_OS (
    os_id INT,
    peca_id INT,
    quantidade INT NOT NULL,
    PRIMARY KEY (os_id, peca_id),
    FOREIGN KEY (os_id) REFERENCES Ordens_de_Servico(os_id),
    FOREIGN KEY (peca_id) REFERENCES Pecas(peca_id)
);

INSERT INTO Clientes (nome, cpf, telefone, endereco) VALUES
('Carlos Mendes', '11122233344', '11988776655', 'Rua Alfa, 10'),
('Beatriz Costa', '55566677788', '21977665544', 'Rua Beta, 20');

INSERT INTO Veiculos (cliente_id, placa, modelo, ano) VALUES
(1, 'ABC1D23', 'Toyota Corolla', 2020),
(2, 'XYZ9H87', 'Honda Civic', 2019),
(1, 'QWE4R56', 'Ford Ka', 2018);

INSERT INTO Equipes (especialidade) VALUES ('Motor e Transmissão'), ('Elétrica e Injeção');
INSERT INTO Mecanicos (equipe_id, nome, codigo) VALUES
(1, 'Roberto Alves', 'MEC001'),
(1, 'Fernando Lima', 'MEC002'),
(2, 'Ana Paula', 'MEC003');

INSERT INTO Servicos (descricao, valor_mao_de_obra) VALUES
('Troca de óleo e filtro', 100.00),
('Alinhamento e Balanceamento', 150.00),
('Troca de pastilhas de freio', 120.00);

INSERT INTO Pecas (nome_peca, valor_unitario) VALUES
('Óleo 5W30 (Litro)', 50.00),
('Filtro de Óleo', 30.00),
('Pastilha de Freio (Par)', 180.00);

INSERT INTO Ordens_de_Servico (veiculo_id, equipe_id, data_emissao, data_conclusao, status) VALUES
(1, 1, '2023-08-01', '2023-08-02', 'Concluído'),
(2, 2, '2023-08-03', NULL, 'Em andamento'),
(3, 1, '2023-08-05', '2023-08-05', 'Concluído');

INSERT INTO Servicos_em_OS (os_id, servico_id) VALUES (1, 1), (2, 3), (3, 2);
INSERT INTO Pecas_em_OS (os_id, peca_id, quantidade) VALUES (1, 1, 4), (1, 2, 1), (2, 3, 1);

UPDATE Ordens_de_Servico SET valor_total = 
    (SELECT SUM(s.valor_mao_de_obra) FROM Servicos_em_OS sos JOIN Servicos s ON sos.servico_id = s.servico_id WHERE sos.os_id = 1) +
    (SELECT SUM(p.valor_unitario * pos.quantidade) FROM Pecas_em_OS pos JOIN Pecas p ON pos.peca_id = p.peca_id WHERE pos.os_id = 1)
WHERE os_id = 1;

SELECT placa, modelo, ano FROM Veiculos WHERE status = 'Em andamento';
SELECT c.nome, v.placa, os.data_emissao, os.status FROM Ordens_de_Servico os JOIN Veiculos v ON os.veiculo_id = v.veiculo_id JOIN Clientes c ON v.cliente_id = c.cliente_id ORDER BY c.nome, os.data_emissao DESC;
SELECT os.os_id, os.data_emissao, (SELECT SUM(s.valor_mao_de_obra) FROM Servicos_em_OS sos JOIN Servicos s ON sos.servico_id = s.servico_id WHERE sos.os_id = os.os_id) + (SELECT IFNULL(SUM(p.valor_unitario * pos.quantidade), 0) FROM Pecas_em_OS pos JOIN Pecas p ON pos.peca_id = p.peca_id WHERE pos.os_id = os.os_id) AS valor_calculado FROM Ordens_de_Servico os;
SELECT e.especialidade, COUNT(os.os_id) AS total_os FROM Ordens_de_Servico os JOIN Equipes e ON os.equipe_id = e.equipe_id GROUP BY e.especialidade HAVING total_os > 0;
SELECT c.nome, COUNT(v.veiculo_id) AS total_veiculos FROM Clientes c JOIN Veiculos v ON c.cliente_id = v.cliente_id GROUP BY c.nome;
