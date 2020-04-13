/*1. create database*/
create database parcijalni
go

use parcijalni
go
/*
2. U svoju baze podataka putem Import/Export alata prebaciti sljedeće tabele sa podacima: 
CreditCard, PersonCreditCard i Person koje se nalaze u AdventureWorks2014 bazi podataka.
Transfer the following datasheets to your database using the Import / Export tool:
CreditCard, PersonCreditCard and Person located in the AdventureWorks2014 database.
*/
/*
3. Kreiranje indeksa u bazi podataka nada tabelama koje ste importovali u zadatku broj 2:
a) Non-clustered indeks nad tabelom Person. Potrebno je indeksirati Lastname i FirstName. Također,
potrebno je uključiti kolonu Title.
b) Napisati proizvoljni upit nad tabelom Person koji u potpunosti
iskorištava indeks iz prethodnog koraka 
c) Uraditi disable indeksa iz koraka a)
d) Clustered indeks nad tabelom CreditCard i kolonom CreditCardID
e) Non-clustered indeks nad tabelom CreditCard i kolonom CardNumber. 
Također, potrebno je uključiti
kolone ExpMonth i ExpYear.
Creating an index in the database above the tables you imported in Task # 2:
a) Non-clustered index over the Person table. Lastname and FirstName must be indexed. Also,
the Title column must be included.
b) Write an arbitrary query over a Person table that completely
exploits the index from the previous step
c) Do the disable index from step a)
d) Clustered index over the CreditCard table and the CreditCardID column
e) Non-clustered index over CreditCard table and CardNumber column.
Also, it needs to be included
the ExpMonth and ExpYear columns. */
/*a*/
create nonclustered index IX_PersonLFT
on Person.Person (LastName, FirstName)
include (Title)
go
/*b*/
select FirstName, LastName, Title
from Person.Person
go
/*c*/
alter index IX_PersonLFT on Person.Person
disable
go
/*d*/
create nonclustered index IX_CreditCardCN
on Sales.CreditCard (CreditCardID)
go
/*e*/
create nonclustered index IX_CreditCardCNEMEY
on Sales.CreditCard (CardNumber)
include (ExpMonth, ExpYear)
go
/*
4. Kreirati view sa sljedećom definicijom.
Objekat treba da prikazuje: Prezime, ime, broj kartice i tip kartice, ali
samo onim osobama koje imaju karticu tipa Vista i nemaju titulu
4. Create a view with the following definition.
The object should show: Last name, first name, card number and card type, but
only to those who have a Vista card and do not have a title
*/
create view v_vistaKartica
as
select P.LastName, P.FirstName, CC.CardNumber, CC.CardType
	from Person.Person P
	inner join Sales.PersonCreditCard PCC
	on P.BusinessEntityID = PCC.BusinessEntityID
	inner join Sales.CreditCard CC
	on PCC.CreditCardID = CC.CreditCardID
	where CC.CardType = 'Vista' and P.Title is null
go

select * from v_vistaKartica
go
/*
5. Kreirati uskladištenu proceduru koja vrši modifikaciju
prezimena osobe za uneseni BusinessEntityID.
Nakon toga izvršiti proceduru i jednostavnom SELECT komandom provjeriti rezultat
5. Create a stored procedure that performs the modification
the person's last name for the BusinessEntityID you entered.
Then perform the procedure and check the result with a simple SELECT command
*/
create procedure p_LastNameOnBusinessEntityID(
	@id int,
	@LastName nvarchar(50)
)
as
	begin
		update Person.Person
		set LastName = @LastName
		where @id = BusinessEntityID
	end
go

select * from Person.Person
where BusinessEntityID = 1

exec p_LastNameOnBusinessEntityID 1, 'Kezo'

select * from Person.Person
where BusinessEntityID = 1
/*
6. Napraviti full i diferencijalni backup baze podataka na default lokaciju servera:
C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup ili proizvoljno 
Make full and differential backup of the database to the default server location:
C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup or arbitrary
*/

