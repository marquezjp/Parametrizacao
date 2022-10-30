options (skip=1)
load data into table sigrh_rr_vinculos
insert
fields terminated by';'
trailing nullcols (
sgorgao,
nucpf,
nmpessoa,
matricula_legado,
dtadmissao date "DD/MM/YYYY",
dtdesligamento date "DD/MM/YYYY",
nmrelacaotrabalho,
nmregimetrabalho,
nmnaturezavinculo,
nmregimeprevidenciario,
nmsituacaoprevidenciaria,
nmtiporegimeproprioprev,
decarreira,
degrupoocupacional,
decargo,
declasse,
decompetencia,
deespecialidade,
nmtipocargahoraria,
nucargahoraria,
nubancocredito,
nuagenciacredito
)

