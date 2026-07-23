use COMPASS

declare @agentID varchar(10) = '031031'
declare @batchID int = 1409098

select  distinct
        b.batchID,
        b.periodYear,
        b.periodMonth,
        sum(datediff(day,bf.effDate,b.receivedDate)) as 'days',
        count(bf.policyID) as 'cnt',
        sum(datediff(day,bf.effDate,b.receivedDate)) / count(bf.policyID) as 'gap'
from    batchform bf inner join
        batch b
     on b.batchID = bf.batchID 
where   b.agentID = @agentID
group by b.batchID,
         b.periodYear,
         b.periodMonth
order by b.periodYear,b.periodMonth

EXEC	[dbo].[spCalculateReportGap] @batchID = @batchID
