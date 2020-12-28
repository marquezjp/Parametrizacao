update eafaafastamentovinculo
set dtinclusao = '21/12/2020'
where cdvinculo in (select v.cdvinculo from ecadvinculo v
                      where v.numatricula in (948904, 948918, 949253, 946664, 945517, 942368, 947807, 947967, 948007, 951921, 946499));