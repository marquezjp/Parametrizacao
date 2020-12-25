SELECT 
gp080.empfil,
gp085.mat,
gp080.ano, pmactbver.cod as codver,  
pmactbver.nome as descver, 
SUM (CASE gp085.mes WHEN 1 THEN (gp085.valor)/100 ELSE 0 END) AS Janeiro, 
CASE when (SUM (CASE gp085.mes WHEN 1 THEN (gp085.valor)/100 ELSE 0 END)  > 0) 
                         and (SUM (CASE gp085.mes WHEN 1 THEN (gp085.valor)/100 ELSE 0 END)  < SUM (CASE gp085.mes WHEN 2 THEN (gp085.valor)/100 ELSE 0 END)) then  
                         ((SUM (CASE gp085.mes WHEN 2 THEN (gp085.valor)/100 ELSE 0 END) - SUM (CASE gp085.mes WHEN 1 THEN (gp085.valor)/100 ELSE 0 END)  ) / SUM (CASE gp085.mes WHEN 1 THEN (gp085.valor)/100 ELSE 0 END)* 100)*-1 
      when (SUM (CASE gp085.mes WHEN 2 THEN (gp085.valor)/100 ELSE 0 END)  > 0) 
                         and (SUM (CASE gp085.mes WHEN 1 THEN (gp085.valor)/100 ELSE 0 END)  > SUM (CASE gp085.mes WHEN 2 THEN (gp085.valor)/100 ELSE 0 END)) then 
                         (SUM (CASE gp085.mes WHEN 1 THEN (gp085.valor)/100 ELSE 0 END) - SUM (CASE gp085.mes WHEN 2 THEN (gp085.valor)/100 ELSE 0 END)  ) / SUM (CASE gp085.mes WHEN 2 THEN (gp085.valor)/100 ELSE 0 END)* 100 
else 
0 
end as Percent1, 
           SUM (CASE gp085.mes WHEN 2 THEN (gp085.valor)/100 ELSE 0 END) AS Fevereiro, 
CASE when (SUM (CASE gp085.mes WHEN 2 THEN (gp085.valor)/100 ELSE 0 END)  > 0) 
                         and (SUM (CASE gp085.mes WHEN 2 THEN (gp085.valor)/100 ELSE 0 END)  < SUM (CASE gp085.mes WHEN 3 THEN (gp085.valor)/100 ELSE 0 END)) then 
                ((SUM (CASE gp085.mes WHEN 3 THEN (gp085.valor)/100 ELSE 0 END) - SUM (CASE gp085.mes WHEN 2 THEN (gp085.valor)/100 ELSE 0 END)  ) / SUM (CASE gp085.mes WHEN 2 THEN (gp085.valor)/100 ELSE 0 END)* 100)*-1 
          when (SUM (CASE gp085.mes WHEN 3 THEN (gp085.valor)/100 ELSE 0 END)  > 0) 
                         and (SUM (CASE gp085.mes WHEN 2 THEN (gp085.valor)/100 ELSE 0 END)  > SUM (CASE gp085.mes WHEN 3 THEN (gp085.valor)/100 ELSE 0 END)) then 
          (SUM (CASE gp085.mes WHEN 2 THEN (gp085.valor)/100 ELSE 0 END) - SUM (CASE gp085.mes WHEN 3 THEN (gp085.valor)/100 ELSE 0 END)  ) / SUM (CASE gp085.mes WHEN 3 THEN (gp085.valor)/100 ELSE 0 END)* 100 
