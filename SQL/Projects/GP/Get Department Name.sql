use ANTIC

DECLARE @dept as varchar(5) = ''

if (@dept <> '')
begin
  select  a.SGMNTID
         ,a.DSCRIPTN
  from GL40200 a --segment master
  where a.SGMNTID = @dept
  order by a.SGMNTID
end
else
begin
  select  distinct
          a.SGMNTID
         ,a.DSCRIPTN
         ,b.ACTNUMST
  from GL40200 a --segment master
       inner join
       GL00105 b
       on a.SGMNTID = b.ACTNUMBR_3
  order by a.SGMNTID
end