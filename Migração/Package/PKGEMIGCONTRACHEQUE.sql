set serveroutput on
/

select PKGMIGCONTRACHEQUE.especificacaoLayout() from dual;
/

select json_query(PKGMIGCONTRACHEQUE.especificacaoLayout(), '$.Arquivos[0].Grupos[0]' pretty ) from dual;
/

select json_serialize(PKGMIGCONTRACHEQUE.especificacaoLayout() returning clob pretty ) from dual;
/

--- Exemplo Listar o Arquivo de Migração
declare
vRefCursor sys_refcursor;

type arquivoMigracaoLinha is record(
nmarquivo varchar2(50),
nuregsitro number(8),
jschaveunica varchar(500),
jscampos clob
);
item arquivoMigracaoLinha;

procedure print (p in varchar2) is
begin dbms_output.put_line(p); end;

begin
  vRefCursor := PKGMIGCONTRACHEQUE.obterArquivoMigracao('emigcapapagamento2');

  loop fetch vRefCursor into item;
    exit when vRefCursor%NOTFOUND;
    print(item.nmarquivo || ' ' ||
          item.nuregsitro || ' ' ||
          item.jschaveunica || ' ' ||
          item.jscampos
    );
  end loop;

end;
/

-- Remover o Pacote
drop package PKGMIGCONTRACHEQUE;
/

-- Criar o Especificação do Pacote
create or replace package PKGMIGCONTRACHEQUE is

function obterArquivoMigracao(pNomeTabela varchar2, pProprietario varchar2 default null) return sys_refcursor;
function especificacaoLayout return clob;

end PKGMIGCONTRACHEQUE;
/

-- Criar o Corpo do Pacote
create or replace package body PKGMIGCONTRACHEQUE is

function obterArquivoMigracao(pNomeTabela varchar2, pProprietario varchar2 default null) return sys_refcursor is
  vNomeCompletoTabela varchar2(50);
  vListaCampos varchar2(5000);
  vSQL varchar2(5000);
  vRefCursor sys_refcursor;
begin
  if pProprietario is null then
    vNomeCompletoTabela := upper('sigrhmig') || '.' ||upper(pNomeTabela);
  else
    vNomeCompletoTabela := upper(pProprietario) || '.' || upper(pNomeTabela);
  end if;

 vSQL := '
select listagg(nvl(tab.campo,''null'') || '' as '' || layout.campo, '', '')
       within group (order by layout.ordem) as campos
from (select campo, rownum as ordem
      from table(PKGMIGLAYOUT.listar(PKGMIGCONTRACHEQUE.especificacaoLayout()))
     ) layout
left join (select column_name as campo from sys.all_tab_columns
           where owner = upper(:pProprietario)
             and table_name = upper(:pNomeTabela)
          ) tab on tab.campo = layout.campo 
';

  execute immediate vSQL into vListaCampos using pProprietario, pNomeTabela;

  vSQL := '
select ''' || upper(pNomeTabela) || ''' as nmarquivo, rownum as nuregistro,
json_object(SGORGAO, NUMATRICULALEGADO,
            NUANOREFERENCIA, NUMESREFERENCIA,
            NMTIPOFOLHA, NMTIPOCALCULO, NUSEQUENCIALFOLHA,
            NMTIPORUBRICA, NURUBRICA) as jschaveunica,
json_object(*) as jscampos
from (select ' || vListaCampos || ' from ' || vNomeCompletoTabela || ') mig
';

    open vRefCursor for vSQL;
    return vRefCursor;
end obterArquivoMigracao;

