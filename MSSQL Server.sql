-- Comandos do dia a dia

-- ===============================
-- SQL SERVER
-- ===============================

-- Verificar informações da tabela
EXEC sp_help [schema.table];
OR --> OU
SELECT TAB1.* 
  FROM information_schema.columns TAB1
 WHERE TAB1.table_name = 'nome_tabela';

-- Descobrir nomes dos schemas
SELECT DISTINCT OBJECT_SCHEMA_NAME(object_id)  
FROM sys.objects;

-- Nome dos campos da tabela
SELECT s.name AS 'Schema'
	  ,t.name AS 'Tabela (Entidade)'
	  ,c.name AS 'Campos (Atributos)'
	  ,tp.name AS 'Tipo do Campo'
	  ,(CASE
		 WHEN tp.name = 'nvarchar' THEN (c.max_length/2)
		 WHEN tp.name = 'nchar' THEN (c.max_length/2)
		 ELSE c.max_length
	    END) AS 'Valor do Campo'
	  ,(CASE
		 WHEN c.is_nullable = 0 THEN 'NÃO'
		 ELSE 'SIM'
	    END) AS 'Null'
  FROM sys.columns AS c
  INNER JOIN sys.tables AS t ON t.object_id = c.object_id
  INNER JOIN sys.schemas AS s ON s.schema_id = t.schema_id
  LEFT JOIN sys.types AS tp ON tp.user_type_id = c.user_type_id
 WHERE 1 = 1
   AND t.object_id = object_id('simap.tb_ativo') 
   AND s.name = 'simap'
ORDER BY c.name;
OR
SELECT TAB1.TABLE_SCHEMA AS 'Schema'
	  ,TAB1.TABLE_NAME AS 'Tabela (Entidade)'
	  ,TAB1.COLUMN_NAME AS 'Campos (Atributos)'
	  ,TAB1.DATA_TYPE AS 'Tipo do Campo'
	  ,TAB1.CHARACTER_MAXIMUM_LENGTH AS 'Valor do Campo'
	  ,TAB4.TABLE_NAME AS 'Tabela Estrangeira'
	  ,TAB5.CONSTRAINT_TYPE
  FROM INFORMATION_SCHEMA.COLUMNS TAB1
 LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE TAB2 ON TAB1.TABLE_NAME = TAB2.TABLE_NAME 
														   AND TAB1.COLUMN_NAME = TAB2.COLUMN_NAME
 LEFT JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS TAB3 ON TAB2.CONSTRAINT_NAME = TAB3.CONSTRAINT_NAME
 LEFT JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE TAB4 ON TAB3.UNIQUE_CONSTRAINT_NAME = TAB4.CONSTRAINT_NAME
 LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS TAB5 ON TAB2.CONSTRAINT_NAME = TAB5.CONSTRAINT_NAME
 WHERE TAB1.table_name = 'nome_tabela';
OR
-- USAR ESSA CONSULTA PARA BUSCAR NOME DE FK DAS TABELAS
SELECT TAB2.CONSTRAINT_NAME
	  ,TAB1.* 
  FROM information_schema.columns TAB1
 LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE TAB2 ON TAB1.TABLE_NAME = TAB2.TABLE_NAME 
														   AND TAB1.COLUMN_NAME = TAB2.COLUMN_NAME
 WHERE TAB1.table_name = 'nome_tabela';
 
-- TABELAS NOVAS CRIADAS COM BASE NAS HU PRA INFORMAR AO DESENVOLVEDOR
SELECT TAB2.CONSTRAINT_NAME
	  ,TAB1.TABLE_SCHEMA
	  ,TAB1.TABLE_NAME
	  ,TAB1.COLUMN_NAME
	  ,TAB1.DATA_TYPE
	  ,TAB1.CHARACTER_MAXIMUM_LENGTH 
  FROM information_schema.columns TAB1
 LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE TAB2 ON TAB1.TABLE_NAME = TAB2.TABLE_NAME 
														   AND TAB1.COLUMN_NAME = TAB2.COLUMN_NAME
 WHERE TAB1.table_name = 'tb_devolucao_solicitacao';
 
-- Validar quantidades das tabelas em bases diferentes
SELECT s.name AS 'Schema'
	  ,t.name AS 'Tabela (Entidade)'
	  ,CONCAT('SELECT COUNT(*) FROM ',s.name,'.',t.name,';') AS 'Query'
  FROM sys.tables AS t
  INNER JOIN sys.schemas AS s ON s.schema_id = t.schema_id
 WHERE s.name = 'origem_DNN';
 
-- Informativo tabela Pai e Filhos
SELECT OBJECT_NAME(constid) FK
      ,OBJECT_NAME(FKEYID) Tabela_Filha
      ,OBJECT_NAME(rKEYID) Tabela_Pai
      ,COL_NAME(Rkeyid, Rkey) Colunas_Pai
      ,COL_NAME(fkeyid, fkey) Colunas_Pai
  FROM SYSFOREIGNKEYS;

-- DICIONARIO DE DADOS SQL SERVER

EXEC sp_addextendedproperty  
     @name = N'MS_Description' 
    ,@value = N'Descrever a informação ' 
    ,@level0type = N'Schema', @level0name = 'simap' 
    ,@level1type = N'Table',  @level1name = 'ta_plano_manutencao_equipamento' 
    ,@level2type = N'Column', @level2name = 'fk_grupo_equipamento';
OR
EXEC sp_addextendedproperty 'MS_Description', 'Identificador do Vínculo com as opções: 1- Requerente, 2- Imigrante e 3- Ambos', 'Schema', ESQUEMA, 'table', TABELA, 'column', COLUNA;

-- Comando para visualizar e gerar a documentação do Banco de Dados
SELECT t.name AS 'Tabela (Entidade)', 
	   c.name AS 'Colunas (Atributos)',
	   ep.value AS 'Descrição'
  FROM sys.extended_properties ep
  INNER JOIN sys.tables t ON ep.major_id = t.object_id
  LEFT JOIN sys.columns c ON ep.major_id = c.object_id AND ep.minor_id = c.column_id
 WHERE t.name = 'nome_tabela';
  
-- Liberar permissão do usuário.
GRANT SELECT ON SCHEMA :: [schema] TO [user];

-- Query para renomear DATABASE
USE master;  
GO  
ALTER DATABASE [RESOLUCAO20_CNMP] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
ALTER DATABASE [RESOLUCAO20_CNMP] MODIFY FILE (NAME = RESOLUCAO20_CNMP, NEWNAME = RESOLUCAO20_CNMP_OLD, FILENAME = 'E:\SQL\DEV2019\DATA\RESOLUCAO20_CNMP_OLD.mdf'); -- Renomear arquivo logico também
GO
ALTER DATABASE [RESOLUCAO20_CNMP] MODIFY FILE (NAME = RESOLUCAO20_CNMP_log, NEWNAME = RESOLUCAO20_CNMP_OLD_log, FILENAME = 'E:\SQL\DEV2019\DATALOG\RESOLUCAO20_CNMP_OLD_log.ldf'); -- Renomear arquivo logico também
GO
ALTER DATABASE [RESOLUCAO20_CNMP] MODIFY NAME = [RESOLUCAO20_CNMP_OLD];
GO  
ALTER DATABASE [RESOLUCAO20_CNMP_OLD] SET MULTI_USER;
GO

-- Query para identificar processos em execução no banco de dados
-- Obs.: Consultar a documentação da Microsoft a respeito dessa tabela.
SELECT * FROM sys.sysprocesses;
GO