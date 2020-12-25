select bltexto from esegtextoformatadogeral
where cdtextoformatadogeral = 1;

update esegtextoformatadogeral
set bltexto =

'
<SPAN style="FONT-SIZE: 10px; FONT-FAMILY: Verdana, Arial; COLOR: rgb(0,0,0); BACKGROUND-COLOR: rgb(255,255,238)">
<DIV><B><FONT color=#000099 size=3>Contatos da Gestão de Pessoas</FONT></B></DIV>
<DIV><BR></DIV>
<DIV><B>Sergio Malta Barros</B></DIV>
<DIV>SEMGE - Diretor de Gestão da Folha de Pagamento</DIV>
<DIV><FONT color=#3366ff>sergio.malta@semarhp.maceio.al.gov.br</FONT></DIV>
<DIV><BR></DIV>
<DIV><B>Gloria Batista</B></DIV>
<DIV>Grupo Gestor para Modernizaçao da Gestão do Município de Maceió</DIV>
<DIV><FONT color=#3366ff>modernizacao@semge.maceio.al.gov.br</FONT></DIV>
<DIV><BR></DIV>
<DIV><B>Joao Geraldo Oliveira</B></DIV>
<DIV>SEMGE/DTI - Diretor de Tecnologia da Informação<SPAN style="WHITE-SPACE: pre"> </SPAN></DIV>
<DIV><FONT color=#3366ff>geraldo.oliveira@dti.maceio.al.gov.br</FONT></DIV>
'

where cdtextoformatadogeral = 1;