else 
0 
end as Percent2, 
SUM (CASE gp085.mes WHEN 3 THEN (gp085.valor)/100 ELSE 0 END) AS Marco, 
CASE when (SUM (CASE gp085.mes WHEN 3 THEN (gp085.valor)/100 ELSE 0 END)  > 0) 
                         and (SUM (CASE gp085.mes WHEN 3 THEN (gp085.valor)/100 ELSE 0 END)  < SUM (CASE gp085.mes WHEN 4 THEN (gp085.valor)/100 ELSE 0 END)) then 
                ((SUM (CASE gp085.mes WHEN 4 THEN (gp085.valor)/100 ELSE 0 END) - SUM (CASE gp085.mes WHEN 3 THEN (gp085.valor)/100 ELSE 0 END)  ) / SUM (CASE gp085.mes WHEN 3 THEN (gp085.valor)/100 ELSE 0 END)* 100)*-1 
          when (SUM (CASE gp085.mes WHEN 4 THEN (gp085.valor)/100 ELSE 0 END)  > 0) 
                         and (SUM (CASE gp085.mes WHEN 3 THEN (gp085.valor)/100 ELSE 0 END)  > SUM (CASE gp085.mes WHEN 4 THEN (gp085.valor)/100 ELSE 0 END)) then 
             (SUM (CASE gp085.mes WHEN 3 THEN (gp085.valor)/100 ELSE 0 END) - SUM (CASE gp085.mes WHEN 4 THEN (gp085.valor)/100 ELSE 0 END)  ) / SUM (CASE gp085.mes WHEN 4 THEN (gp085.valor)/100 ELSE 0 END)* 100 
else 
0 
end as Percent3,  
SUM (CASE gp085.mes WHEN 4 THEN (gp085.valor)/100 ELSE 0 END) AS Abril, 
CASE when (SUM (CASE gp085.mes WHEN 4 THEN (gp085.valor)/100 ELSE 0 END)  > 0) 
                         and (SUM (CASE gp085.mes WHEN 4 THEN (gp085.valor)/100 ELSE 0 END)  < SUM (CASE gp085.mes WHEN 5 THEN (gp085.valor)/100 ELSE 0 END)) then 
                ((SUM (CASE gp085.mes WHEN 5 THEN (gp085.valor)/100 ELSE 0 END) - SUM (CASE gp085.mes WHEN 4 THEN (gp085.valor)/100 ELSE 0 END)  ) / SUM (CASE gp085.mes WHEN 4 THEN (gp085.valor)/100 ELSE 0 END)* 100)*-1 
          when (SUM (CASE gp085.mes WHEN 5 THEN (gp085.valor)/100 ELSE 0 END)  > 0) 
                         and (SUM (CASE gp085.mes WHEN 4 THEN (gp085.valor)/100 ELSE 0 END)  > SUM (CASE gp085.mes WHEN 5 THEN (gp085.valor)/100 ELSE 0 END)) then 
             (SUM (CASE gp085.mes WHEN 4 THEN (gp085.valor)/100 ELSE 0 END) - SUM (CASE gp085.mes WHEN 5 THEN (gp085.valor)/100 ELSE 0 END)  ) / SUM (CASE gp085.mes WHEN 5 THEN (gp085.valor)/100 ELSE 0 END)* 100 
else 
0 
end as Percent4,  
SUM (CASE gp085.mes WHEN 5 THEN (gp085.valor)/100 ELSE 0 END) AS Maio, 
CASE when (SUM (CASE gp085.mes WHEN 5 THEN (gp085.valor)/100 ELSE 0 END)  > 0) 
                         and (SUM (CASE gp085.mes WHEN 5 THEN (gp085.valor)/100 ELSE 0 END)  < SUM (CASE gp085.mes WHEN 6 THEN (gp085.valor)/100 ELSE 0 END)) then 
                ((SUM (CASE gp085.mes WHEN 6 THEN (gp085.valor)/100 ELSE 0 END) - SUM (CASE gp085.mes WHEN 5 THEN (gp085.valor)/100 ELSE 0 END)  ) / SUM (CASE gp085.mes WHEN 5 THEN (gp085.valor)/100 ELSE 0 END)* 100)*-1 
          when (SUM (CASE gp085.mes WHEN 6 THEN (gp085.valor)/100 ELSE 0 END)  > 0) 
                         and (SUM (CASE gp085.mes WHEN 5 THEN (gp085.valor)/100 ELSE 0 END)  > SUM (CASE gp085.mes WHEN 6 THEN (gp085.valor)/100 ELSE 0 END)) then 
             (SUM (CASE gp085.mes WHEN 5 THEN (gp085.valor)/100 ELSE 0 END) - SUM (CASE gp085.mes WHEN 6 THEN (gp085.valor)/100 ELSE 0 END)  ) / SUM (CASE gp085.mes WHEN 6 THEN (gp085.valor)/100 ELSE 0 END)* 100 
