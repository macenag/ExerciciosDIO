
DROP DATABASE IF EXISTS desafiodio_simplificado;

CREATE DATABASE desafiodio_simplificado;

USE desafiodio_simplificado;


-- Tabela de Clientes
CREATE TABLE Clientes (
    cliente_id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(15),
    endereco VARCHAR(255)
);

-- Tabela de Produtos
CREATE TABLE Produtos (
    produto_id INT PRIMARY KEY AUTO_INCREMENT,
    nome_produto VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10, 2) NOT NULL CHECK (preco > 0),
    estoque INT NOT NULL DEFAULT 0
);

-- Tabela de Pedidos
CREATE TABLE Pedidos (
    pedido_id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT,
    data_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
    status_pedido VARCHAR(50) DEFAULT 'Processando',
    FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id)
);

-- Tabela de Itens do Pedido
CREATE TABLE Itens_Pedido (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    pedido_id INT,
    produto_id INT,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES Pedidos(pedido_id),
    FOREIGN KEY (produto_id) REFERENCES Produtos(produto_id)
);


INSERT INTO Clientes (nome, email, telefone, endereco) VALUES
('João Silva', 'joao.silva@example.com', '11987654321', 'Rua Fictícia, 123'),
('Maria Oliveira', 'maria.oliveira@example.com', '21912345678', 'Avenida Principal, 456');

INSERT INTO Produtos (nome_produto, descricao, preco, estoque) VALUES
('Notebook Pro', 'Notebook de alta performance', 5500.00, 10),
('Mouse Sem Fio', 'Mouse ergonômico', 150.00, 50),
('Teclado Mecânico', 'Teclado com switches blue', 350.00, 25);

INSERT INTO Pedidos (cliente_id, status_pedido) VALUES
(1, 'Concluído'),
(2, 'Enviado'),
(1, 'Processando');

INSERT INTO Itens_Pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES
(1, 1, 1, 5500.00),
(1, 2, 1, 150.00),
(2, 3, 2, 350.00),
(3, 2, 1, 150.00);

-- 1. Recuperação simples de todos os clientes
SELECT * FROM Clientes;

-- 2. Filtro de produtos com preço maior que 300
SELECT nome_produto, preco FROM Produtos WHERE preco > 300.00;

-- 3. Atributo derivado: valor total do estoque por produto
SELECT nome_produto, estoque, preco, (estoque * preco) AS valor_total_estoque
FROM Produtos
ORDER BY valor_total_estoque DESC;

-- 4. Agrupamento de itens por pedido com mais de 1 item
SELECT pedido_id, SUM(quantidade) AS total_itens, SUM(quantidade * preco_unitario) AS valor_total
FROM Itens_Pedido
GROUP BY pedido_id
HAVING total_itens > 1;

-- 5. Junção de tabelas para ver detalhes dos pedidos por cliente
SELECT
    c.nome AS nome_cliente,
    p.pedido_id,
    p.data_pedido,
    p.status_pedido,
    pr.nome_produto,
    ip.quantidade
FROM Pedidos p
JOIN Clientes c ON p.cliente_id = c.cliente_id
JOIN Itens_Pedido ip ON p.pedido_id = ip.pedido_id
JOIN Produtos pr ON ip.produto_id = pr.produto_id
ORDER BY c.nome, p.pedido_id;

