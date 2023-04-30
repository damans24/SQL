/
This is a stored procedure will insert a person's information into tblExercisePerson and tblExercisePersonLanguageFluency tables.
It first checks if the person already exists in the tblPerson table. 
(1) If the person does, we do not proceed--(RETURN to completely quit the procedure). 
(2) If the person does not, we proceed. Eventually we will insert the person info to tblPerson. But, before we do that
	we want to check if the passed in language name with which the person speaks natively exists in the tblLanguage table. 
	(1) If the language does not exist in the tblLanguage table, we do not proceed (RETURN to completely quit the procedure). 
	(2) If the language does exist, we continue with BEGIN TRANSACTION because we have two modification statements in the rest of the procedure 
		(1) we start a transaction to insert the person's information to tblPerson table. 
		(2) Then, 
			(1) we get the PersonID using the @@Identity; 
			(2) we also get the language ID for the passed in language name from the tblLanguage table and 
			    the fluency ID for the fluency level of 'Native Speaker' from tblFluency table
			(3) then we insert a new record into the tblPersonLanguageFluency table.

Show data in the tables:
Select * from tblExercisePerson;
Select * from tblExerciseLanguage;
Select * from tblExercisePersonLanguageFluency
Test script:
--the person exists
DECLARE @resultCode int, @message varchar(250)
--Parameters: @firstName, @lastName, @address, @city, @state, @zip, @languageName, @ResultCode, @message
EXECUTE dbo.uspInsertPersonLanguage 'Richard', 'Byrd', '5697 Mt Baker Hwy', 'Deming',
'WA', '98224', 'English', @resultCode OUTPUT, @message OUTPUT
SELECT @resultCode, @message;

--the language name does not exist
DECLARE @resultCode int, @message varchar(250)
EXECUTE dbo.uspInsertPersonLanguage 'Annie', 'Miller', '234 15th Street', 'Bellingham',
'WA', '98225', 'Dadjo', @resultCode OUTPUT , @message OUTPUT  
SELECT @resultCode, @message;

--everything is fine
DECLARE @resultCode int, @message varchar(250)
EXECUTE dbo.uspInsertPersonLanguage 'Nikki', 'Jones', '123 14th Street', 'Bellingham',
'WA', '98225', 'English', @resultCode OUTPUT , @message OUTPUT 
SELECT @resultCode, @message;


*/

CREATE PROCEDURE dbo.uspInsertPersonLanguage (@firstName varchar(250), @lastName varchar(250), @address varchar(250),
@city varchar(250), @state varchar(250), @ZIP varchar(250), @languageName varchar(250), @resultCode int OUTPUT, @message varchar(250) OUTPUT)
AS
BEGIN
	PRINT '----INPUT PARAMETER VALUES';
	PRINT 'First name:			' + @firstName;
	PRINT 'Last name:			' + @lastName;
	PRINT 'Address:				' + @address;
	PRINT 'City:				' + @city;
	PRINT 'State:				' + @state;
	PRINT 'ZIP:					' + @ZIP;
	PRINT 'Language:			' + @languageName;
	--Check if the person with @firstName, @lastName, @address, @city, and @state exists in the tblExercisePerson table. 
	SELECT * FROM tblExercisePerson WHERE FirstName=@firstName and LastName=@lastName 
	and Address=@address and City=@city and State=@state;
	/**
	If the person exists in the table, set @resultCode=-1 and @message='The person exists in the database'
	then RETURN
	*/
	if @@ROWCOUNT>=1
	begin
		set @resultCode=-1
		set @message='The person exists in the database'
		return
	end

	/**
	Check if @language exists in the tblExerciseLanguage table
	If the langauge does NOT exist in the table, set @resultCode=-2 and @message='The language does not exist in the database'
	then, RETURN
	*/
	select * from tblExerciseLanguage where LanguageName=@languageName
	if @@ROWCOUNT <= 0
	begin
		set @resultCode=-2
		set @message='The language does not exist in the database'
		return 
	end
	--Start a transaction: BEGIN TRANSACTION
	BEGIN TRANSACTION
		/**
		Insert the record into tblExercisePerson. Enclose the insert statement in a BETGIN TRY...BEGIN CATCH block.
		In the BEGIN CATCH block, set @resultCode=-3 and @message='Issue in inserting into tblExercisePerson'.
		Also print the message 'Issue in inserting into tblExercisePerson' in the BEGIN CATCH block. 
		ROLLBACK TRANSACTION in the BEGIN CATCH block and RETURN.
		*/
		begin try
			insert into tblExercisePerson (FirstName, LastName, Address, City, State, ZipCode)
			values (@firstName, @lastName, @address, @city, @state, @ZIP)
			select @@IDENTITY
		end try
		begin catch
			set @resultCode=-3
			set @message='Issue in inserting into tblExercisePerson'
			Print 'Issue in inserting into tblExercisePerson'
			rollback transaction
			return
		end catch
		/**
		Declare a variable @langagueID as int and set the @languageID equal to the LanguageID from 
		tblExerciseLanguage table where the LanguageName matches the @languageName
		*/
		declare @languageID int
		select @languageID=LanguageID from tblExerciseLanguage where LanguageName=@languageName
		/**
		Declare a variable @fluencyID as int and set the @fluencyID equal to the FluencyID from 
		tblExerciseFluency table where the Fluencydescription = 'Native Speaker'
		*/
		declare @fluencyID int
		select @fluencyID=FluencyID from tblExerciseFluency where FLUENCYDESCRIPTION='Native Speaker'
		/**
		Insert the record into tblExercisePersonLanguageFluency. Enclose the insert statement in a BETGIN TRY...BEGIN CATCH block.
		In the BEGIN CATCH block, set @resultCode=-4 and @message='Issue in inserting into tblExercisePersonLanguageFluency'.
		Also print the message 'Issue in inserting into tblExercisePersonLanguageFluency' in the BEGIN CATCH block. 
		ROLLBACK TRANSACTION and RETURN in the BEGIN CATCH block .
		*/
		begin try
			insert into tblExercisePersonLanguageFluency (LanguageID, FluencyID)
			values (@languageID, @fluencyID)
		
		end try
		begin catch
			set @resultCode=-4
			set @message='Issue in inserting into tblExercisePersonLanguageFluency'
			print 'Issue in inserting into tblExercisePersonLanguageFluency'
			rollback transaction
			return
		end catch
		/**
		PRINT a message 'Succeeded!'.
		SET @resultCode=1 and @message='Succeeded'.
		Then, COMMIT the transaction.
		*/
		print 'Succeeded!'
		set @resultCode=1
		set @message='Succeeded'
		commit transaction
END