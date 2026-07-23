use alliant_test

declare @code varchar(max) = '15GHDBMS11' -- place the code here
declare @cplIDTable table (id int)

insert into @cplIDTable (id)
select iclid from dbo.t_icl where code in (@code)

--holding tables
declare @cplTable table 
(	[FileNumber] [varchar](2000) NULL,
	[lender_id] [int] NULL,
	[Agent] [varchar](50) NULL,
	[AgentFullName] [varchar](100) NULL,
	[LenderName] [varchar](300) NULL,
	[StateName] [varchar](20) NULL,
	[LogID] [int] NULL,
	[ISAOA] [bit] NULL,
	[ATIMA] [bit] NULL,
	[VA] [bit] NOT NULL,
	[HUD] [bit] NOT NULL,
	[EscrowID] [int] NULL,
	[ICLDate] [datetime] NOT NULL,
	[GFNumber] [varchar](200) NULL,
	[PAddress1] [varchar](100) NULL,
	[PAddress2] [varchar](100) NULL,
	[PCity] [varchar](50) NULL,
	[PState] [varchar](50) NULL,
	[PZipcode] [varchar](12) NULL,
	[BorrowerF] [varchar](1000) NULL,
	[BorrowerL] [varchar](1000) NULL,
	[Version] [int] NOT NULL,
	[ClosingLetterID] [int] NULL,
	[SAddress1] [varchar](100) NULL,
	[SAddress2] [varchar](100) NULL,
	[SCity] [varchar](50) NULL,
	[SState] [varchar](50) NULL,
	[SZipcode] [varchar](12) NULL,
	[SellerF] [varchar](1000) NULL,
	[SellerL] [varchar](1000) NULL,
	[SellerInfo] [bit] NOT NULL,
	[Abbreviate] [bit] NOT NULL,
	[ShowBranches] [bit] NOT NULL,
	[Borrower] [varchar](2000) NULL,
	[Seller] [varchar](2000) NULL,
	[Code] [char](10) NULL,
	[Status] [varchar](10) NULL,
	[StatusChangeDate] [datetime] NULL,
	[PolicyID] [int] NULL,
	[AttorneyID] [int] NULL,
	[TransactionType] [varchar](50) NOT NULL,
	[LenderExtra] [varchar](500) NULL,
	[CPLType] [varchar](10) NULL,
	[LiabilityAmount] [money] NULL,
	[EstimatedClosingDate] [datetime] NULL
)

declare @propTable table
(	[CPLID] [int] NOT NULL,
	[Address1] [varchar](500) NULL,
	[Address2] [varchar](500) NULL,
	[City] [varchar](100) NULL,
	[State] [varchar](50) NULL,
	[Zipcode] [varchar](20) NULL
)

declare @beneTable table 
(	[BeneficiaryId] [int] NOT NULL,
	[CplId] [int] NOT NULL
)

SELECT 
    RowNum = ROW_NUMBER() OVER(ORDER BY act)
    ,*
INTO #temp
FROM @cplIDTable

DECLARE @MaxRownum INT
SET @MaxRownum = (SELECT MAX(RowNum) FROM #temp)

DECLARE @Iter INT
SET @Iter = (SELECT MIN(RowNum) FROM #temp)

WHILE @Iter <= @MaxRownum
BEGIN

  -- TODO: add logic to save the old data into variable tables
    
  SET @Iter = @Iter + 1
END

DROP TABLE #temp

select  [CPLID]
	     ,[Address1]
	     ,[Address2]
 	     ,[City]
	     ,[State]
	     ,[Zipcode]
from    dbo.CPLProperties
where   CPLID in (select id from @cplIDTable)