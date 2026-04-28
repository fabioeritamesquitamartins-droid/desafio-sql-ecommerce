-- DESAFIO SQL E-COMMERCE
-- Autor: Fábio da Silva Martins
-- Data: 28/04/2026

CREATE DATABASE ecommerce;
USE ecommerce;

-- Refinamento 1: Cliente PF ou PJ, nunca os dois
CREATE TABLE CLIENTE (
    idCLIENTE INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    nome_razao_social VARCHAR(255) NOT NULL,
    tipo_pessoa ENUM('PF','PJ') NOT NULL,
    cpf VARCHAR(11) UNIQUE,
    cnpj VARCHAR(14) UNIQUE,
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_pessoa CHECK (
        (tipo_pessoa = 'PF' AND cpf IS NOT NULL AND cnpj IS NULL) OR
        (tipo_pessoa = 'PJ' AND cnpj IS NOT NULL AND cpf IS NULL)
    )
);

CREATE TABLE ENDERECO_CLIENTE (
    idENDERECO_CLIENTE INT AUTO_INCREMENT PRIMARY KEY,
    idCLIENTE INT NOT NULL,
    logradouro VARCHAR(255) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    uf CHAR(2) NOT NULL,
    cep VARCHAR(9) NOT NULL,
    is_principal BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (idCLIENTE) REFERENCES CLIENTE(idCLIENTE) ON DELETE CASCADE
);

-- Refinamento 2: Cliente pode ter N formas de pagamento
CREATE TABLE FORMA_PAGAMENTO (
    idFORMA_PAGAMENTO INT AUTO_INCREMENT PRIMARY KEY,
    idCLIENTE INT NOT NULL,
    tipo ENUM('CREDITO','DEBITO','PIX','BOLETO') NOT NULL,
    token_cartao VARCHAR(255),
    ultimos_digitos CHAR(4),
    ativo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (idCLIENTE) REFERENCES CLIENTE(idCLIENTE) ON DELETE CASCADE
);