else 
0 
end as Percent5,  
SUM (CASE gp085.mes WHEN 6 THEN (gp085.valor)/100 ELSE 0 END) AS junho, 
CASE when (SUM (CASE gp085.mes WHEN 6 THEN (gp085.valor)/100 ELSE 0 END)  > 0) 
                         and (SUM (CASE gp085.mes WHEN 6 THEN (gp085.valor)/100 ELSE 0 END)  < SUM (CASE gp085.mes WHEN 7 THEN (gp085.valor)/100 ELSE 0 END)) then 
                ((SUM (CASE gp085.mes WHEN 7 THEN (gp085.valor)/100 ELSE 0 END) - SUM (CASE gp085.mes WHEN 6 THEN (gp085.valor)/100 ELSE 0 END)  ) / SUM (CASE gp085.mes WHEN 6 THEN (gp085.valor)/100 ELSE 0 END)* 100)*-1 
          when (SUM (CASE gp085.mes WHEN 7 THEN (gp085.valor)/100 ELSE 0 END)  > 0) 
                         and (SUM (CASE gp085.mes WHEN 6 THEN (gp085.valor)/100 ELSE 0 END)  > SUM (CASE gp085.mes WHEN 7 THEN (gp085.valor)/100 ELSE 0 END)) then 
             (SUM (CASE gp085.mes WHEN 6 THEN (gp085.valor)/100 ELSE 0 END) - SUM (CASE gp085.mes WHEN 7 THEN (gp085.valor)/100 ELSE 0 END)  ) / SUM (CASE gp085.mes WHEN 7 THEN (gp085.valor)/100 ELSE 0 END)* 100 
else 
0 
end as Percent6,  
SUM (CASE gp085.mes WHEN 7 THEN (gp085.valor)/100 ELSE 0 END) AS julho,  
    CASE when (SUM (CASE gp085.mes WHEN 7 THEN (gp085.valor)/100 ELSE 0 END)  > 0) 
                         and (SUM (CASE gp085.mes WHEN 7 THEN (gp085.valor)/100 ELSE 0 END)  < SUM (CASE gp085.mes WHEN 8 THEN (gp085.valor)/100 ELSE 0 END)) then 
                ((SUM (CASE gp085.mes WHEN 8 THEN (gp085.valor)/100 ELSE 0 END) - SUM (CASE gp085.mes WHEN 7 THEN (gp085.valor)/100 ELSE 0 END)  ) / SUM (CASE gp085.mes WHEN 7 THEN (gp085.valor)/100 ELSE 0 END)* 100)*-1 
          when (SUM (CASE gp085.mes WHEN 8 THEN (gp085.valor)/100 ELSE 0 END)  > 0) 
                         and (SUM (CASE gp085.mes WHEN 7 THEN (gp085.valor)/100 ELSE 0 END)  > SUM (CASE gp085.mes WHEN 8 THEN (gp085.valor)/100 ELSE 0 END)) then           
(SUM (CASE gp085.mes WHEN 7 THEN (gp085.valor)/100 ELSE 0 END) - SUM (CASE gp085.mes WHEN 8 THEN (gp085.valor)/100 ELSE 0 END)  ) / SUM (CASE gp085.mes WHEN 8 THEN (gp085.valor)/100 ELSE 0 END)* 100 
else 
0 
end as Percent7,  
SUM (CASE gp085.mes WHEN 8 THEN (gp085.valor)/100 ELSE 0 END) AS Agosto, 
        CASE when (SUM (CASE gp085.mes WHEN 8 THEN (gp085.valor)/100 ELSE 0 END)  > 0) 
                         and (SUM (CASE gp085.mes WHEN 8 THEN (gp085.valor)/100 ELSE 0 END)  < SUM (CASE gp085.mes WHEN 9 THEN (gp085.valor)/100 ELSE 0 END)) then 
                ((SUM (CASE gp085.mes WHEN 9 THEN (gp085.valor)/100 ELSE 0 END) - SUM (CASE gp085.mes WHEN 8 THEN (gp085.valor)/100 ELSE 0 END)  ) / SUM (CASE gp085.mes WHEN 8 THEN (gp085.valor)/100 ELSE 0 END)* 100)*-1 
          when (SUM (CASE gp085.mes WHEN 9 THEN (gp085.valor)/100 ELSE 0 END)  > 0) 
                         and (SUM (CASE gp085.mes WHEN 8 THEN (gp085.valor)/100 ELSE 0 END)  > SUM (CASE gp085.mes WHEN 9 THEN (gp085.valor)/100 ELSE 0 END)) then          
