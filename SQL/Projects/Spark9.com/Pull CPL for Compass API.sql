CREATE TABLE #cpl 
(
  [agentID] VARCHAR(30),
  [officeID] INTEGER,
  [cplID] VARCHAR(30),
  [fileNumber] VARCHAR(100),
  [liability] MONEY,
  [Source] VARCHAR(30),
  [user] VARCHAR(100),
  [issueDate] DATETIME,
  [address] VARCHAR(1000),
  [city] VARCHAR(1000),
  [state] VARCHAR(1000),
  [zip] VARCHAR(1000)
)

INSERT INTO #cpl ([agentID],[officeID],[cplID],[fileNumber],[liability],[Source],[user],[issueDate],[address],[city],[state],[zip])
SELECT  c.[cintid],
        i.[EscrowID],
        i.[code],
        i.[FileNumber],
        i.[liabilityamount],
        i.[Source],
        i.[agent],
        i.[ICLDate],
        p.[Address1],
        p.[City],
        p.[State],
        p.[Zipcode]
FROM    [dbo].[t_icl] i INNER JOIN
        [dbo].[t_company] c
ON      i.[EscrowID] = c.[cid] INNER JOIN
        [dbo].[CPLProperties] p
ON      i.[iclid] = p.[CPLID]
WHERE   i.[ICLDate] > '2020-06-01'

SELECT  '|T|T{[n]' +
      + '|T|T|T"name": "CPL Issue ' + CONVERT(VARCHAR,[cplID]) +'",[n]' +
      + '|T|T|T"request": {[n]' +
      + '|T|T|T|T"method": "POST",[n]' +
      + '|T|T|T|T"header": [[n]' +
      + '|T|T|T|T|T{[n]' +
      + '|T|T|T|T|T|T"key": "Content-Type",[n]' +
      + '|T|T|T|T|T|T"name": "Content-Type",[n]' +
      + '|T|T|T|T|T|T"type": "text",[n]' +
      + '|T|T|T|T|T|T"value": "application/json"[n]' +
      + '|T|T|T|T|T}[n]' +
      + '|T|T|T|T],[n]' +
      + '|T|T|T|T"body": {[n]' +
      + '|T|T|T|T|T"mode": "raw",[n]' +
      + '|T|T|T|T|T"raw": "{\"GfNumber\": \"' + COALESCE([fileNumber],'') + '\", \"AgentId\": \"' + [agentID] + '\", \"OfficeId\": ' + CONVERT(VARCHAR,[officeID]) + ', \"CPLCode\": \"' + CONVERT(VARCHAR,[cplID]) + '\", \"LiabilityAmount\": ' + CONVERT(VARCHAR,COALESCE([liability],0)) + ', \"Source\": \"' + COALESCE([Source],'ARC') + '\", \"Username\": \"' + ISNULL([user],'Unknown') + '\", \"IssueDate\": \"' + CONVERT(VARCHAR,[issueDate], 101) + '\", \"PropertyAddress\": \"' + [address] + '\", \"PropertyCity\": \"' + [city] + '\", \"PropertyState\": \"' + [state] + '\", \"PropertyZip\": \"' + [zip] + '\"}",[n]' +
      + '|T|T|T|T|T"options": {[n]' +
      + '|T|T|T|T|T|T"raw": {[n]' +
      + '|T|T|T|T|T|T|T"language": "json"[n]' +
      + '|T|T|T|T|T|T}[n]' +
      + '|T|T|T|T|T}[n]' +
      + '|T|T|T|T},[n]' +
      + '|T|T|T|T"url": {[n]' +
      + '|T|T|T|T|T"raw": "https://compass.alliantnational.com:8118/do/action/WService={{env}}/get?I1={{Username}}&I2={{Password}}&I3=arcCplIssue",[n]' +
      + '|T|T|T|T|T"protocol": "https",[n]' +
      + '|T|T|T|T|T"host": [[n]' +
      + '|T|T|T|T|T|T"compass",[n]' +
      + '|T|T|T|T|T|T"alliantnational",[n]' +
      + '|T|T|T|T|T|T"com"[n]' +
      + '|T|T|T|T|T],[n]' +
      + '|T|T|T|T|T"port": "8118",[n]' +
      + '|T|T|T|T|T"path": [[n]' +
      + '|T|T|T|T|T|T"do",[n]' +
      + '|T|T|T|T|T|T"action",[n]' +
      + '|T|T|T|T|T|T"WService={{env}}",[n]' +
      + '|T|T|T|T|T|T"get"[n]' +
      + '|T|T|T|T|T],[n]' +
      + '|T|T|T|T|T"query": [[n]' +
      + '|T|T|T|T|T|T{[n]' +
      + '|T|T|T|T|T|T|T"key": "I1",[n]' +
      + '|T|T|T|T|T|T|T"value": "{{Username}}"[n]' +
      + '|T|T|T|T|T|T},[n]' +
      + '|T|T|T|T|T|T{[n]' +
      + '|T|T|T|T|T|T|T"key": "I2",[n]' +
      + '|T|T|T|T|T|T|T"value": "{{Password}}"[n]' +
      + '|T|T|T|T|T|T},[n]' +
      + '|T|T|T|T|T|T{[n]' +
      + '|T|T|T|T|T|T|T"key": "I3",[n]' +
      + '|T|T|T|T|T|T|T"value": "arcCplIssue"[n]' +
      + '|T|T|T|T|T|T}[n]' +
      + '|T|T|T|T|T][n]' +
      + '|T|T|T|T}[n]' +
      + '|T|T|T},[n]' +
      + '|T|T|T"response": [][n]' +
      + '|T|T},'
FROM    #cpl

DROP TABLE #cpl