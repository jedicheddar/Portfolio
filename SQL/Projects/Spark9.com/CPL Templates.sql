DECLARE @state VARCHAR(2) = ''

SELECT  *
FROM    [dbo].[t_ClosingLetter]
WHERE   [StateInit] = CASE WHEN @state = '' THEN [StateInit] ELSE @state END