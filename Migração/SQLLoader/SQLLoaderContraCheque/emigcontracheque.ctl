options (skip=1)
load data
characterset UTF8
into table emigcontrachequecsv_202310
insert
fields terminated by';'
trailing nullcols (
nuseq sequence(max,1),
sgorgao,
numatriculalegado,
nucpf,
nuanoreferencia,
numesreferencia,
nuanomesrefdiferenca,
nmtipofolha,
nmtipocalculo,
nusequencialfolha,
nmtiporubrica,
nurubrica,
nmrubrica,
nusufixorubrica,
vlpagamento,
vlindicerubrica,
detipoindice,
qtparcelas,
nuparcela,
nucpfbenfpensaoalimento,
nuprocessoretroativo,
qtmeses,
dtadmissao
)