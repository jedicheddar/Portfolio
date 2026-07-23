SELECT  b.batchID,
        b.cnt AS 'batchPolicySum',
        bf.cnt AS 'batchformPolicyCount'
FROM    (
        SELECT  batch.batchID,
                batch.periodID,
                SUM(policyCount) AS 'cnt'
        FROM    batch 
        WHERE   batch.stat = 'C'
        GROUP BY batch.batchID,batch.periodID
        ) b INNER JOIN
        (
        SELECT  batch.batchID,
                batch.periodID,
                COUNT(*) AS 'cnt'
        FROM    batchform INNER JOIN 
                batch 
        ON      batch.batchID = batchform.batchID
        WHERE   batchform.formType = 'P'
        AND     batch.stat = 'C'
        GROUP BY batch.batchID,batch.periodID
        ) bf
ON      b.batchID = bf.batchID
AND     b.periodID = bf.periodID
AND     b.cnt <> bf.cnt
ORDER BY b.batchID