backup database parcijalni
to disk = 'C:\Program Files\Microsoft SQL Server\Backup\parcBak.bak'
go

backup database parcijalni
to disk = 'C:\Program Files\Microsoft SQL Server\Backup\parcBak_diff.bak'
with differential
go

/*
7. Mapirati login sa SQL Server-a pod imenom „student“ u svoju bazu kao 
korisnika pod svojim imenom
-Map login from SQL Server named "student" to your database as
users under your own name
*/

create login student
with password  = 'sif3a'
go

create user Nu for login student
go
/*
8. Kreirati uskladištenu proceduru koja će za uneseno prezime, ime ili broj kartice 
vršiti pretragu nad prethodno kreiranim view-om (zadatak 4). 
Procedura obavezno treba da vraća rezultate bez obzira da li su vrijednosti
parametara postavljene. 
Testirati ispravnost procedure u sljedećim situacijama:
a) Nije postavljena vrijednost niti jednom parametru (vraća sve zapise)
b) Postavljena je vrijednost parametra prezime, a ostala dva parametra nisu (pretraga po prezimenu)
c) Postavljene su vrijednosti parametara prezime i ime, a broj kartice nije 
(pretraga po prezimenu i imenu)
d) Postavljene su vrijednosti sva tri parametra (pretraga po svim parametrima)
Također, procedura treba da pretragu prezimena i imena vrši parcijalno (počinje sa).
-Create a stored procedure that will enter the last name, first name or card number
search the previously created view (Task 4).
The procedure should return results regardless of whether they are values
parameters set.
Test the correctness of the procedure in the following situations:
a) No parameter was set (returns all records)
b) The last name parameter value is set and the other two parameters are not (last name search)
c) The surname and first name parameter values are set and the card number is not
(search by name and surname)
d) Values of all three parameters are set (search by all parameters)
Also, the procedure should search for the last name and first name partially (starting with).
*/
create procedure p_ViewLnFnCc(
	@LastName nvarchar(50) = NULL,
	@FirstName nvarchar(50) = NULL,
	@CreditCard nvarchar(25) = NULL
)
as
	begin
		select *
		from v_vistaKartica
		where (@LastName is null
				and @FirstName is null
				and @CreditCard is null) 
				or
				(@LastName = LastName or LastName like @LastName + '%') or
				(@FirstName = FirstName or FirstName like @FirstName + '%') or
				(@CreditCard = CardNumber)
	end
go
/*
9. Kreirati uskladištenu proceduru koje će za uneseni broj kartice vršiti brisanje 
kreditne kartice (CreditCard).
Također, u istoj proceduri (u okviru jedne transakcije) 
prethodno obrisati sve zapise o vlasništvu kartice
(PersonCreditCard). Obavezno testirati ispravnost kreirane procedure.
Create a stored procedure that will erase the card number entered
credit cards (CreditCard).
Also, in the same procedure (within one transaction)
delete all card ownership records
(PersonCreditCard). Be sure to test the correctness of the created procedure.
*/

create procedure p_Delete(
	@CardNumber nvarchar(25)
)
as
	begin
		delete from Sales.PersonCreditCard
		from Sales.PersonCreditCard PCC
		inner join Sales.CreditCard CC
			on PCC.CreditCardID = CC.CreditCardID
		where CC.CardNumber = @CardNumber

		delete from Sales.CreditCard
		where @CardNumber = CardNumber
	end
go

exec p_Delete '17038'

/*
10. Kreirati trigger koji će spriječiti brisanje zapisa u tabeli PersonCreditCard.
Testirati ispravnost kreiranog triggera
Create a trigger that will prevent the records in the PersonCreditCard table from being deleted.
Test the accuracy of the created trigger
*/
create trigger tr_PerhibitedDelete on Sales.PersonCreditCard
instead of delete
as
	begin
		print('Zabranjeno brisanje iz ove tabele.')
		rollback
	end
go

delete from Sales.PersonCreditCard