(SUM (CASE gp085.mes WHEN 8 THEN (gp085.valor)/100 ELSE 0 END) - SUM (CASE gp085.mes WHEN 9 THEN (gp085.valor)/100 ELSE 0 END)  ) / SUM (CASE gp085.mes WHEN 9 THEN (gp085.valor)/100 ELSE 0 END)* 100 
else 
0 
end as Percent8,  
SUM (CASE gp085.mes WHEN 9 THEN (gp085.valor)/100 ELSE 0 END) AS Setembro,  
        CASE when (SUM (CASE gp085.mes WHEN 9 THEN (gp085.valor)/100 ELSE 0 END)  > 0) 
                        and (SUM (CASE gp085.mes WHEN 9 THEN (gp085.valor)/100 ELSE 0 END)  < SUM (CASE gp085.mes WHEN 10 THEN (gp085.valor)/100 ELSE 0 END)) then 
                ((SUM (CASE gp085.mes WHEN 10 THEN (gp085.valor)/100 ELSE 0 END) - SUM (CASE gp085.mes WHEN 9 THEN (gp085.valor)/100 ELSE 0 END)  ) / SUM (CASE gp085.mes WHEN 9 THEN (gp085.valor)/100 ELSE 0 END)* 100)*-1 
          when (SUM (CASE gp085.mes WHEN 10 THEN (gp085.valor)/100 ELSE 0 END)  > 0) 
                         and (SUM (CASE gp085.mes WHEN 9 THEN (gp085.valor)/100 ELSE 0 END)  > SUM (CASE gp085.mes WHEN 10 THEN (gp085.valor)/100 ELSE 0 END)) then            
(SUM (CASE gp085.mes WHEN 9 THEN (gp085.valor)/100 ELSE 0 END) - SUM (CASE gp085.mes WHEN 10 THEN (gp085.valor)/100 ELSE 0 END)  ) / SUM (CASE gp085.mes WHEN 10 THEN (gp085.valor)/100 ELSE 0 END)* 100 
else 
0 
end as Percent9,  
SUM (CASE gp085.mes WHEN 10 THEN (gp085.valor)/100 ELSE 0 END) AS Outubro, 
        CASE when (SUM (CASE gp085.mes WHEN 10 THEN (gp085.valor)/100 ELSE 0 END)  > 0) 
                         and (SUM (CASE gp085.mes WHEN 10 THEN (gp085.valor)/100 ELSE 0 END)  < SUM (CASE gp085.mes WHEN 11 THEN (gp085.valor)/100 ELSE 0 END)) then 
                ((SUM (CASE gp085.mes WHEN 11 THEN (gp085.valor)/100 ELSE 0 END) - SUM (CASE gp085.mes WHEN 10 THEN (gp085.valor)/100 ELSE 0 END)  ) / SUM (CASE gp085.mes WHEN 10 THEN (gp085.valor)/100 ELSE 0 END)* 100)*-1 
          when (SUM (CASE gp085.mes WHEN 11 THEN (gp085.valor)/100 ELSE 0 END)  > 0) 
                         and (SUM (CASE gp085.mes WHEN 10 THEN (gp085.valor)/100 ELSE 0 END)  > SUM (CASE gp085.mes WHEN 11 THEN (gp085.valor)/100 ELSE 0 END)) then             
