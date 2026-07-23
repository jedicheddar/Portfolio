USE [COMPASS]
GO
DECLARE @appCode VARCHAR(20) = 'CLM',
        @objAction VARCHAR(100) = 'Vendor',
        @objProperty VARCHAR(100) = 'Vendor',
        @modifiedBy VARCHAR(100) = 'joliver@alliantnational.com'
        
CREATE TABLE #propTable ([objID] VARCHAR(100), [objName] VARCHAR(100))
INSERT INTO #propTable ([objID], [objName]) VALUES ('1090','Karsh Gabler Call PC')
INSERT INTO #propTable ([objID], [objName]) VALUES ('1641','Figari & Davenport, LLP')
INSERT INTO #propTable ([objID], [objName]) VALUES ('1701','Mueller and Neff Real Estate Appraisers')
INSERT INTO #propTable ([objID], [objName]) VALUES ('1717','Gust Rosenfeld, P.L.C.')
INSERT INTO #propTable ([objID], [objName]) VALUES ('1787','Biernacki & Biernacki, P.A.')
INSERT INTO #propTable ([objID], [objName]) VALUES ('1830','Adams And Reese LLP')
INSERT INTO #propTable ([objID], [objName]) VALUES ('1860','Investors Title Company')
INSERT INTO #propTable ([objID], [objName]) VALUES ('1862','Fitch & Associates')
INSERT INTO #propTable ([objID], [objName]) VALUES ('1934','Winderweedle, Haines, Ward & Woodman, PA')
INSERT INTO #propTable ([objID], [objName]) VALUES ('1957','Lowndes, Drosdick, Doster, Kantor & Reed')
INSERT INTO #propTable ([objID], [objName]) VALUES ('1998','Simplifile LC')
INSERT INTO #propTable ([objID], [objName]) VALUES ('2176','Ramras Legal, PLC')
INSERT INTO #propTable ([objID], [objName]) VALUES ('2282','Clark Partington')
INSERT INTO #propTable ([objID], [objName]) VALUES ('2288','Oliver Law Office')
INSERT INTO #propTable ([objID], [objName]) VALUES ('2301','Jackson Walker LLP')
INSERT INTO #propTable ([objID], [objName]) VALUES ('2346','Kent McMillan')
INSERT INTO #propTable ([objID], [objName]) VALUES ('2466','Lewis Roca Rothgerber Christie LLP')
INSERT INTO #propTable ([objID], [objName]) VALUES ('2536','Callison Tighe & Robinson LLC')
INSERT INTO #propTable ([objID], [objName]) VALUES ('2561','Ballaga, Freedman & Atkins, LLP')
INSERT INTO #propTable ([objID], [objName]) VALUES ('2571','Hein Schneider & Bond P.C.')
INSERT INTO #propTable ([objID], [objName]) VALUES ('2573','Ritter Chusid, LLP')
INSERT INTO #propTable ([objID], [objName]) VALUES ('2597','Travis Investigations, Inc')
INSERT INTO #propTable ([objID], [objName]) VALUES ('2599','Lien Sweeper')
INSERT INTO #propTable ([objID], [objName]) VALUES ('2638','Quilling Selander Lownds Winslett & Moser PC')
INSERT INTO #propTable ([objID], [objName]) VALUES ('2674','Briner Law Group, LLC')
INSERT INTO #propTable ([objID], [objName]) VALUES ('2716','Levine Kellogg Lehman Schneider & Grossman LLP')
INSERT INTO #propTable ([objID], [objName]) VALUES ('2762','Kolesar & Leatham, Chtd')
INSERT INTO #propTable ([objID], [objName]) VALUES ('2782','Anderson, McPharlin & Conners LLP')
INSERT INTO #propTable ([objID], [objName]) VALUES ('2794','Ritter Chusid, LLP Trust Account')
INSERT INTO #propTable ([objID], [objName]) VALUES ('3032','DeLange Hudspeth McConnell & Tibbets LLP')
INSERT INTO #propTable ([objID], [objName]) VALUES ('3065','David H. Stotts')
INSERT INTO #propTable ([objID], [objName]) VALUES ('3073','Bogin, Munns & Munns, P.A.')
INSERT INTO #propTable ([objID], [objName]) VALUES ('3077','Olson, Redford & Wahlberg, P.A.')
INSERT INTO #propTable ([objID], [objName]) VALUES ('3163','Tannenbaum Scro, PLLC')
INSERT INTO #propTable ([objID], [objName]) VALUES ('3167','Pray Walker PC')
INSERT INTO #propTable ([objID], [objName]) VALUES ('5011','The Gilroy Firm')
INSERT INTO #propTable ([objID], [objName]) VALUES ('5020','Offit Kurman P.A.')
INSERT INTO #propTable ([objID], [objName]) VALUES ('5038','McGarvey PLLC')
INSERT INTO #propTable ([objID], [objName]) VALUES ('5040','Maurice Wood PLLC')
INSERT INTO #propTable ([objID], [objName]) VALUES ('5058','HeirSearch')
INSERT INTO #propTable ([objID], [objName]) VALUES ('5092','Brown & Ruprecht, PC')
INSERT INTO #propTable ([objID], [objName]) VALUES ('5096','Keating Brown PLLC')
INSERT INTO #propTable ([objID], [objName]) VALUES ('5123','Branum PLLC')
INSERT INTO #propTable ([objID], [objName]) VALUES ('5124','North Star Title Services, LLC')
INSERT INTO #propTable ([objID], [objName]) VALUES ('5188','Timmins LLC')

INSERT INTO [dbo].[sysprop] ([appCode],[objAction],[objID],[objProperty],[objValue],[objName],[objDesc],[objRef],[lastModified],[modifiedBy],[comments])
SELECT  @appCode,
        @objAction,
        [objID],
        @objProperty,
        '',
        [objName],
        '',
        '',
        GETDATE(),
        @modifiedBy,
        'Vendor approved by Noemi Dedouh (ndedouh@alliantnational.com)'
FROM    #propTable

SELECT  *
FROM    [dbo].[sysprop]
WHERE   [appCode] = @appCode
AND     [objAction] = @objAction
AND     [objProperty] = @objProperty

DROP TABLE #propTable
GO