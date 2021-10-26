begin
  for vrec in (select L.*
                 from vpagRubrica R
                inner join epagLancamentoFinanceiro L
                   on L.cdRubricaAgrupamento = R.cdRubricaAgrupamento
                where nuRubrica in (4, 7, 10, 13, 14)
                  and cdtiporubrica in (1, 2)
                  and (L.Dtfimdireito is null or L.Dtfimdireito > sysdate)
                  and L.Vllancamentofinanceiro is not null
                  and L.FLanulado = 'N') loop
  
    update Epaglancamentofinanceiro
       set dtFImDireito = '30/09/2021'
     where cdLancamentoFinanceiro = vrec.Cdlancamentofinanceiro;
  
    insert into Epaglancamentofinanceiro
      (cdlancamentofinanceiro,
       cdvinculo,
       nusufixorubrica,
       dtiniciodireito,
       dtfimdireito,
       flvalorproporcional,
       nuparcelas,
       flpagaafastdefinitivo,
       nucpfcadastrador,
       dtinclusao,
       dtultalteracao,
       fldecisaojudicial,
       flfolhasuplementar,
       vlindice,
       vllancamentofinanceiro,
       cdlancfinanceiroorigem,
       cdlancamentoimp,
       cdfolhapagsuplementar,
       cddocumento,
       cdtipopublicacao,
       dtpublicacao,
       nupaginicial,
       nupublicacao,
       cdmeiopublicacao,
       deoutromeio,
       dtanulado,
       flanulado,
       dtfimdireitoanterior,
       cdrubricaagrupamento,
       inperiodicidade,
       cdprocessorestituicaoerario,
       flobservalimretroativoerario,
       cdprocessopagretroativo,
       nuformulaespecifica,
       dtiniciodireitolancamento,
       flacertoauto13sal,
       flpropdemitidonomes,
       cdtipofolhapagamento,
       vlintegraliprev,
       dedocumentoimportacao,
       flpagaafasttempsemremun,
       cdtipocalculo,
       nusequencialfolha,
       cdcompensacaoretroerario,
       flautomatico,
       delancamentofinanceiro,
       cdrubricaagrupamentoorigem,
       vlparalelo)
    values
      (Spaglancamentofinanceiro.Nextval,
       vrec.cdvinculo,
       vrec.nusufixorubrica,
       to_date('01/10/2021'),
       NULL,
       vrec.flvalorproporcional,
       vrec.nuparcelas,
       vrec.flpagaafastdefinitivo,
       vrec.nucpfcadastrador,
       vrec.dtinclusao,
       vrec.dtultalteracao,
       vrec.fldecisaojudicial,
       vrec.flfolhasuplementar,
       vrec.vlindice,
       vrec.vlLancamentoFinanceiro + vrec.vlLancamentoFinanceiro * 0.03,
       vrec.cdlancfinanceiroorigem,
       vrec.cdlancamentoimp,
       vrec.cdfolhapagsuplementar,
       vrec.cddocumento,
       vrec.cdtipopublicacao,
       vrec.dtpublicacao,
       vrec.nupaginicial,
       vrec.nupublicacao,
       vrec.cdmeiopublicacao,
       vrec.deoutromeio,
       vrec.dtanulado,
       vrec.flanulado,
       vrec.dtfimdireitoanterior,
       vrec.cdrubricaagrupamento,
       vrec.inperiodicidade,
       vrec.cdprocessorestituicaoerario,
       vrec.flobservalimretroativoerario,
       vrec.cdprocessopagretroativo,
       vrec.nuformulaespecifica,
       vrec.dtiniciodireitolancamento,
       vrec.flacertoauto13sal,
       vrec.flpropdemitidonomes,
       vrec.cdtipofolhapagamento,
       vrec.vlintegraliprev,
       vrec.dedocumentoimportacao,
       vrec.flpagaafasttempsemremun,
       vrec.cdtipocalculo,
       vrec.nusequencialfolha,
       vrec.cdcompensacaoretroerario,
       vrec.flautomatico,
       vrec.delancamentofinanceiro,
       vrec.cdrubricaagrupamentoorigem,
       vrec.vlparalelo);
  
  end loop;

end;