(SUM (CASE gp085.mes WHEN 10 THEN (gp085.valor)/100 ELSE 0 END) - SUM (CASE gp085.mes WHEN 11 THEN (gp085.valor)/100 ELSE 0 END)  ) / SUM (CASE gp085.mes WHEN 11 THEN (gp085.valor)/100 ELSE 0 END)* 100 
else 
0 
end as Percent10,  
SUM (CASE gp085.mes WHEN 11 THEN (gp085.valor)/100 ELSE 0 END) AS Novembro, 
        CASE when (SUM (CASE gp085.mes WHEN 11 THEN (gp085.valor)/100 ELSE 0 END)  > 0) 
                         and (SUM (CASE gp085.mes WHEN 11 THEN (gp085.valor)/100 ELSE 0 END)  < SUM (CASE gp085.mes WHEN 12 THEN (gp085.valor)/100 ELSE 0 END)) then 
                ((SUM (CASE gp085.mes WHEN 12 THEN (gp085.valor)/100 ELSE 0 END) - SUM (CASE gp085.mes WHEN 11 THEN (gp085.valor)/100 ELSE 0 END)  ) / SUM (CASE gp085.mes WHEN 11 THEN (gp085.valor)/100 ELSE 0 END)* 100)*-1 
          when (SUM (CASE gp085.mes WHEN 12 THEN (gp085.valor)/100 ELSE 0 END)  > 0) 
                         and (SUM (CASE gp085.mes WHEN 11 THEN (gp085.valor)/100 ELSE 0 END)  > SUM (CASE gp085.mes WHEN 12 THEN (gp085.valor)/100 ELSE 0 END)) then             
(SUM (CASE gp085.mes WHEN 11 THEN (gp085.valor)/100 ELSE 0 END) - SUM (CASE gp085.mes WHEN 12 THEN (gp085.valor)/100 ELSE 0 END)  ) / SUM (CASE gp085.mes WHEN 12 THEN (gp085.valor)/100 ELSE 0 END)* 100 
else 
0 
end as Percent11,  
SUM (CASE gp085.mes WHEN 12 THEN (gp085.valor)/100 ELSE 0 END) AS Dezembro, 
SUM (CASE gp085.mes WHEN 1 THEN (gp085.valor)/100 ELSE 0 END) + SUM (CASE gp085.mes WHEN 2 THEN (gp085.valor)/100 ELSE 0 END) + 
SUM (CASE gp085.mes WHEN 3 THEN (gp085.valor)/100 ELSE 0 END) + SUM (CASE gp085.mes WHEN 4 THEN (gp085.valor)/100 ELSE 0 END) + 
SUM (CASE gp085.mes WHEN 5 THEN (gp085.valor)/100 ELSE 0 END) + SUM (CASE gp085.mes WHEN 6 THEN (gp085.valor)/100 ELSE 0 END) + 
SUM (CASE gp085.mes WHEN 7 THEN (gp085.valor)/100 ELSE 0 END) + SUM (CASE gp085.mes WHEN 8 THEN (gp085.valor)/100 ELSE 0 END) + 
SUM (CASE gp085.mes WHEN 9 THEN (gp085.valor)/100 ELSE 0 END) + SUM (CASE gp085.mes WHEN 10 THEN (gp085.valor)/100 ELSE 0 END) + 
SUM (CASE gp085.mes WHEN 11 THEN (gp085.valor)/100 ELSE 0 END) + SUM (CASE gp085.mes WHEN 12 THEN (gp085.valor)/100 ELSE 0 END) AS TotVer                                 
FROM fp.pmactbver 
INNER JOIN fp.gp085 
ON pmactbver.cod = gp085.vrb 
inner join fp.gp080 
on gp080.ano    = gp085.ano 
and gp080.mes    = gp085.mes 
and gp080.mat    = gp085.mat 
and gp080.folha  = gp085.folha 
inner join fp.pmactbfil 
on gp080.empfil = pmactbfil.cod 
where gp080.ano = 2020 
and   gp080.liquido > 0 
and gp085.valor > 0 
and PMACTBVER.cod < 800 
and gp080.folha = 0 
GROUP BY   gp085.vrb,pmactbver.cod,pmactbver.nome,gp080.ano , gp080.empfil, gp085.mat
ORDER BY gp085.vrb,gp080.ano;