CREATE TABLE PRODUTO (
    idPRODUTO INT AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(50) UNIQUE NOT NULL,
    nome_descricao TEXT NOT NULL,
    preco_base DECIMAL(10,2) NOT NULL CHECK (preco_base >= 0),
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE ESTOQUE (
    idESTOQUE INT AUTO_INCREMENT PRIMARY KEY,
    nome_deposito VARCHAR(100) NOT NULL,
    localizacao_fisica TEXT,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE VENDEDOR (
    idVENDEDOR INT AUTO_INCREMENT PRIMARY KEY,
    nome_fantasia VARCHAR(255) NOT NULL,
    cnpj VARCHAR(14) UNIQUE NOT NULL,
    comissao_plataforma DECIMAL(5,2) NOT NULL CHECK (comissao_plataforma >= 0 AND comissao_plataforma <= 100)
);

CREATE TABLE FORNECEDOR (
    idFORNECEDOR INT AUTO_INCREMENT PRIMARY KEY,
    razao_social VARCHAR(255) NOT NULL,
    cnpj VARCHAR(14) UNIQUE NOT NULL
);

-- Refinamento 3: Entrega com status e rastreio
CREATE TABLE PEDIDO (
    idPEDIDO INT AUTO_INCREMENT PRIMARY KEY,
    idCLIENTE INT NOT NULL,
    idENDERECO_CLIENTE INT NOT NULL,
    data_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
    status_pedido ENUM('CRIADO','PAGO','ENVIADO','ENTREGUE','CANCELADO') DEFAULT 'CRIADO',
    valor_total DECIMAL(10,2) NOT NULL CHECK (valor_total >= 0),
    status_entrega ENUM('AGUARDANDO','ENVIADO','EM_TRANSITO','ENTREGUE','DEVOLVIDO') DEFAULT 'AGUARDANDO',
    codigo_rastreio VARCHAR(50),
    FOREIGN KEY (idCLIENTE) REFERENCES CLIENTE(idCLIENTE),
    FOREIGN KEY (idENDERECO_CLIENTE) REFERENCES ENDERECO_CLIENTE(idENDERECO_CLIENTE)
);

CREATE TABLE PEDIDO_ITEM (
    idPEDIDO INT,
    idPRODUTO INT,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    preco_unitario_momento DECIMAL(10,2) NOT NULL,
    idESTOQUE INT,
    idVENDEDOR INT,
    PRIMARY KEY (idPEDIDO, idPRODUTO),
    FOREIGN KEY (idPEDIDO) REFERENCES PEDIDO(idPEDIDO) ON DELETE CASCADE,
    FOREIGN KEY (idPRODUTO) REFERENCES PRODUTO(idPRODUTO),
    FOREIGN KEY (idESTOQUE) REFERENCES ESTOQUE(idESTOQUE),
    FOREIGN KEY (idVENDEDOR) REFERENCES VENDEDOR(idVENDEDOR)
);

CREATE TABLE PRODUTO_ESTOQUE (
    idPRODUTO INT,
    idESTOQUE INT,
    quantidade INT NOT NULL DEFAULT 0 CHECK (quantidade >= 0),
    quantidade_reservada INT NOT NULL DEFAULT 0 CHECK (quantidade_reservada >= 0),
    PRIMARY KEY (idPRODUTO, idESTOQUE),
    FOREIGN KEY (idPRODUTO) REFERENCES PRODUTO(idPRODUTO),
    FOREIGN KEY (idESTOQUE) REFERENCES ESTOQUE(idESTOQUE),
    CONSTRAINT chk_reserva CHECK (quantidade_reservada <= quantidade)
);

CREATE TABLE VENDEDOR_PRODUTO (
    idVENDEDOR INT,
    idPRODUTO INT,
    preco_venda DECIMAL(10,2) NOT NULL CHECK (preco_venda >= 0),
    ativo BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (idVENDEDOR, idPRODUTO),
    FOREIGN KEY (idVENDEDOR) REFERENCES VENDEDOR(idVENDEDOR),
    FOREIGN KEY (idPRODUTO) REFERENCES PRODUTO(idPRODUTO)
);

CREATE TABLE FORNECEDOR_PRODUTO (
    idFORNECEDOR INT,
    idPRODUTO INT,
    idESTOQUE INT,
    custo_unitario DECIMAL(10,2) NOT NULL CHECK (custo_unitario >= 0),
    PRIMARY KEY (idFORNECEDOR, idPRODUTO, idESTOQUE),
    FOREIGN KEY (idFORNECEDOR) REFERENCES FORNECEDOR(idFORNECEDOR),
    FOREIGN KEY (idPRODUTO) REFERENCES PRODUTO(idPRODUTO),
    FOREIGN KEY (idESTOQUE) REFERENCES ESTOQUE(idESTOQUE)
);

CREATE TABLE PAGAMENTO_PEDIDO (
    idPAGAMENTO_PEDIDO INT AUTO_INCREMENT PRIMARY KEY,
    idPEDIDO INT NOT NULL,
    idFORMA_PAGAMENTO INT,
    valor_pago DECIMAL(10,2) NOT NULL CHECK (valor_pago > 0),
    status ENUM('PENDENTE','APROVADO','RECUSADO') DEFAULT 'PENDENTE',
    data_pagamento DATETIME,
    FOREIGN KEY (idPEDIDO) REFERENCES PEDIDO(idPEDIDO),
    FOREIGN KEY (idFORMA_PAGAMENTO) REFERENCES FORMA_PAGAMENTO(idFORMA_PAGAMENTO)
);

-- INSERTS.sql - Dados de teste
USE ecommerce;

-- CLIENTES PF e PJ
INSERT INTO CLIENTE (email, nome_razao_social, tipo_pessoa, cpf) VALUES 
('joao@email.com', 'João Silva', 'PF', '12345678901'),
('maria@email.com', 'Maria Santos', 'PF', '98765432100');

INSERT INTO CLIENTE (email, nome_razao_social, tipo_pessoa, cnpj) VALUES 
('contato@empresa.com', 'Empresa LTDA', 'PJ', '12345678000199'),
('vendas@loja.com', 'Loja SA', 'PJ', '98765432000188');

-- ENDEREÇOS
INSERT INTO ENDERECO_CLIENTE (idCLIENTE, logradouro, cidade, uf, cep, is_principal) VALUES
(1, 'Rua A, 100', 'Curitiba', 'PR', '80000-000', TRUE),
(3, 'Av. Brasil, 500', 'São Paulo', 'SP', '01000-000', TRUE);

-- FORMAS DE PAGAMENTO - Cliente 1 tem 2
INSERT INTO FORMA_PAGAMENTO (idCLIENTE, tipo, ultimos_digitos) VALUES
(1, 'CREDITO', '1234'),
(1, 'PIX', NULL),
(3, 'BOLETO', NULL);

-- PRODUTOS, ESTOQUES, VENDEDOR, FORNECEDOR
INSERT INTO PRODUTO (sku, nome_descricao, preco_base) VALUES
('NOTE-001', 'Notebook Dell 16GB', 4500.00),
('MOUSE-001', 'Mouse Logitech MX', 350.00),
('TECL-001', 'Teclado Mecânico', 500.00);

INSERT INTO ESTOQUE (nome_deposito, localizacao_fisica) VALUES
('CD Curitiba', 'Rua Industrial, 1000'),
('CD São Paulo', 'Rod. Anhanguera, 500');

INSERT INTO VENDEDOR (nome_fantasia, cnpj, comissao_plataforma) VALUES
('Tech Store', '11111111000111', 10.00);

INSERT INTO FORNECEDOR (razao_social, cnpj) VALUES
('Dell Brasil', '22222222000122'),
('Tech Store', '11111111000111'); -- Vendedor que também é fornecedor

-- ESTOQUE DE PRODUTOS
INSERT INTO PRODUTO_ESTOQUE (idPRODUTO, idESTOQUE, quantidade, quantidade_reservada) VALUES
(1, 1, 50, 5),
(1, 2, 30, 0),
(2, 1, 100, 10),
(3, 2, 20, 2);

-- PEDIDOS com entrega
INSERT INTO PEDIDO (idCLIENTE, idENDERECO_CLIENTE, status_pedido, valor_total, status_entrega, codigo_rastreio) VALUES
(1, 1, 'PAGO', 4850.00, 'ENVIADO', 'BR123456789'),
(1, 1, 'ENTREGUE', 350.00, 'ENTREGUE', 'BR987654321'),
(3, 2, 'CRIADO', 500.00, 'AGUARDANDO', NULL);

INSERT INTO PEDIDO_ITEM (idPEDIDO, idPRODUTO, quantidade, preco_unitario_momento, idESTOQUE, idVENDEDOR) VALUES
(1, 1, 1, 4500.00, 1, 1),
(1, 2, 1, 350.00, 1, NULL), -- Venda própria
(2, 2, 1, 350.00, 1, NULL),
(3, 3, 1, 500.00, 2, 1);

-- PAGAMENTOS
INSERT INTO PAGAMENTO_PEDIDO (idPEDIDO, idFORMA_PAGAMENTO, valor_pago, status, data_pagamento) VALUES
(1, 1, 4850.00, 'APROVADO', NOW()),
(2, 2, 350.00, 'APROVADO', NOW());

-- RELACIONAMENTOS
INSERT INTO VENDEDOR_PRODUTO (idVENDEDOR, idPRODUTO, preco_venda) VALUES
(1, 1, 4600.00),
(1, 3, 520.00);

INSERT INTO FORNECEDOR_PRODUTO (idFORNECEDOR, idPRODUTO, idESTOQUE, custo_unitario) VALUES
(1, 1, 1, 3800.00),
(2, 2, 1, 280.00);

-- QUERIES.sql - Todas as cláusulas obrigatórias


-- 1. SELECT simples + WHERE: Produtos ativos com preço > 400
-- Pergunta: Quais produtos ativos custam mais de R$400?
SELECT sku, nome_descricao, preco_base 
FROM PRODUTO 
WHERE ativo = TRUE AND preco_base > 400;

-- 2. Atributo derivado + ORDER BY: Ticket médio por cliente
-- Pergunta: Qual o ticket médio gasto por cada cliente, do maior pro menor?
SELECT 
    c.nome_razao_social,
    COUNT(p.idPEDIDO) AS total_pedidos,
    SUM(p.valor_total) AS valor_total_gasto,
    ROUND(SUM(p.valor_total) / COUNT(p.idPEDIDO), 2) AS ticket_medio
FROM CLIENTE c
JOIN PEDIDO p ON c.idCLIENTE = p.idCLIENTE
GROUP BY c.idCLIENTE, c.nome_razao_social
ORDER BY ticket_medio DESC;

-- 3. HAVING: Clientes com mais de 1 pedido
-- Pergunta: Quantos pedidos foram feitos por cada cliente? Filtrar só quem fez mais de 1
SELECT 
    c.nome_razao_social,
    COUNT(p.idPEDIDO) AS qtd_pedidos
FROM CLIENTE c
LEFT JOIN PEDIDO p ON c.idCLIENTE = p.idCLIENTE
GROUP BY c.idCLIENTE, c.nome_razao_social
HAVING COUNT(p.idPEDIDO) > 1;

-- 4. JOIN complexo + atributo derivado: Relação produtos, fornecedores e estoques
-- Pergunta: Qual a relação de produtos, fornecedores, estoques e margem de lucro?
SELECT 
    pr.nome_descricao AS produto,
    f.razao_social AS fornecedor,
    e.nome_deposito AS estoque,
    pe.quantidade AS qtd_disponivel,
    fp.custo_unitario,
    pr.preco_base,
    ROUND(((pr.preco_base - fp.custo_unitario) / fp.custo_unitario) * 100, 2) AS margem_lucro_pct
FROM PRODUTO pr
JOIN FORNECEDOR_PRODUTO fp ON pr.idPRODUTO = fp.idPRODUTO
JOIN FORNECEDOR f ON fp.idFORNECEDOR = f.idFORNECEDOR
JOIN ESTOQUE e ON fp.idESTOQUE = e.idESTOQUE
JOIN PRODUTO_ESTOQUE pe ON pr.idPRODUTO = pe.idPRODUTO AND e.idESTOQUE = pe.idESTOQUE
ORDER BY margem_lucro_pct DESC;

-- 5. JOIN + WHERE: Algum vendedor também é fornecedor?
-- Pergunta: Existe vendedor que também atua como fornecedor?
SELECT 
    v.nome_fantasia AS vendedor,
    v.cnpj,
    f.razao_social AS fornecedor
FROM VENDEDOR v
INNER JOIN FORNECEDOR f ON v.cnpj = f.cnpj
WHERE v.cnpj IS NOT NULL;

-- 6. Junção tripla: Relação nomes fornecedores e produtos
-- Pergunta: Quais fornecedores abastecem quais produtos e em qual estoque?
SELECT 
    f.razao_social AS fornecedor,
    pr.nome_descricao AS produto,
    e.nome_deposito AS estoque,
    fp.custo_unitario
FROM FORNECEDOR f
JOIN FORNECEDOR_PRODUTO fp ON f.idFORNECEDOR = fp.idFORNECEDOR
JOIN PRODUTO pr ON fp.idPRODUTO = pr.idPRODUTO
JOIN ESTOQUE e ON fp.idESTOQUE = e.idESTOQUE
ORDER BY f.razao_social, pr.nome_descricao;

-- 7. Consulta complexa: Saldo real de estoque + status entrega
-- Pergunta: Qual o saldo real de cada produto por estoque e status das entregas?
SELECT 
    pr.sku,
    pr.nome_descricao,
    e.nome_deposito,
    pe.quantidade AS qtd_fisica,
    pe.quantidade_reservada,
    (pe.quantidade - pe.quantidade_reservada) AS saldo_disponivel_venda,
    p.codigo_rastreio,
    p.status_entrega
FROM PRODUTO pr
JOIN PRODUTO_ESTOQUE pe ON pr.idPRODUTO = pe.idPRODUTO
JOIN ESTOQUE e ON pe.idESTOQUE = e.idESTOQUE
LEFT JOIN PEDIDO_ITEM pi ON pr.idPRODUTO = pi.idPRODUTO AND e.idESTOQUE = pi.idESTOQUE
LEFT JOIN PEDIDO p ON pi.idPEDIDO = p.idPEDIDO
WHERE pr.ativo = TRUE
ORDER BY saldo_disponivel_venda ASC, pr.sku;

