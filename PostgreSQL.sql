-- Comandos do dia a dia

-- ===============================
-- POSTGRESQL
-- ===============================
-- Versão
SELECT VERSION();
-- Retorna o valor atual da sequence usado pelo NEXTVALUE.
SELECT CURRVAL('nome_sequence');
-- Retorna o valor atual da sequence
SELECT last_value FROM 'nome_sequence';
-- Retornar as FK do DATABASE (Integridade Referencial)
SELECT * FROM pg_constraint WHERE contype = 'f' AND connamespace = 'public'::regnamespace;
-- Visualizar GRANT sequences
SELECT TAB1.* 
FROM information_schema.role_usage_grants TAB1
WHERE TAB1.object_schema = 'nome_schema';
-- Visualizar GRANT tables
SELECT 
	TAB1.grantor
	,TAB1.grantee
	,TAB1.table_schema
	,TAB1.table_name
	,TAB1.privilege_type
FROM information_schema.table_privileges TAB1
WHERE TAB1.table_schema = 'nome_schema';