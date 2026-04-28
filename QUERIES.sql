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
