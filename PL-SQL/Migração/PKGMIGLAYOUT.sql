select PKGMIGLAYOUT.mostrar(PKGMIGPESSOA.especificacaoLayout()) from dual;
/

select * from table(PKGMIGLAYOUT.listar(PKGMIGPESSOA.especificacaoLayout()));
/

select * from table(PKGMIGLAYOUT.listarEstatisticaDescritiva(
                      PKGMIGPESSOA.especificacaoLayout(), 'emigpessoa_202210201319','sigrhmig')
                   );
/

select * from table(PKGMIGPESSOA.listarEstatisticaDescritiva('emigpessoa_202210201319','sigrhmig'));
/

--- Remover o Pacote
drop package PKGMIGLAYOUT;
/

create or replace
package PKGMIGLAYOUT is
-- Criar o Especificação do Pacote

type layoutTabelaLinha is record(
  grupo varchar2(50),
  campo varchar2(50),
  descricao varchar2(250),
  tipo varchar2(10),
  tamanho varchar2(5),
  obrigatorio varchar2(3),
  padrao varchar2(250),
  dominio varchar2(250),
  regrasvalidacao varchar2(250),
  sigrh varchar2(250)
);
type layoutTabela is table of layoutTabelaLinha;

type validacaoTabelaLinha is record(
  campo varchar2(50),
  obrigatorio varchar2(3),
  tamanho varchar2(5),
  regravalidacao varchar2(250),
  dominio varchar2(250),
  tipo varchar2(10),
  ordem number(3)
);
type validacaoTabela is table of validacaoTabelaLinha;

type arquivoMigracaoTabelaLinha is record(
nmarquivo varchar2(50),
nuregistro number(8),
jschaveunica varchar(500),
jscampos clob
);
type arquivoMigracaoTabela is table of arquivoMigracaoTabelaLinha;

type estatisticaDescritivaTabelaLinha is record(
  campo     varchar2(50),
  ordem     number(3),
  status    varchar2(50),
  registros number(8),
  unicos    number(8),
  nulos     number(8),
  zeros     number(8),
  numericos number(8),
  datas     number(8),
  invalidos number(8),
  validos   number(5,2),
  minimos   number(20),
  maximos   number(20),
  padrao    varchar2(50),
  dominio   varchar2(1500)
);
type estatisticaDescritivaTabela is table of estatisticaDescritivaTabelaLinha;

function normalizarString(pTexto varchar2) return varchar2;
function centralizarString(pTexto varchar2, pTamanho number) return varchar2;

function mostrar(docJSON in clob) return clob;
function listar(docJSON in clob) return layoutTabela pipelined;

function listarValidacao(docJSON in clob) return sys_refcursor;

function gerarSQLEstatisticasArquivo(
  pNomeTabela in varchar2,
  pCampo in varchar2,
  pObrigatorio in varchar2,
  pTamanho in varchar2,
  pRegraValidacao in varchar2,
  pDominio in varchar2,
  pTipo in varchar2,
  pOrdem in number,
  pStatus in varchar2 default null
) return varchar2;

function listarEstatisticaDescritiva(
  pdocJSON in clob,
  pNomeTabela in varchar2,
  pProprietario in varchar2 default null
) return estatisticaDescritivaTabela pipelined;

end PKGMIGLAYOUT;
/

create or replace
package body PKGMIGLAYOUT is
-- Criar o Corpo do Pacote

