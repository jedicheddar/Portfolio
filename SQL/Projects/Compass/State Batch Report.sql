SELECT  a.agentID
       ,a.name
       ,b.periodYear
FROM    COMPASS.dbo.batch b right outer join
        COMPASS.dbo.agent a
     on a.agentID = b.agentID
    and a.stateID = b.stateID
WHERE   a.stateID = 'KS'
  and   (b.periodYear = 2015 or b.periodYear is null)
  and   (b.stat = 'C' or b.stat is null)
group by a.agentID
       ,a.name
       ,b.periodYear
order by a.agentID