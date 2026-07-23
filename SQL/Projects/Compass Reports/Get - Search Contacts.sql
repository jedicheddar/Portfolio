GO

DECLARE	@search VARCHAR(100) = 'Brenda'

EXEC [dbo].[spSearchContacts] @search = @search

GO
