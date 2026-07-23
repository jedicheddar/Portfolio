USE [COMPASS]

SELECT  b.[batchID],
        d.[entityID]
FROM    [batch] b LEFT OUTER JOIN
        [sysdoc] d
ON      CONVERT(VARCHAR, b.[batchID]) = d.[entityID]
AND     d.[entityType] = 'Batch'
WHERE   d.[entityID] IS NULL
AND     b.[batchID] > 19110000