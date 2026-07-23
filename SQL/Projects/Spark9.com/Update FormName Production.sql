declare @formtable table (newform varchar(200),oldform varchar(200),formstate varchar(2), fname varchar(200),id int)

declare @state varchar(2) = '' -- enter the state

insert into @formtable (newform,oldform,formstate,fname,id)
select  a.[FormName]
       ,b.[FormName]
       ,a.[State]
       ,a.[FileName]
       ,b.[PFormID]
from    (
        Select  [FormName]
               ,[State]
               ,[FileName]
               ,[PFormID]
        from    dev_alliant.dbo.t_policyforms
        where   [State] = @state
        ) a inner join
        (
        Select  [FormName]
               ,[State]
               ,[FileName]
               ,[PFormID]
        from    alliant.dbo.t_policyforms
        where   [State] = @state
        ) b
     on a.[FileName] = b.[FileName]

select  a.PFormID
       ,a.FormName as CurrentFormName
       ,b.newform as NewFormName
       ,a.FileName
       ,a.Active
from    alliant.dbo.t_policyforms a inner join
        @formtable b
     on a.pformid = b.id
  where b.oldform <> b.newform

IF @@ROWCOUNT > 0
BEGIN
  select distinct 'UPDATE alliant.dbo.t_policyforms set FormName=''' + newform + ''' where PFormID = ' + cast(id as varchar(10)) from @formtable where oldform <> newform
END