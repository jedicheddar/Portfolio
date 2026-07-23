DECLARE @policyList VARCHAR(MAX) = ''

IF (@policyList <> '')
BEGIN
  CREATE TABLE #policy 
  (
    [agentID] VARCHAR(30),
    [officeID] INTEGER,
    [policyID] INTEGER,
    [liability] MONEY,
    [gross] MONEY,
    [Source] VARCHAR(30),
    [user] VARCHAR(100),
    [policytype] INTEGER,
    [effective] DATETIME,
    [issueDate] DATETIME,
    [residential] BIT
  )

  DECLARE @sql NVARCHAR(MAX) = ''

  SET @sql = 'INSERT INTO #policy ([agentID],[officeID],[policyID],[liability],[gross],[Source],[user],[policytype],[effective],[issueDate],[residential])
              SELECT  c.[cintid],
                      p.[cid],
                      p.[policyid],
                      p.[liabilityamount],
                      p.[grosspremium],
                      p.[Source],
                      p.[agent],
                      p.[pformID],
                      p.[effectivedate],
                      p.[used],
                      p.[residential]
              FROM    [dbo].[t_policies] p INNER JOIN
                      [dbo].[t_company] c
              ON      p.[cid] = c.[cid]
              WHERE   p.[policyid] IN (' + @policyList + ')'

  INSERT INTO #policy ([agentID],[officeID],[policyID],[liability],[gross],[Source],[user],[policytype],[effective],[issueDate],[residential])
  EXEC sp_executesql @sql

  SELECT  '
  {\n
    "name": "Policy Issue ' + CONVERT(VARCHAR,[policyID]) +'",\n
    "event": [\n
      {\n
        "listen": "test",\n
        "script": {\n
          "exec": [\n
            "pm.test(\"Success\", function () {\r",\n
            "    var jsonData = pm.response.json();\r",\n
            "    pm.expect(jsonData.Envelope.Body.Success.code).to.eql(\"2000\");\r",\n
            "});"\n
          ],\n
          "type": "text/javascript"\n
        }\n
      }\n
    ],\n
    "request": {\n
      "method": "POST",\n
      "header": [\n
        {\n
          "key": "Content-Type",\n
          "name": "Content-Type",\n
          "type": "text",\n
          "value": "application/json"\n
        }\n
      ],\n
      "body": {\n
        "mode": "raw",\n
        "raw": "{\"AgentId\": \"' + [agentID] + '\", \"OfficeId\": ' + CONVERT(VARCHAR,[officeID]) + ', \"PolicyId\": ' + CONVERT(VARCHAR,[policyID]) + ', \"LiabilityAmount\": ' + CONVERT(VARCHAR,COALESCE([liability],0)) + ', \"GrossPremiumAmount\": ' + CONVERT(VARCHAR,COALESCE([gross],0)) + ', \"Source\": \"' + COALESCE([Source],'ARC') + '\", \"Username\": \"' + ISNULL([user],'Unknown') + '\", \"PolicyTemplateId\": ' + CONVERT(VARCHAR,ISNULL([policytype],0)) + ', \"EffectiveDate\": \"' + ISNULL(COALESCE(CONVERT(VARCHAR,[effective], 101), CONVERT(VARCHAR,[issueDate], 101)),'NULL') + '\", \"IssueDate\": \"' + CONVERT(VARCHAR,[issueDate], 101) + '\", \"Residential\": ' + CASE WHEN [residential] = 1 THEN 'true' ELSE 'false' END + '}",\n
        "options": {\n
          "raw": {\n
            "language": "json"\n
          }\n
        }\n
      },\n
      "url": {\n
        "raw": "https://compass.alliantnational.com:8118/do/action/WService={{env}}/act?I1={{Username}}&I2={{Password}}&I3=arcPolicyIssue",\n
        "protocol": "https",\n
        "host": [\n
          "compass",\n
          "alliantnational",\n
          "com"\n
        ],\n
        "port": "8118",\n
        "path": [\n
          "do",\n
          "action",\n
          "WService={{env}}",\n
          "act"\n
        ],\n
        "query": [\n
          {\n
            "key": "I1",\n
            "value": "{{Username}}"\n
          },\n
          {\n
            "key": "I2",\n
            "value": "{{Password}}"\n
          },\n
          {\n
            "key": "I3",\n
            "value": "arcPolicyIssue"\n
          }\n
        ]\n
      }\n
    },\n
    "response": []\n
  },'
  FROM    #policy

  DROP TABLE #policy
END
