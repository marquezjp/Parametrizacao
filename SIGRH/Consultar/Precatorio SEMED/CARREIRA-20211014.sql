select cditemcarreira from ecaditemcarreira
where cdtipoitemcarreira = 1 and deitemcarreira like 'MAGISTERIO%';

--(456, 457, 181, 184, 186)

select cditemcarreira from ecaditemcarreira
where cdtipoitemcarreira = 1 and deitemcarreira like 'ADMINISTRACAO GERAL%';

--(56, 58, 59, 62, 64, 70)

select es.cdestruturacarreira || ', ' from ecadestruturacarreira es
left join ecaditemcarreira c on c.cditemcarreira = es.cditemcarreira
left join ecadestruturacarreira cp on cp.cdestruturacarreira = es.cdestruturacarreirapai
left join ecaditemcarreira cr on cr.cditemcarreira = cp.cditemcarreira
where cr.cditemcarreira in (456, 457, 181, 184, 186); --(select cditemcarreira from ecaditemcarreira
                                                      -- where cdtipoitemcarreira = 1 and deitemcarreira like 'MAGISTERIO%');

--(264, 265, 267, 269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286,
-- 287, 288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 298, 299, 300, 301, 302, 303, 304, 305, 306, 307,
-- 308, 309, 310, 311, 312, 313, 314, 315, 316, 317, 318, 319, 641, 643, 644, 645, 646, 647, 648, 649, 650,
-- 651, 750, 753, 755, 756, 789, 754)
                            
select es.cdestruturacarreira || ', ' from ecadestruturacarreira es
left join ecaditemcarreira c on c.cditemcarreira = es.cditemcarreira
left join ecadestruturacarreira cp on cp.cdestruturacarreira = es.cdestruturacarreirapai
left join ecaditemcarreira cr on cr.cditemcarreira = cp.cditemcarreira
where cr.cditemcarreira in (56, 58, 59, 62, 64, 70); --(select cditemcarreira from ecaditemcarreira
                                                     -- where cdtipoitemcarreira = 1 and deitemcarreira like 'ADMINISTRACAO GERAL%');

--(48, 63, 65, 70, 72, 73, 74, 75, 76, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95,
-- 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117,
-- 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139,
-- 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161,
-- 162, 163, 164, 165, 166, 701, 700, 883)
                            
select distinct capa.cdvinculo
from epagcapahistrubricavinculo capa
inner join epagfolhapagamento f on f.cdfolhapagamento = capa.cdfolhapagamento and f.flcalculodefinitivo = 'S'
left join ecadvinculo v on v.cdvinculo = capa.cdvinculo
left join ecadhistcargoefetivo cef on cef.cdvinculo = capa.cdvinculo and cef.flanulado = 'N'
where nvl(capa.vlproventos, 0) > 0 and capa.flativo = 'S'
  and f.cdorgao = 40 -- select cdorgao from vcadorgao where sgorgao = 'SEMED'
  and v.dtadmissao >= '01/01/1998' and v.dtadmissao <= '31/12/2006'
  and cef.cdestruturacarreira in (48, 63, 65, 70, 72, 73, 74, 75, 76, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95,
                                  96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117,
                                  118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139,
                                  140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161,
                                  162, 163, 164, 165, 166, 701, 700, 883)
--(
--select es.cdestruturacarreira from ecadestruturacarreira es
--left join ecaditemcarreira c on c.cditemcarreira = es.cditemcarreira
--left join ecadestruturacarreira cp on cp.cdestruturacarreira = es.cdestruturacarreirapai
--left join ecaditemcarreira cr on cr.cditemcarreira = cp.cditemcarreira
--where cr.cditemcarreira in (
--select cditemcarreira from ecaditemcarreira
--where cdtipoitemcarreira = 1 and deitemcarreira like 'MAGISTERIO%'))
order by capa.cdvinculo;
