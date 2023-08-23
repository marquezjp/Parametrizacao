/* EXPRESSÃO REGULAR PARA VALIDAÇÃO FORMATO DA DATA
# Dia pode ter 1 ou 2 digitos, se 2 digitos pode iniciar com 0, 1, 2 ou 3, se iniciar com 3 o segundo digito só pode ser 0 ou 1
# Mês pode ter 1 ou 2 digitos, se 2 digitos pode iniciar com 0 ou 1, se iniciar com 1 o segundo digito só pode ser 0, 1, ou 2
# Ano pode iniciar com 19 ou 20, se inciar com 20 o terceiro digito soó pode ser 0, 1 ou 2
*/

select 'valida' as data from dual
where regexp_like('25/12/1921', '^(0?[1-9]|[12]\d|3[01])/(0?[1-9]|1[0-2])/(19[0-9]{2}|20[0-2][0-9])$')
;
/

select 'valida' as data from dual
where regexp_like('1921-12-25', '^((19[0-9][0-9]|2[0-9][0-9][0-9])(\/|-|\.)(0[1-9]|[1-9]|1[0-2]{1,2})(\/|-|\.)(0[1-9]|1[0-9]|2[0-9]|3[0-1]{1,2}))|((0[1-9]|1[0-9]|2[0-9]|3[0-1]{1,2})(\/|-|\.)(0[1-9]|[1-9]|1[0-2]{1,2})(\/|-|\.)(19[0-9][0-9]|2[0-9][0-9][0-9]))$')
;
/



/* EXPRESSÃO REGULAR PARA VALIDAÇÃO DE DATA ENTRE OS ANOS DE 1900 E 2299 CONSIDERA ANO BISSEXTO
^(
# Meses com 31 Dias, MESES 1, 3, 5, 7, 8, 10 ou 12, Ano entre 1900 e 2299
# Dia pode ter 1 ou 2 digitos se 2 digitos pode iniciar com 0, 1, 2 ou 3, se iniciar com 3 o segundo digito só pode ser 0 ou 1
# Mês pode ter 1 ou 2 digitos, se 1 digitos pode ser 1, 3, 5, 7 ou 8 se 2 digitos 10 ou 12
# Ano pode iniciar com 19 ou 20, depois pode ser de 00 à 99
(
(0?[1-9]|[12]\d|3[01])  # Dia
[\.\-\/]
(0?[13578]|10|12)       # Mês
[\.\-\/]
(19\d\d|2[0-2]\d\d)     # Ano
)
|
# Meses com 31 Dias, MESES 1, 3, 5, 7, 8, 10 ou 12, Ano entre 1900 e 2299
# Meses com 30 Dias, MESES 4,6,9,11, Ano entre 1900 e 2299
# Dia pode ter 1 ou 2 digitos se 2 digitos pode iniciar com 0, 1, 2 ou 3, se iniciar com 3 o segundo digito só pode ser 0
# Mês pode ter 1 ou 2 digitos, se 1 digitos pode ser 4, 6 ou 9 se 2 digitos 11
(
(0?[1-9]|[12]\d|30)     # Dia
[\.\-\/]
(0?[469]|11)            # Mês
[\.\-\/]
(19\d\d|2[0-2]\d\d)     # Ano
)
|
# Tratar o mês de Fevereiro até 28 dia, Ano entre 1900 e 2299
# Dia pode ter 1 ou 2 digitos se 2 digitos pode iniciar com 0, 1, 2, se iniciar com 2 o segundo digito só pode ser 0 à 8
# Mês opde ter 1 ou 2 digitos, 2 ou 02
(
0?[1-9]|1\d|2[0-8])     # Dia
[\.\-\/]
0?2                     # Mês
[\.\-\/]
(19\d\d|2[0-2]\d\d)     # Ano
)
|
# Regra do Ano Bissexto, tratar o mês de Fevereiro com 29 dia, Ano entre 1900 e 2299
# Dezena do Ano iniciada com 0 termina com 4 ou 8
# Dezena do Ano iniciada com 2, 4, 6 ou 8 termina com 0, 4 ou 8
# Dezena do Ano iniciada com 1, 3, 5, 7 ou 9 termina com 2 ou 6
(
29                      # Dia
[\.\-\/]
0?2                     # Mês
[\.\-\/]
((19|2[0-2])?(0[48]|[2468][048]|[13579][26])) # Ano
)
)$
*/
select 'valida' as data from dual
where regexp_like('29/02/1968', '^(((0?[1-9]|[12]\d|3[01])[\.\-\/](0?[13578]|10|12)[\.\-\/](19\d\d|2[0-2]\d\d))|((0?[1-9]|[12]\d|30)[\.\-\/](0?[469]|11)[\.\-\/](19\d\d|2[0-2]\d\d))|((0?[1-9]|1\d|2[0-8])[\.\-\/]0?2[\.\-\/](19\d\d|2[0-2]\d\d))|(29[\.\-\/]0?2[\.\-\/]((19|2[0-2])?(0[48]|[2468][048]|[13579][26]))))$')
;
/

