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