function normalizarString(pTexto varchar2) return varchar2 as
begin
 return translate(
    regexp_replace(
      upper(trim(replace(pTexto, '''', ''))),
      '[[:space:]]+', chr(32)
    ),
    'ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÏÖÜÇÑŠÝŸŽåáéíóúàèìòùâêîôûãõëïöüçñšýÿž',
    'AEIOUAEIOUAEIOUAOEIOUCNSYYZaaeiouaeiouaeiouaoeioucnsyyz'
  );
end normalizarString;

function centralizarString(pTexto varchar2, pTamanho number) return varchar2 as  
begin  
 return lpad(rpad(pTexto,length(pTexto) + (pTamanho - length(pTexto) - 1) / 2,' '),pTamanho,' ');
end centralizarString;

function mostrar(docJSON in clob) return clob as
begin
 return json_query(docJSON, '$' returning clob pretty);
end mostrar;

function listar(docJSON in clob) return layoutTabela pipelined as

cursor cListaLayout(docJSON in clob) is
select
  grupo,
  campo,
  descricao,
  tipo,
  tamanho,
  obrigatorio,
  padrao,
  dominio,
  regrasvalidacao,
  sigrh
from json_table(docJSON, '$' columns (
  familiaarquivos varchar2(250) path '$.FamiliaArquivos',
  nested path '$.Arquivos' columns (
    arquivo varchar2(250) path '$.Arquivo',
    versao varchar2(250) path '$.Versão',
    tabela varchar2(250) path '$.Tabela',
    nested Path '$.Grupos[*]' columns (
      grupo Varchar2(50) Path '$.Grupo',
      nested path '$.Campos[*]' columns (
        campo varchar2(50) path '$.Campo',
        descricao varchar2(250) Path '$.Descrição',
        tipo varchar2(10) Path '$.Tipo',
        tamanho varchar2(5) path '$.Tamanho',
        obrigatorio varchar2(3) path '$.Obrigatório',
        padrao varchar2(250) path '$.Padrão',
        dominio varchar2(250) format json path '$.Domínio',
        regrasvalidacao varchar2(250) format json path '$.RegrasValidação',
        sigrh varchar2(250) format json path '$.SIGRH'
       )
     )
   )
 ));

begin
  for item in cListaLayout(docJSON) loop
    pipe row(layoutTabelaLinha(
      item.grupo,
      item.campo,
      item.descricao,
      item.tipo,
      item.tamanho,
      item.obrigatorio,
      item.padrao,
      item.dominio,
      item.regrasvalidacao,
      item.sigrh
    ));
  end loop; 

end listar;

function listarValidacao(docJSON in clob) return sys_refcursor as

vValidacaoRefCursor sys_refcursor;
vValidacaoTabela validacaoTabela;

cursor cListaLayout(docJSON clob) is
select
  campo,
  obrigatorio,
  tamanho,
  regravalidacao,
  dominio,
  tipo,
  rownum as ordem
from json_table(docJSON, '$.Arquivos.Grupos[*].Campos[*]' columns (
    campo varchar2(50) path '$.Campo',
    descricao varchar2(250) Path '$.Descrição',
    tipo varchar2(10) Path '$.Tipo',
    tamanho varchar2(5) path '$.Tamanho',
    obrigatorio varchar2(3) path '$.Obrigatório',
    padrao varchar2(250) path '$.Padrão',
    dominio varchar2(250) format json path '$.Domínio',
    nested path '$.RegrasValidação[*]' columns (
      regravalidacao varchar2(250) path '$'
    )
 ));

begin
  open cListaLayout(docJSON);
  fetch cListaLayout bulk collect into vValidacaoTabela;
  close cListaLayout;
  open vValidacaoRefCursor for select * from table (vValidacaoTabela);
  return vValidacaoRefCursor;
end listarValidacao;

function gerarSQLEstatisticasArquivo(
  pNomeTabela in varchar2,
  pCampo in varchar2,
  pObrigatorio in varchar2,
  pTamanho in varchar2,
  pRegraValidacao in varchar2,
  pDominio in varchar2,
  pTipo in varchar2,
  pOrdem in number,
  pStatus in varchar2 default null
) return varchar2 is
begin

  if pStatus = 'Ausente' then
    return 'select ''' || pCampo || ''' as campo, ' || pOrdem || ' as ordem, ''' || pStatus || ''' as status,
            null as registros,
            null as unicos,
            null as nulos,
            null as zeros,
            null as numericos,
            null as datas,
            null as invalidos,
            null as validos,
            null as minimos,
            null as maximos,
            null as padrao,
            null as dominio
            from dual';
  end if;

  return '
with
listaunicos as (select distinct ' || pCampo || ' from ' || pNomeTabela || '),
lista as (
select ''' || pCampo || ''' as campolista, listagg(' || pCampo || ', ''; '') within group (order by ' || pCampo || ') as dominio
from listaunicos
where (select count(*) from listaunicos) < 50  
),
estatistica as (
select ''' || pCampo || ''' as campo, ' || pOrdem || ' as ordem, ''' || pStatus || ''' as status,
count(*) as registros,
count(distinct ' || pCampo || ') as unicos,
count(case when ' || pCampo || ' is null then 1 else null end) as nulos,
count(case when to_char(' || pCampo || ') = ''0'' then 1 else null end) as zeros,
count(case when ' || pCampo || ' is not null
            and length(trim(translate(' || pCampo || ', ''0123456789 -,.'', '' ''))) = 0
           then 1
           else null
      end) as numericos,
count(case when ''' || pTipo || ''' = ''Date''
            and ' || pCampo || ' is not null
            and length(PKGMIGVALIDACAO.validarData(' || pCampo || ')) > 1
            then 1
            else null
      end) as datas,
count(case when length(PKGMIGVALIDACAO.validar(
  pConteudo => ' || pCampo || ',
  pCampo => ''' || pCampo || ''',
  pObrigatorio => ''' || pObrigatorio || ''',
  pTamanho => ''' || pTamanho || ''',
  pRegravalidacao => ''' || pRegraValidacao || ''',
  pDominio => ''' || pDominio || ''',
  pTipo => ''' || pTipo || '''
)) > 1 then 1 else null end) as invalidos,
min(case when ' || pCampo || ' is not null
          and length(trim(translate(' || pCampo || ', ''0123456789 -,.'', '' ''))) = 0
          and length(trim(translate(' || pCampo || ', '' "-,.'', '' ''))) < 20
         then to_number(trim(translate(' || pCampo || ', '' "-,.'', '' '')))
         else null
    end) as minimos,
max(case when ' || pCampo || ' is not null
          and length(trim(translate(' || pCampo || ', ''0123456789 -,.'', '' ''))) = 0
          and length(trim(translate(' || pCampo || ', '' "-,.'', '' ''))) < 20
         then to_number(trim(translate(' || pCampo || ', '' "-,.'', '' '')))
         else null
    end) as maximos
from ' || pNomeTabela || '
)

select campo, ordem, status, registros, unicos, nulos, zeros, numericos, datas, invalidos,
round(((nvl(registros,0) - nvl(invalidos,0)) / nullif( nvl(registros,0),0)) * 100, 2) as validos,
minimos, maximos,
case unicos when 0 then null when 1 then dominio else null end as padrao,
case when unicos > 1 then dominio else null end as dominio
from estatistica
left join lista on campolista = campo
';

end gerarSQLEstatisticasArquivo;

function listarEstatisticaDescritiva(
  pdocJSON in clob,
  pNomeTabela in varchar2,
  pProprietario in varchar2 default null
) return estatisticaDescritivaTabela pipelined as
vSQL varchar2(4000);
vNomeTabela varchar2(50);

type camposTabelaRecord is record (
  campo varchar2(50),
  obrigatorio varchar2(3),
  tamanho varchar2(5),
  regravalidacao varchar2(250),
  dominio varchar2(250),
  tipo varchar2(10),
  ordem number(3),
  status varchar2(50)
);
camposTabela camposTabelaRecord;
 
cursor cCamposTabela (pdocJSON clob, vNomeTabela varchar2, vProprietario varchar2) is
with
layout as (select campo, obrigatorio, tamanho, trim(translate(regrasvalidacao, '[]"', ' ')) as regravalidacao, dominio, tipo, rownum as ordem
           from table(PKGMIGLAYOUT.listar(pdocJSON)))),
tab as (select column_name as campo, 'Não' as obrigatorio, data_length as tamanho, null as regravalidacao, null as dominio, data_type as tipo, column_id as ordem
        from sys.all_tab_columns where owner = upper(vProprietario) and table_name = upper(vNomeTabela))
select
nvl(layout.campo,tab.campo) as campo,
nvl(layout.obrigatorio,tab.obrigatorio) as obrigatorio,
nvl(layout.tamanho,tab.tamanho) as tamanho,
nvl(layout.regravalidacao,tab.regravalidacao) as regravalidacao,
nvl(layout.dominio,tab.dominio) as dominio,
nvl(layout.tipo,tab.tipo) as tipo,
nvl(layout.ordem,tab.ordem) as ordem,
case
 when tab.campo is null then 'Ausente'
 when layout.campo is null then 'Ignorado'
 else 'Presente'
end as status
from tab
full join layout on layout.campo = tab.campo 
--where nvl(tab.ordem,layout.ordem) between 81 and 100
order by ordem
;

type estatisticaDescritivaLinha is record(
  campo     varchar2(50),
  ordem     number(3),
  status    varchar2(50),
  registros number(8),
  unicos    number(8),
  nulos     number(8),
  zeros     number(8),
  numericos number(8),
  datas     number(8),
  invalidos number(8),
  validos   number(5,2),
  minimos   number(20),
  maximos   number(20),
  padrao    varchar2(50),
  dominio   varchar2(1500)
);
estatisticasArquivo estatisticaDescritivaLinha;

begin
  if pProprietario is null then vNomeTabela := upper(pNomeTabela);
  else vNomeTabela := upper(pProprietario) || '.' || upper(pNomeTabela);
  end if;
  
  open cCamposTabela(pdocJSON, upper(pNomeTabela), upper(pProprietario));
  loop fetch cCamposTabela into camposTabela;
    exit when cCamposTabela%notfound;

      vSQL := gerarSQLEstatisticasArquivo(
        vNomeTabela,
        camposTabela.campo,
        camposTabela.obrigatorio,
        camposTabela.tamanho,
        camposTabela.regravalidacao,
        camposTabela.dominio,
        camposTabela.tipo,
        camposTabela.ordem,
        camposTabela.status
      );
      execute immediate vSQL into estatisticasArquivo;

      pipe row(estatisticaDescritivaTabelaLinha(
        camposTabela.campo,
        camposTabela.ordem,
        camposTabela.status,
        estatisticasArquivo.registros,
        estatisticasArquivo.unicos,
        estatisticasArquivo.nulos,
        estatisticasArquivo.zeros,
        estatisticasArquivo.numericos,
        estatisticasArquivo.datas,
        estatisticasArquivo.invalidos,
        estatisticasArquivo.validos,
        estatisticasArquivo.minimos,
        estatisticasArquivo.maximos,
        estatisticasArquivo.padrao,
        estatisticasArquivo.dominio
      ));

  end loop; 
   
end listarEstatisticaDescritiva;

end PKGMIGLAYOUT;
/