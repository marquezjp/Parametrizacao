-- Remover o Pacote
drop package PKGMIGVALIDACAO;
/

-- Criar o Especificação do Pacote
create or replace
package PKGMIGVALIDACAO is

function validarNumero(pConteudo in varchar2) return number;
function validarData(pConteudo in varchar2, pFormato in varchar2 default 'DD/MM/YYYY') return number;
function validarTamanho(pConteudo in varchar2) return number;
function validarNome(pConteudo in varchar2) return number;
function validarFaixa(pConteudo in varchar2) return number;
function validarLista(pConteudo in varchar2) return number;
function validarIndice(pConteudo in varchar2) return number;

function validarAgencia(pConteudo in varchar2) return number;
function validarBanco(pConteudo in varchar2) return number;
function validarCEP(pConteudo in varchar2) return number;
function validarCNPJ(pConteudo in varchar2) return number;
function validarCPF(pConteudo in varchar2) return number;
function validarCargaHoraria(pConteudo in varchar2) return number;
function validarCargo(pConteudo in varchar2) return number;
function validarCargoComissionado(pConteudo in varchar2) return number;
function validarCarreira(pConteudo in varchar2) return number;
function validarCentroCusto(pConteudo in varchar2) return number;
function validarClasse(pConteudo in varchar2) return number;
function validarCompetencia(pConteudo in varchar2) return number;
function validarDataNascimento(pConteudo in varchar2) return number;
function validarEMail(pConteudo in varchar2) return number;
function validarEspecialidade(pConteudo in varchar2) return number;
function validarEstadoCivil(pConteudo in varchar2) return number;
function validarGrupoComissionado(pConteudo in varchar2) return number;
function validarGrupoMotivoAfastamento(pConteudo in varchar2) return number;
function validarGrupoOcupacional(pConteudo in varchar2) return number;
function validarMotivoAfastamento(pConteudo in varchar2) return number;
function validarNaturezaVinculo(pConteudo in varchar2) return number;
function validarOpcaoRemuneracao(pConteudo in varchar2) return number;
function validarPais(pConteudo in varchar2) return number;
function validarRaca(pConteudo in varchar2) return number;
function validarRegimePrevidenciario(pConteudo in varchar2) return number;
function validarRegimeProprioPrevidenciario(pConteudo in varchar2) return number;
function validarRegimeTrabalho(pConteudo in varchar2) return number;
function validarRelacaoTrabalho(pConteudo in varchar2) return number;
function validarSiglaOrgao(pConteudo in varchar2) return number;
function validarSiglaUO(pConteudo in varchar2) return number;
function validarSituacaoPrevidenciaria(pConteudo in varchar2) return number;
function validarTipoAfastamento(pConteudo in varchar2) return number;
function validarTipoCalculo(pConteudo in varchar2) return number;
function validarTipoContaCredito(pConteudo in varchar2) return number;
function validarTipoFolha(pConteudo in varchar2) return number;
function validarTipoOcupacao(pConteudo in varchar2) return number;
function validarTipoProvimento(pConteudo in varchar2) return number;
function validarValorMonetario(pConteudo in varchar2) return number;

end PKGMIGVALIDACAO;
/

-- Criar o Corpo do Pacote
create or replace
package body PKGMIGVALIDACAO is

function validarNumero(pConteudo in varchar2) return number is
begin
    if pConteudo is null then return 0 ;
    end if;
    
    if trim(TRANSLATE(pConteudo, '0123456789 -,.', ' ')) is null
      then return 1 ;
    else
      return 0 ;
    end if;
end validarNumero;

function validarData (
  pConteudo in varchar2,
  pFormato in varchar2 default 'DD/MM/YYYY'
) return number is
lData date;
begin
    if pConteudo is null then return 0 ;
    end if;
   
    lData := to_date(pConteudo, pFormato);
    return 1;

exception
    when others then return 0 ;

end validarData;

function validarTamanho(pConteudo in varchar2) return number is
begin
	return 1;
end validarTamanho;

function validarNome(pConteudo in varchar2) return number is
begin
	return 1;
end validarNome;

function validarFaixa(pConteudo in varchar2) return number is
begin
	return 1;
end validarFaixa;

function validarLista(pConteudo in varchar2) return number is
begin
	return 1;
end validarLista;

function validarIndice(pConteudo in varchar2) return number is
begin
	return 1;
end validarIndice;

function validarAgencia(pConteudo in varchar2) return number is
begin
	return 1;
