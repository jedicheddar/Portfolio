DECLARE @attorneyID VARCHAR(30) = '',
        @newStatus VARCHAR(30) = '', -- Active, Inactive, Cancelled, Closed
        @affectChildren BIT = 0,
        @affectParent BIT = 0

DECLARE @found BIT = 0

SELECT  @found = 1
FROM    [Attorneys]
WHERE   [ANAttorneyID] = @attorneyID
AND     [ParentId] IS NULL

IF (@found = 1)
BEGIN
  IF (@affectParent = 1)
    UPDATE  [Attorneys]
    SET     [Status] = @newStatus
    WHERE   [ParentId] IS NULL
    AND     [ANAttorneyID] = @attorneyID
    
  IF (@affectChildren = 1)
    UPDATE  [Attorneys]
    SET     [Status] = @newStatus
    WHERE   [ParentId] IS NOT NULL
    AND     [ANAttorneyID] = @attorneyID

  SELECT  *
  FROM    [Attorneys]
  WHERE   [ANAttorneyID] = @attorneyID
END