function especificacaoLayout return clob is
begin
  return '
{
"FamiliaArquivos" : "Informações de Pagamento",
"Arquivos" : {
"Arquivo" : "Contracheque",
"SiglaArquivo" : "CONTRACHEQUE",
"Versão" : "2.1",
"Tabela" : "EMIGCONTRACHEQUE",
"Grupos" : [
{
"Grupo" : "Identificação do Vínculo",
"Campos" : [
{
"Campo" : "SGORGAO",
"Descrição" : "Sigla do órgão da folha de pagamento",
"Tipo" : "VARCHAR2",
"Tamanho" : "20",
"Obrigatório" : "Sim",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADORGAO", "Coluna" : "SGORGAO"}],
"RegrasValidação" : ["validarDominio"]
},
{
"Campo" : "NUMATRICULALEGADO",
"Descrição" : "Matrícula no sistema legado",
"Tipo" : "VARCHAR2",
"Tamanho" : "10",
"Obrigatório" : "Sim",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADVINCULO", "Coluna" : "NUMATRICULA"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "NUCPF",
"Descrição" : "CPF da pessoa",
"Tipo" : "Char",
"Tamanho" : "11",
"Obrigatório" : "Sim",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "ECADPESSOA", "Coluna" : "NUCPF"}],
"RegrasValidação" : ["validarCPF"]
}
]
},
{
"Grupo" : "Identificação da Folha",
"Campos" : [
{
"Campo" : "NUANOREFERENCIA",
"Descrição" : "Ano de referência da folha de pagamento.",
"Tipo" : "NUMBER",
"Tamanho" : "4",
"Obrigatório" : "Sim",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "EPAGFOLHAPAGAMENTO", "Coluna" : "NUANOREFERENCIA"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "NUMESREFERENCIA",
"Descrição" : "Mês de referência da folha de pagamento.",
"Tipo" : "NUMBER",
"Tamanho" : "2",
"Obrigatório" : "Sim",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "EPAGFOLHAPAGAMENTO", "Coluna" : "NUMESREFERENCIA"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "NMTIPOFOLHA",
"Descrição" : "Nome do tipo de folha de pagamento",
"Tipo" : "VARCHAR2",
"Tamanho" : "40",
"Obrigatório" : "Sim",
"Padrão" : "",
"Domínio" : ["NORMAL", "RESCISÃO", "13º SALÁRIO", "FÉRIAS", "ADIANTAMENTO DE 13º SALÁRIO", "INSTITUIDORES DE PENSÃO", "APOSENTADORIA", "13º SALÁRIO DE APOSENTADORIA", "ADIANTAMENTO DE 13º DE APOSENTADORIA", "OUTROS TIPOS DE FOLHA", "BOLSISTA", "RESIDENTE", "RESIDENTE - 13º SALÁRIO", "PESQUISADOR", "COMISSIONADO PURO", "FÚNEBRE", "FÚNEBRE - 13º SALÁRIO"],
"SIGRH" : [{"Conceito" : "EPAGTIPOFOLHA", "Coluna" : "NMTIPOFOLHA"}],
"RegrasValidação" : ["validarDominio"]
},
{
"Campo" : "NMTIPOCALCULO",
"Descrição" : "Nome do tipo de cálculo",
"Tipo" : "VARCHAR2",
"Tamanho" : "40",
"Obrigatório" : "Sim",
"Padrão" : "",
"Domínio" : ["NORMAL", "SIMULAÇÃO", "RECÁLCULO DO MÊS", "CÁLCULO RETROATIVO", "SUPLEMENTAR", "RECÁLCULO COMPLEMENTAR"],
"SIGRH" : [{"Conceito" : "EPAGTIPOCALCULO", "Coluna" : "NMTIPOCALCULO"}],
"RegrasValidação" : ["validarDominio"]
},
{
"Campo" : "NUSEQUENCIALFOLHA",
"Descrição" : " Número de sequencial da folha",
"Tipo" : "NUMBER",
"Tamanho" : "6",
"Obrigatório" : "Sim",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "EPAGFOLHAPAGAMENTO", "Coluna" : "NUSEQUENCIALFOLHA"}],
"RegrasValidação" : ["validarNumero"]
}
]
},
{
"Grupo" : "Informações da Rubrica do Contracheque",
"Campos" : [
{
"Campo" : "NMTIPORUBRICA",
"Descrição" : "Descrição do tipo de rubrica",
"Tipo" : "VARCHAR2",
"Tamanho" : "90",
"Obrigatório" : "Sim",
"Padrão" : "",
"Domínio" : ["PROVENTO NORMAL", "DIFERENCAS DE PROVENTO", "PROVENTOS EXTRA FOLHA", "DEVOLUCOES DE DESCONTO", "DESCONTO", "DIFERENCAS DE DESCONTO", "DESCONTOS EXTRA FOLHA", "DEVOLUCOES DE PROVENTO", "TOTALIZADORES", "PROVENTOS DE EXERCICIOS FINDOS", "DESCONTOS DE EXERCICIOS FINDOS"],
"SIGRH" : [{"Conceito" : "EPAGTIPORUBRICA", "Coluna" : "NMTIPORUBRICA"}],
"RegrasValidação" : ["validarDominio"]
},
{
"Campo" : "NURUBRICA",
"Descrição" : "Número da rubrica",
"Tipo" : "NUMBER",
"Tamanho" : "4",
"Obrigatório" : "Sim",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "EPAGRUBRICA", "Coluna" : "NURUBRICA"}],
"RegrasValidação" : ["validarRubrica"]
},
{
"Campo" : "NMRUBRICA",
"Descrição" : "Descrição da rubrica",
"Tipo" : "VARCHAR2",
"Tamanho" : "",
"Obrigatório" : "Sim",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "EPAGRUBRICA", "Coluna" : "NMRUBRICA"}],
"RegrasValidação" : ["validarRubrica"]
},
{
"Campo" : "NUSUFIXORUBRICA",
"Descrição" : "Sufixo da rubrica",
"Tipo" : "NUMBER",
"Tamanho" : "2",
"Obrigatório" : "Sim",
"Padrão" : "1",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "EPAGHISTORICORUBRICAVINCULO", "Coluna" : "NUSUFIXORUBRICA"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "VLPAGAMENTO",
"Descrição" : "Valor de pagamento da rubrica",
"Tipo" : "NUMBER",
"Tamanho" : "13,2",
"Obrigatório" : "Sim",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "EPAGHISTORICORUBRICAVINCULO", "Coluna" : "VLPAGAMENTO"}],
"RegrasValidação" : ["validarValorMonetario"]
},
{
"Campo" : "VLINDICERUBRICA",
"Descrição" : "Valor do índice da rubrica",
"Tipo" : "NUMBER",
"Tamanho" : "15,4",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "EPAGHISTORICORUBRICAVINCULO", "Coluna" : "VLINDICERUBRICA"}],
"RegrasValidação" : ["validarIndice"]
},
{
"Campo" : "DETIPOINDICE",
"Descrição" : "Descrição do tipo de índice",
"Tipo" : "NUMBER",
"Tamanho" : "2",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : ["VALOR", "PERCENTUAL", "QUANTIDADE HORAS/MINUTOS", "QUANTIDADE DE DIAS", "QUANT.QUOTAS (SOLDO) 1 COTA = 1/30 SOLDO", "GRUPO/NÍVEL/REFERÊNCIA", "PERCENTUAL SOBRE VALORES REFERÊNCIA", "PERC.TABELA FINANCEIRA", "OUTROS", "MESES", "ANOS"],
"SIGRH" : [{"Conceito" : "EPAGTIPOINDICE", "Coluna" : "DETIPOINDICE "}],
"RegrasValidação" : null
},
{
"Campo" : "QTPARCELAS",
"Descrição" : "Quantidade de parcelas",
"Tipo" : "NUMBER",
"Tamanho" : "3",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "EPAGHISTORICORUBRICAVINCULO", "Coluna" : "QTPARCELAS"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "NUPARCELA",
"Descrição" : "Número da parcela paga",
"Tipo" : "NUMBER",
"Tamanho" : "3",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "EPAGHISTORICORUBRICAVINCULO", "Coluna" : "NUPARCELA"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "NUANOMESREFDIREFENCA",
"Descrição" : "Ano e Mês de referência do Lançamento Financeiro se for diferença de meses anteriores",
"Tipo" : "NUMBER",
"Tamanho" : "6",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : ["AAAAMM"],
"SIGRH" : null,
"RegrasValidação" : ["validarNumero"]
}
]
},
{
"Grupo" : "Informação da Pensão Alimento",
"Campos" : [
{
"Campo" : "NUCPFBENFPENSAOALIMENTO",
"Descrição" : "CPF do beneficiário da pensão de alimentos",
"Tipo" : "CHAR",
"Tamanho" : "11",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : null,
"RegrasValidação" : ["validarCPF"]
}
]
},
{
"Grupo" : "Informação do Processo Retroativos",
"Campos" : [
{
"Campo" : "NUPROCESSORETROATIVO",
"Descrição" : "Número do processo de retroativos",
"Tipo" : "VARCHAR2",
"Tamanho" : "20",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "EPAGHISTORICORUBRICAVINCULO", "Coluna" : "DEPROCESSORETROATIVO"}],
"RegrasValidação" : ["validarNumero"]
},
{
"Campo" : "QTMESES",
"Descrição" : "Quantidade de meses do processo de retroativo",
"Tipo" : "NUMBER",
"Tamanho" : "3",
"Obrigatório" : "Não",
"Padrão" : "",
"Domínio" : null,
"SIGRH" : [{"Conceito" : "EPAGHISTORICORUBRICAVINCULO", "Coluna" : "VLINDICERUBRICARRA"}],
"RegrasValidação" : ["validarNumero"]
}
]
}

]
}
}
';
end especificacaoLayout;

end PKGMIGCONTRACHEQUE;
/