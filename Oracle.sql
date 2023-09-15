-- Comandos do dia a dia

-- ===============================
-- ORACLE
-- ===============================

-- Verificar informações de tabela
select col.column_id,
col.owner as schema_name,
col.table_name,
col.column_name,
col.data_type,
col.data_length,
col.data_precision,
col.data_scale,
col.nullable
from sys.all_tab_columns col
where col.table_name = 'TB_PER_PERSONALIDADE' --> É casesensitive
  and col.owner = 'ORCRIM'
order by col.column_name desc;

-- Verificar quantidade de colunas das tabelas de acordo com o schema
select col.owner as schema_name,
col.table_name,
count(col.column_name) as qtd_colunas
from sys.all_tab_columns col
where col.owner = 'ORCRIM'
group by col.owner,col.table_name
order by col.table_name;

-- Verificar sequences criadas no DB
select TAB1.owner as schema_name,
       TAB1.object_name AS name_sequence
  from all_objects TAB1
 where object_type = 'SEQUENCE'
   and TAB1.owner = 'ORCRIM';

-- Verificar Indices no DB
select ind.index_name,
       ind_col.column_name,
       ind.index_type,
       ind.uniqueness,
       ind.table_owner as schema_name,
       ind.table_name as object_name,
       ind.table_type as object_type       
from sys.all_indexes ind
inner join sys.all_ind_columns ind_col on ind.owner = ind_col.index_owner
                                    and ind.index_name = ind_col.index_name
where ind.owner IN ('APOIO', 'AUDITORIA', 'ORCRIM', 'SEG')
order by ind.table_owner,
         ind.table_name,
         ind.index_name,
         ind_col.column_position;
		 
-- Tabelas das sessões e processos em andamento (Verificar as conexões e devidas inforamções (X9)).
SELECT * 
FROM V$SESSION;

SELECT vse.SID, vse.SERIAL#, vse.USERNAME, vse.*
FROM V$SESSION vse 
WHERE vse.USERNAME = 'Owner';

SELECT isql.sql_text, vse.*
FROM V$SESSION vse
JOIN V$PROCESS vpr ON vse.PADDR = vpr.ADDR
JOIN V$SQLAREA isql ON isql.hash_value = vse.sql_hash_value
WHERE vse.USERNAME = 'Owner';