begin
  for i in (
with
comissionadovalores as (
select cargonome as nunivel, nivel as nucodigo, valor as vlfixo, 6 as cdrelacaotrabalho
from ComissionadosNivelRefValores
)

select
 vlcco.cdvalorrefccoagruporgespec,
 vlcco.nucodigo,
 vlcco.nunivel,
 vlcco.cdrelacaotrabalho,
 valor.vlfixo
from epagvalorrefccoagruporgespec vlcco
inner join epaghistvalorrefccoagruporgver hvvlcco on hvvlcco.cdhistvalorrefccoagruporgver = vlcco.cdhistvalorrefccoagruporgver
                                                 and hvvlcco.nuanoiniciovigencia = '1901'
                                                 and hvvlcco.numesiniciovigencia = '01'
inner join epagvalorrefccoagruporgversao vvlcco on vvlcco.cdvalorrefccoagruporgversao = hvvlcco.cdvalorrefccoagruporgversao
                                               and vvlcco.nuversao = 1
left join comissionadovalores valor on valor.nunivel = vlcco.nunivel
                                   and valor.nucodigo = vlcco.nucodigo
                                   and valor.cdrelacaotrabalho = vlcco.cdrelacaotrabalho
where valor.nunivel is not null
order by
 vvlcco.cdagrupamento,
 vlcco.nunivel,
 vlcco.nucodigo
  ) loop

    update epagvalorrefccoagruporgespec set vlfixo = i.vlfixo
    where cdvalorrefccoagruporgespec = i.cdvalorrefccoagruporgespec;
    
  end loop;
end;
/