end validarAgencia;

function validarBanco(pConteudo in varchar2) return number is
begin
	return 1;
end validarBanco;

function validarCEP(pConteudo in varchar2) return number is
begin
	return 1;
end validarCEP;

function validarCNPJ(pConteudo in varchar2) return number is
begin
	return 1;
end validarCNPJ;

function validarCPF(pConteudo in varchar2) return number is
begin
	return 1;
end validarCPF;

function validarCargaHoraria(pConteudo in varchar2) return number is
begin
	return 1;
end validarCargaHoraria;

function validarCargo(pConteudo in varchar2) return number is
begin
	return 1;
end validarCargo;

function validarCargoComissionado(pConteudo in varchar2) return number is
begin
	return 1;
end validarCargoComissionado;

function validarCarreira(pConteudo in varchar2) return number is
begin
	return 1;
end validarCarreira;

function validarCentroCusto(pConteudo in varchar2) return number is
begin
	return 1;
end validarCentroCusto;

function validarClasse(pConteudo in varchar2) return number is
begin
	return 1;
end validarClasse;

function validarCompetencia(pConteudo in varchar2) return number is
begin
	return 1;
end validarCompetencia;

function validarDataNascimento(pConteudo in varchar2) return number is
begin
	return 1;
end validarDataNascimento;

function validarEMail(pConteudo in varchar2) return number is
begin
	return 1;
end validarEMail;

function validarEspecialidade(pConteudo in varchar2) return number is
begin
	return 1;
end validarEspecialidade;

function validarEstadoCivil(pConteudo in varchar2) return number is
begin
	return 1;
end validarEstadoCivil;

function validarGrupoComissionado(pConteudo in varchar2) return number is
begin
	return 1;
end validarGrupoComissionado;

function validarGrupoMotivoAfastamento(pConteudo in varchar2) return number is
begin
	return 1;
end validarGrupoMotivoAfastamento;

function validarGrupoOcupacional(pConteudo in varchar2) return number is
begin
	return 1;
end validarGrupoOcupacional;

function validarMotivoAfastamento(pConteudo in varchar2) return number is
begin
	return 1;
end validarMotivoAfastamento;

function validarNaturezaVinculo(pConteudo in varchar2) return number is
begin
	return 1;
end validarNaturezaVinculo;

function validarOpcaoRemuneracao(pConteudo in varchar2) return number is
begin
	return 1;
end validarOpcaoRemuneracao;

function validarPais(pConteudo in varchar2) return number is
begin
	return 1;
end validarPais;

function validarRaca(pConteudo in varchar2) return number is
begin
	return 1;
end validarRaca;

function validarRegimePrevidenciario(pConteudo in varchar2) return number is
begin
	return 1;
end validarRegimePrevidenciario;

function validarRegimeProprioPrevidenciario(pConteudo in varchar2) return number is
begin
	return 1;
end validarRegimeProprioPrevidenciario;

function validarRegimeTrabalho(pConteudo in varchar2) return number is
begin
	return 1;
end validarRegimeTrabalho;

function validarRelacaoTrabalho(pConteudo in varchar2) return number is
begin
	return 1;
end validarRelacaoTrabalho;

function validarSiglaOrgao(pConteudo in varchar2) return number is
begin
	return 1;
end validarSiglaOrgao;

function validarSiglaUO(pConteudo in varchar2) return number is
begin
	return 1;
end validarSiglaUO;

function validarSituacaoPrevidenciaria(pConteudo in varchar2) return number is
begin
	return 1;
end validarSituacaoPrevidenciaria;

function validarTipoAfastamento(pConteudo in varchar2) return number is
begin
	return 1;
end validarTipoAfastamento;

function validarTipoCalculo(pConteudo in varchar2) return number is
begin
	return 1;
end validarTipoCalculo;

function validarTipoContaCredito(pConteudo in varchar2) return number is
begin
	return 1;
end validarTipoContaCredito;

function validarTipoFolha(pConteudo in varchar2) return number is
begin
	return 1;
end validarTipoFolha;

function validarTipoOcupacao(pConteudo in varchar2) return number is
begin
	return 1;
end validarTipoOcupacao;

function validarTipoProvimento(pConteudo in varchar2) return number is
begin
	return 1;
end validarTipoProvimento;

function validarValorMonetario(pConteudo in varchar2) return number is
begin
	return 1;
end validarValorMonetario;

end PKGMIGVALIDACAO;
/