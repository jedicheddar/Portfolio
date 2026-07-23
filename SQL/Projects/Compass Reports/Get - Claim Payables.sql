USE [COMPASS]

SELECT  (SELECT [objValue] FROM [sysprop] WHERE [appCode] = 'CLM' AND [objAction] = 'PayableInvoice' AND [objProperty] = 'Status' AND [objID] = inv.[stat]) AS [Status],
        inv.[hasDocument] AS [Has Doc],
        inv.[reduceLiability] AS [Red. Liab.],
        (SELECT [objValue] FROM [sysprop] WHERE [appCode] = 'CLM' AND [objAction] = 'PayableInvoice' AND [objProperty] = 'Category' AND [objID] = inv.[refCategory]) AS [Category],
        inv.[vendorID] AS [Vendor ID],
        inv.[vendorName] AS [Vendor Name],
        inv.[refID] AS [Claim ID],
        inv.[invoiceDate] AS [Invoice Date],
        inv.[invoiceNumber] AS [Invoice Number],
        inv.[appDate] AS [Approval Date],
        inv.[approval] AS [Approved By],
        inv.[transDate] AS [Posting Date],
        inv.[amount] AS [Amount]
FROM    (
        SELECT  inv.[apinvID],
                ISNULL(trx.[aptrxID],0) AS 'aptrxID',
                inv.[stat],
                CASE
                  WHEN inv.[refType] = 'C' THEN 'Claim'
                END AS 'refDescription',
                inv.[refType],
                inv.[refID],
                inv.[contention],
                'P' AS 'invoiceType',
                inv.[refCategory],
                inv.[vendorID],
                inv.[vendorName],
                inv.[invoiceNumber],
                inv.[invoiceDate],
                inv.[dateReceived] AS 'recDate',
                CASE
                  WHEN inv.[stat] = 'C' or inv.[stat] = 'V' THEN trx.[transAmount]
                  WHEN inv.[stat] = 'A' THEN app.[amount]
                  WHEN inv.[stat] = 'O' or inv.[stat] = 'D' THEN inv.[amount]
                END AS 'amount',
                CASE WHEN doc.[entityID] IS NOT NULL 
                  THEN 'True'
                  ELSE 'False'
                END AS 'hasDocument',
                CASE WHEN inv.[reduceLiability] = 1
                  THEN 'True'
                  ELSE 'False'
                END AS [reduceLiability],
                app.[dateActed] AS 'appDate',
                trx.[transAmount],
                trx.[transDate],
                CONVERT(VARCHAR(1000),ISNULL(app.[uid],'')) AS 'uid',
                CONVERT(VARCHAR(1000),ISNULL(app.[name],'')) AS 'approval',
                CASE WHEN inv.[stat] = 'C' OR inv.[stat] = 'V'
                  THEN DATEDIFF(DAY,inv.[invoiceDate],trx.[transDate])
                  ELSE DATEDIFF(DAY,inv.[invoiceDate],GETDATE())
                END AS 'age'
        FROM    [apinv] inv INNER JOIN
                (
                SELECT  DISTINCT
                        app.[apinvID],
                        MIN(app.[amount]) as 'amount',
                        MAX(app.[dateActed]) AS 'dateActed',
                        SUBSTRING(
                        (
                            SELECT  ', ' + usr.[uid] AS [text()]
                            FROM    [sysuser] usr INNER JOIN
                                    [apinva] app2
                            ON      app2.[uid] = usr.[uid]
                            WHERE   app.[apinvID] = app2.[apinvID]
                            ORDER BY app.[apinvID]
                            FOR XML PATH ('')
                        ), 3, 1000) [uid],
                        SUBSTRING(
                        (
                            SELECT  ', ' + usr.[name] AS [text()]
                            FROM    [sysuser] usr INNER JOIN
                                    [apinva] app2
                            ON      app2.[uid] = usr.[uid]
                            WHERE   app.[apinvID] = app2.[apinvID]
                            ORDER BY app.[apinvID]
                            FOR XML PATH ('')
                        ), 3, 1000) [name]
                FROM    [apinva] app
                GROUP BY app.[apinvID]
                ) app
        ON      inv.[apinvID] = app.[apinvID] LEFT OUTER JOIN
                [aptrx] trx
        ON      inv.[apinvID] = trx.[apinvID]
        AND     trx.[transType] = 'C' LEFT OUTER JOIN
                [sysdoc] doc
        ON      inv.[apinvID] = CONVERT(INTEGER,doc.[entityID])
        AND     doc.[entityType] = 'Invoice-AP'
        ) inv
WHERE   inv.[refID] IN (
        '20161971',
        '20100231',
        '20172513',
        '20172625',
        '20162228',
        '20172679',
        '20182946',
        '20141426',
        '20131064',
        '20100324',
        '20110594',
        '20110680',
        '20193354',
        '20172433',
        '20100378',
        '20141564',
        '20172418',
        '20120815'
        )