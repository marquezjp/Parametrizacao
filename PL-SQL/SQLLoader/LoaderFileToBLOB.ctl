load data infile *
append into table livros
fields terminated by ';' (
idlivros sequence(max,1),
nome char,
nomearquivo filler char,
sinopse lobfile (nomearquivo) terminated by EOF
)
BEGINDATA
DELPHI 7  A BÍBLIA;sinopse1.dat
APRENDA SQL 3 EM 24 Horas;sinopse2.dat
PL*SQL EM 24 HORAS;sinopse3.dat
SQL MAGAZINE;sinopse4.dat