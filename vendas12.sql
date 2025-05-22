CREATE DATABASE vendas12;
USE vendas12;

CREATE TABLE Clientes (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    Nome VARCHAR(100),
    Email VARCHAR(100)
);

CREATE TABLE Fornecedores (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    Nome VARCHAR(100),
    Contato VARCHAR(100)
);

CREATE TABLE Estoque (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    Produto VARCHAR(100),
    Quantidade INT,
    ID_Fornecedor INT,
    FOREIGN KEY (ID_Fornecedor) REFERENCES Fornecedores(ID)
);

CREATE TABLE Pedidos (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    Produto VARCHAR(100),
    Quantidade INT,
    ID_Cliente INT,
    Statuss VARCHAR(50) DEFAULT 'Pendente',
    DataPedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ID_Cliente) REFERENCES Clientes(ID)
);

CREATE TABLE Historico_Pedidos (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    Produto VARCHAR(100),
    Quantidade INT,
    ID_Cliente INT,
    Statuss VARCHAR(50),
    DataPedido TIMESTAMP,
    FOREIGN KEY (ID_Cliente) REFERENCES Clientes(ID)
);

INSERT INTO Fornecedores (Nome, Contato) VALUES
('Distribuidora Central', 'contato@central.com'),
('Fornecedora Alfa', 'alfa@fornecedores.com'),
('Mercado Tech', 'vendas@mercadotech.com'),
('Alpha Import', 'import@alpha.com'),
('Distribuição Rápida', 'contato@rapida.com'),
('Fornecedor Beta', 'beta@fornecedores.com');

INSERT INTO Clientes (Nome, Email) VALUES
('João Silva', 'joao.silva@email.com'),
('Maria Oliveira', 'maria.oliveira@email.com'),
('Carlos Souza', 'carlos.souza@email.com'),
('Fernanda Lima', 'fernanda.lima@email.com'),
('Bruno Rocha', 'bruno.rocha@email.com'),
('Ana Costa', 'ana.costa@email.com');

INSERT INTO Estoque (Produto, Quantidade, ID_Fornecedor) VALUES
('Teclado Gamer', 50, 1),
('Mouse Óptico', 100, 2),
('Monitor LED 24"', 30, 3),
('Notebook i5', 20, 4),
('HD Externo 1TB', 40, 5),
('Webcam Full HD', 60, 6);

INSERT INTO Pedidos (Produto, Quantidade, ID_Cliente, Statuss) VALUES
('Teclado Gamer', 2, 1, 'Pendente'),
('Mouse Óptico', 1, 2, 'Enviado'),
('Monitor LED 24"', 1, 3, 'Cancelado'),
('Notebook i5', 1, 4, 'Pendente'),
('HD Externo 1TB', 2, 5, 'Enviado'),
('Webcam Full HD', 3, 6, 'Pendente');

INSERT INTO Historico_Pedidos (Produto, Quantidade, ID_Cliente, Statuss, DataPedido) VALUES
('Teclado Gamer', 2, 1, 'Entregue', '2024-05-10 14:30:00'),
('Mouse Óptico', 1, 2, 'Entregue', '2024-05-12 10:15:00'),
('Monitor LED 24"', 1, 3, 'Cancelado', '2024-05-14 09:45:00'),
('Notebook i5', 1, 4, 'Entregue', '2024-05-15 16:00:00'),
('HD Externo 1TB', 2, 5, 'Entregue', '2024-05-17 11:30:00'),
('Webcam Full HD', 3, 6, 'Pendente', '2024-05-18 13:20:00');

CREATE VIEW View_Pedidos_Confirmados AS
SELECT P.ID, C.Nome AS Cliente, P.Produto, P.Quantidade, P.Statuss, P.DataPedido
FROM Pedidos P
JOIN Clientes C ON P.ID_Cliente = C.ID
WHERE P.Statuss = 'Confirmado';

DELIMITER //
CREATE FUNCTION TotalPedidosCliente(clienteID INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total FROM Pedidos WHERE ID_Cliente = clienteID;
    RETURN total;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE FazerPedido(
    IN nomeProduto VARCHAR(100),
    IN qtd INT,
    IN clienteID INT
)
BEGIN
    DECLARE estoqueDisponivel INT;
    SELECT Quantidade INTO estoqueDisponivel FROM Estoque WHERE Produto = nomeProduto;

    IF estoqueDisponivel IS NOT NULL AND estoqueDisponivel >= qtd THEN
        INSERT INTO Pedidos (Produto, Quantidade, ID_Cliente)
        VALUES (nomeProduto, qtd, clienteID);
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Produto inexistente ou estoque insuficiente.';
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER AtualizaEstoqueEHistorico
AFTER UPDATE ON Pedidos
FOR EACH ROW
BEGIN
    IF NEW.Statuss = 'Confirmado' AND OLD.Statuss != 'Confirmado' THEN
        UPDATE Estoque
        SET Quantidade = Quantidade - NEW.Quantidade
        WHERE Produto = NEW.Produto;

        INSERT INTO Historico_Pedidos (Produto, Quantidade, ID_Cliente, Statuss, DataPedido)
        VALUES (NEW.Produto, NEW.Quantidade, NEW.ID_Cliente, NEW.Statuss, NEW.DataPedido);
    END IF;
END //
DELIMITER ;

INSERT INTO Fornecedores (Nome, Contato) VALUES ('Novo Fornecedor', 'novo@forn.com');

INSERT INTO Clientes (Nome, Email) VALUES ('Lucas Martins', 'lucas@email.com');

INSERT INTO Estoque (Produto, Quantidade, ID_Fornecedor) VALUES ('Cadeira Gamer', 10, 1);

CALL FazerPedido('Cadeira Gamer', 2, 7); 

UPDATE Pedidos SET Statuss = 'Confirmado' WHERE ID = 7;

SELECT * FROM Pedidos WHERE ID = 7;

SELECT * FROM Estoque WHERE Produto = 'Cadeira Gamer';

SELECT * FROM Historico_Pedidos WHERE Produto = 'Cadeira Gamer';

SELECT * FROM View_Pedidos_Confirmados;
