-- Remover o Pacote
drop package PKGMIGVALIDACAO;
/

-- Criar o Especificação do Pacote
create or replace
package PKGMIGVALIDACAO is

function validarNumero(pConteudo in varchar2) return boolean;
function validarData(pConteudo in varchar2, pFormato in varchar2 default 'DD/MM/YYYY') return boolean;
function validarTamanho(pConteudo in varchar2) return boolean;
function validarNome(pConteudo in varchar2) return boolean;
function validarFaixa(pConteudo in varchar2) return boolean;
function validarLista(pConteudo in varchar2) return boolean;
function validarIndice(pConteudo in varchar2) return boolean;

function validarAgencia(pConteudo in varchar2) return boolean;
function validarBanco(pConteudo in varchar2) return boolean;
function validarCEP(pConteudo in varchar2) return boolean;
function validarCNPJ(pConteudo in varchar2) return boolean;
function validarCPF(pConteudo in varchar2) return boolean;
function validarCargaHoraria(pConteudo in varchar2) return boolean;
function validarCargo(pConteudo in varchar2) return boolean;
function validarCargoComissionado(pConteudo in varchar2) return boolean;
function validarCarreira(pConteudo in varchar2) return boolean;
function validarCentroCusto(pConteudo in varchar2) return boolean;
function validarClasse(pConteudo in varchar2) return boolean;
function validarCompetencia(pConteudo in varchar2) return boolean;
function validarDataNascimento(pConteudo in varchar2) return boolean;
function validarEMail(pConteudo in varchar2) return boolean;
function validarEspecialidade(pConteudo in varchar2) return boolean;
function validarEstadoCivil(pConteudo in varchar2) return boolean;
function validarGrupoComissionado(pConteudo in varchar2) return boolean;
function validarGrupoMotivoAfastamento(pConteudo in varchar2) return boolean;
function validarGrupoOcupacional(pConteudo in varchar2) return boolean;
function validarMotivoAfastamento(pConteudo in varchar2) return boolean;
function validarNaturezaVinculo(pConteudo in varchar2) return boolean;
function validarOpcaoRemuneracao(pConteudo in varchar2) return boolean;
function validarPais(pConteudo in varchar2) return boolean;
function validarRaca(pConteudo in varchar2) return boolean;
function validarRegimePrevidenciario(pConteudo in varchar2) return boolean;
function validarRegimeProprioPrevidenciario(pConteudo in varchar2) return boolean;
function validarRegimeTrabalho(pConteudo in varchar2) return boolean;
function validarRelacaoTrabalho(pConteudo in varchar2) return boolean;
function validarSiglaOrgao(pConteudo in varchar2) return boolean;
function validarSiglaUO(pConteudo in varchar2) return boolean;
function validarSituacaoPrevidenciaria(pConteudo in varchar2) return boolean;
function validarTipoAfastamento(pConteudo in varchar2) return boolean;
function validarTipoCalculo(pConteudo in varchar2) return boolean;
function validarTipoContaCredito(pConteudo in varchar2) return boolean;
function validarTipoFolha(pConteudo in varchar2) return boolean;
function validarTipoOcupacao(pConteudo in varchar2) return boolean;
function validarTipoProvimento(pConteudo in varchar2) return boolean;
function validarValorMonetario(pConteudo in varchar2) return boolean;

end PKGMIGVALIDACAO;
/

-- Criar o Corpo do Pacote
create or replace
package body PKGMIGVALIDACAO is

function validarNumero(pConteudo in varchar2) return boolean is
begin
    if pConteudo is null then return FALSE ;
    end if;
    
    if trim(TRANSLATE(pConteudo, '0123456789 -,.', ' ')) is null
      then return TRUE ;
    else
      return FALSE ;
    end if;
end validarNumero;

function validarData (
  pConteudo in varchar2,
  pFormato in varchar2 default 'DD/MM/YYYY'
) return boolean is
lData date;
begin
    if pConteudo is null then return FALSE ;
    end if;
   
    lData := to_date(pConteudo, pFormato);
    return TRUE ;

exception
    when others then return FALSE ;

end validarData;

function validarTamanho(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarTamanho;

function validarNome(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarNome;

function validarFaixa(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarFaixa;

function validarLista(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarLista;

function validarIndice(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarIndice;

function validarAgencia(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarAgencia;

function validarBanco(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarBanco;

function validarCEP(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarCEP;

function validarCNPJ(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarCNPJ;

function validarCPF(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarCPF;

function validarCargaHoraria(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarCargaHoraria;

function validarCargo(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarCargo;

function validarCargoComissionado(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarCargoComissionado;

function validarCarreira(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarCarreira;

function validarCentroCusto(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarCentroCusto;

function validarClasse(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarClasse;

function validarCompetencia(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarCompetencia;

function validarDataNascimento(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarDataNascimento;

function validarEMail(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarEMail;

function validarEspecialidade(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarEspecialidade;

function validarEstadoCivil(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarEstadoCivil;

function validarGrupoComissionado(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarGrupoComissionado;

function validarGrupoMotivoAfastamento(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarGrupoMotivoAfastamento;

function validarGrupoOcupacional(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarGrupoOcupacional;

function validarMotivoAfastamento(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarMotivoAfastamento;

function validarNaturezaVinculo(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarNaturezaVinculo;

function validarOpcaoRemuneracao(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarOpcaoRemuneracao;

function validarPais(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarPais;

function validarRaca(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarRaca;

function validarRegimePrevidenciario(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarRegimePrevidenciario;

function validarRegimeProprioPrevidenciario(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarRegimeProprioPrevidenciario;

function validarRegimeTrabalho(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarRegimeTrabalho;

function validarRelacaoTrabalho(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarRelacaoTrabalho;

function validarSiglaOrgao(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarSiglaOrgao;

function validarSiglaUO(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarSiglaUO;

function validarSituacaoPrevidenciaria(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarSituacaoPrevidenciaria;

function validarTipoAfastamento(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarTipoAfastamento;

function validarTipoCalculo(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarTipoCalculo;

function validarTipoContaCredito(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarTipoContaCredito;

function validarTipoFolha(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarTipoFolha;

function validarTipoOcupacao(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarTipoOcupacao;

function validarTipoProvimento(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarTipoProvimento;

function validarValorMonetario(pConteudo in varchar2) return boolean is
begin
	return TRUE;
end validarValorMonetario;

end PKGMIGVALIDACAO;
/