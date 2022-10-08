set serveroutput on

declare
vSQL varchar2(32000);

type recCamposTabela is record (campo varchar2(50),
                               ordem number(6));
camposTabela recCamposTabela;
 
cursor cCamposTabela (vProprietario varchar2, vNomeTabela varchar2) is
   select lower(column_name) as campo, column_id as ordem from sys.all_tab_columns
   where owner = vProprietario
     and table_name = vNomeTabela
--     and column_id between 1 and 20
--     and column_id = 2
   order by column_id;
   
type tpEstatisticasArquivo is ref cursor;
cEstatisticasArquivo tpEstatisticasArquivo;

type recEstatisticasArq is record (campo     varchar2(50),
                                   ordem     number(6),
                                   registros number(6),
                                   unicos    number(6),
                                   nulos     number(6),
                                   zeros     number(6),
                                   numericos number(6),
                                   datas     number(6),
                                   minimos   long,
                                   maximos   long,
                                   padrao    varchar2(50),
                                   dominio   varchar2(1500)
                                  );
estatisticasArquivo recEstatisticasArq;

procedure print (p in varchar2) is
begin
  dbms_output.put_line(p);
end;

function centralizarString(pTexto varchar2, pTamanho number) return varchar2 is  
begin  
 return lpad(rpad(pTexto,length(pTexto) + (pTamanho - length(pTexto) - 1) / 2,' '),pTamanho,' ');
end centralizarString;

function validarData (
  pData in varchar2,
  pFormato in varchar2 default 'DD/MM/YYYY'
) return boolean is
lData date;
begin
    if pData is null then return FALSE ;
    end if;
   
    lData := to_date(pData, pFormato);
    return TRUE ;

exception
    when others then return FALSE ;

end validarData;

function validarNumero(pNumero in varchar2) return boolean is
begin
    if pNumero is null then return FALSE ;
    end if;
    
    if trim(TRANSLATE(pNumero, '0123456789 -,.', ' ')) is null
      then return TRUE ;
    else
      return FALSE ;
    end if;
end validarNumero;

function gerarSQL (
  pCampo in varchar2,
  pOrdem in number,
  pNomeTabela in varchar2,
  pProprietario in varchar2 default null
) return varchar2 is
begin
  return '

with  
unicos as (select distinct ' || pCampo || ' from SIGRHMIG.EMIGCAPAPAGAMENTO2),
lista as (
select ''' || pCampo || ''' as campolista, listagg(' || pCampo || ', ''; '') within group (order by ' || pCampo || ') as dominio
from unicos
where (select count(*) from unicos) < 50  
),
estatistica as (
select ''' || pCampo || ''' as campo, ' || pOrdem || ' as ordem,
count(*) as registros,
count(distinct ' || pCampo || ') as unicos,
count(case when ' || pCampo || ' is null then 1 else null end) as nulos,
count(case when to_char(' || pCampo || ') = ''0'' then 1 else null end) as zeros,
count(case when ' || pCampo || ' is not null and trim(TRANSLATE(' || pCampo || ', ''0123456789 -,.'', '' '')) is null then 1 else null end) as numericos,
--count(case when validarData(' || pCampo || ') then 1 else null end) as datas,
--min(case when validarNumero(' || pCampo || ') then trim(TRANSLATE(' || pCampo || ', '' -,.'', '' '')) else null end) as minimos,
--max(case when validarNumero(' || pCampo || ') then trim(TRANSLATE(' || pCampo || ', '' -,.'', '' '')) else null end) as maximos
null as datas,
null as minimos,
null as maximos
from ' || pProprietario || '.' || pNomeTabela || '
)

select campo, ordem, registros, unicos, nulos, zeros, numericos, datas, minimos, maximos,
case when unicos = 1 then dominio else null end as padrao,
case when unicos > 1 then dominio else null end as dominio
from estatistica
left join lista on campolista = campo
';
end gerarSQL;

begin

  print(rpad('campo',30)     || ' | ' ||
        lpad('ordem',06)     || ' | ' ||
        lpad('registros',06) || ' | ' ||
        lpad('unicos',06)    || ' | ' ||
        lpad('nulos',06)     || ' | ' ||
        lpad('zeros',06)     || ' | ' ||
        lpad('numericos',06) || ' | ' ||
        lpad('datas',06)     || ' | ' ||
        lpad('minimos',11)   || ' | ' ||
        lpad('maximos',11)   || ' | ' ||
        rpad('padrao',50)    || ' | ' ||
        rpad('dominio',100)
        );

  print(rpad('-',30,'-')     || ' + ' ||
        lpad('-',06,'-')     || ' + ' ||
        lpad('-',06,'-')     || ' + ' ||
        lpad('-',06,'-')     || ' + ' ||
        lpad('-',06,'-')     || ' + ' ||
        lpad('-',06,'-')     || ' + ' ||
        lpad('-',06,'-')     || ' + ' ||
        lpad('-',06,'-')     || ' + ' ||
        lpad('-',11,'-')     || ' + ' ||
        lpad('-',11,'-')     || ' + ' ||
        rpad('-',50,'-')     || ' + ' ||
        rpad('-',100,'-')
        );
        
  open cCamposTabela(upper('sigrhmig'), upper('emigcapapagamento2'));
  loop fetch cCamposTabela into camposTabela;
    exit when cCamposTabela%notfound;
    
     vSQL := gerarSQL(camposTabela.campo, camposTabela.ordem, upper('emigcapapagamento2'), upper('sigrhmig'));
     
--     print(camposTabela.campo || ' | ' || camposTabela.ordem || ' | ' || vSQL);
--     print(vSQL);
 
     execute immediate vSQL into estatisticasArquivo;
  
     print(rpad(estatisticasArquivo.campo,30) || ' | ' ||
           centralizarString(estatisticasArquivo.ordem,06) || ' | ' ||
           centralizarString(estatisticasArquivo.registros,06) || ' | ' ||
           centralizarString(estatisticasArquivo.unicos,06) || ' | ' ||
           centralizarString(estatisticasArquivo.nulos,06) || ' | ' ||
           centralizarString(estatisticasArquivo.zeros,06) || ' | ' ||
           centralizarString(estatisticasArquivo.numericos,06) || ' | ' ||
           centralizarString(estatisticasArquivo.datas,06) || ' | ' ||
           lpad(nvl(estatisticasArquivo.minimos, ' '),11) || ' | ' ||
           lpad(nvl(estatisticasArquivo.maximos, ' '),11) || ' | ' ||
           rpad(nvl(estatisticasArquivo.padrao, ' '),50) || ' | ' ||
           rpad(nvl(estatisticasArquivo.dominio, ' '),100)
           );
  
    end loop;
  
  close cCamposTabela;

end;