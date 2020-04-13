/*1. Kroz SQL kod, napraviti bazu podataka koja nosi ime vašeg broja dosijea. 
U postupku kreiranja u obzir uzeti samo DEFAULT postavke.
Unutar svoje baze podataka kreirati tabelu sa sljedećom strukturom:
a) Proizvodi:
I. ProizvodID, automatski generatpr vrijednosti i primarni ključ
II. Sifra, polje za unos 10 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
III. Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
IV. Cijena, polje za unos decimalnog broja (obavezan unos)
b) Skladista
I. SkladisteID, automatski generator vrijednosti i primarni ključ
II. Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
III. Oznaka, polje za unos 10 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
IV. Lokacija, polje za unos 50 UNICODE karaktera (obavezan unos)
c) SkladisteProizvodi
I) Stanje, polje za unos decimalnih brojeva (obavezan unos)
Napomena: Na jednom skladištu može biti uskladišteno više proizvoda, dok isti proizvod može biti
uskladišten na više različitih skladišta. 
Onemogućiti da se isti proizvod na skladištu može pojaviti više puta.
10 bodova
First Through SQL code, create a database that bears the name of your file number.
Only DEFAULT settings should be considered in the creation process.
Create a spreadsheet with the following structure inside your database:
a) Products:
I. ProductID, automatic value generator and primary key
II. Code, input field 10 UNICODE characters (mandatory input), unique value
III. Name, input field 50 UNICODE characters (required)
IV. Price, decimal field (required)
b) Warehouse
I. WarehouseID, automatic value generator and primary key
II. Name, input field 50 UNICODE characters (required)
III. Label, 10 UNICODE character input field (required), unique value
IV. Location, 50 UNICODE character input field (required)
c) WarehouseProducts
I) Balance, decimal input field (required)
Note: Multiple products can be stored in one warehouse while the same product can be stored
stored in several different warehouses.
Prevent the same product from appearing in stock more than once.
10 points*/

create database name
go

use name
go

/*a)*/
create table Proizvodi(
	ProizvodID int constraint PK_Proizvodi primary key(ProizvodID) identity(1,1),
	Sifra nvarchar(10) NOT null constraint UQ_Sifra unique, 
	Naziv nvarchar(50) NOT null,
	Cijena decimal(18, 2) NOT null
)
/*b)*/
create table Skladista(
	SkladisteID int constraint PK_Skladiste primary key(SkladisteID) identity(1,1),
	Naziv nvarchar(50) NOT null,
	Oznaka nvarchar(10) NOT null constraint UQ_Oznaka unique, 
	Lokacija nvarchar(50) NOT null
)
/*c)*/
create table SkladisteProizvodi(
	ProizvodID int NOT null,
	SkladisteID int NOT null,
	constraint PK_SkladisteProizvodi primary key(ProizvodID, SkladisteID),
	constraint FK_SkladisteProizvodi_Skladiste foreign key(SkladisteID)
	references Skladista (SkladisteID),
	constraint FK_SkladisteProizvodi_Proizvodi foreign key(ProizvodID)
	references Proizvodi (ProizvodID),
	Stanje decimal(18,2) NOT null
)

/*2. Popunjavanje tabela podacima
a) Putem insert komande u tabelu Skladista dodati minimalno 3 skladišta.
b) Koristeći bazu podataka AdventureWorks2014, preko insert i select komande importovati
10 najprodavanijih bicikala (kategorija proizvoda 'Bikes' i to sljedeće kolone:
I. Broj proizvoda (ProductNumber) - > Sifra,
II. Naziv bicikla (Name) -> Naziv,
III. Cijena po komadu (ListPrice) -> Cijena,
c) Putem insert i select komandi u tabelu SkladisteProizvodi za sva dodana skladista
importovati sve proizvode tako da stanje bude 100
-Filling in spreadsheets with data
a) Add a minimum of 3 warehouses to the Warehouse table via the insert command.
b) Using the AdventureWorks2014 database, import via insert and select
Top 10 Bikes (Product Category 'Bikes' and the following columns:
I. Product Number (ProductNumber) -> Code,
II. Bicycle Name (Name) -> Name,
III. Price per Piece (ListPrice) -> Price,
c) Using the insert and select commands in the WarehouseProducts table for all added warehouses
import all products so that the balance is 100*/

/*a)*/
insert into Skladista (Naziv, Oznaka, Lokacija)
values ('Skladiste1', 'Skl1', 'Konjic')

insert into Skladista (Naziv, Oznaka, Lokacija)
values ('Skladiste2', 'Skl2', 'Mostar')

insert into Skladista (Naziv, Oznaka, Lokacija)
values ('Skladiste3', 'Skl3', 'Sarajevo')

/*b)*/
use AdventureWorks2014 
go

insert into name.dbo.Proizvodi(Sifra, Naziv, Cijena)
select top 10 P.ProductNumber, P.Name, P.ListPrice
from Production.Product as P 
	inner join Production.ProductSubcategory as PSC
		on PSC.ProductSubcategoryID = P.ProductSubcategoryID
	inner join Production.ProductCategory as PC
		on PC.ProductCategoryID = PSC.ProductCategoryID
	inner join Sales.SalesOrderDetail as SOD 
		on SOD.ProductID = P.ProductID
where PC.ProductCategoryID = 1
group by P.ProductNumber, P.Name, P.ListPrice
order by sum(SOD.OrderQty) desc
go

/*c)*/

insert into BrojIndeksa.dbo.Proizvodi(Sifra, Naziv, Cijena)
select top 100 P.ProductNumber, P.Name, P.ListPrice
from Production.Product P
go

use name
go

insert into SkladisteProizvodi(ProizvodID, SkladisteID, Stanje)
select top 100 ProizvodID, 1, 100
from Proizvodi
go

insert into SkladisteProizvodi(ProizvodID, SkladisteID, Stanje)
select top 100 ProizvodID, 2, 100
from Proizvodi
go

insert into SkladisteProizvodi(ProizvodID, SkladisteID, Stanje)
select top 100 ProizvodID, 3, 100
from Proizvodi
go

/*3. Kreirati uskladištenu proceduru koja će vršiti povećanje stanja skladišta 
za određeni proizvod na odabranom skladištu. Provjeriti ispravnost procedure
-Create a stored procedure that will increase the state of storage
for a specific product in the selected warehouse. Check the correctness of the procedure
*/

create procedure p_povecanjeStanja (
	@ProizvodId int ,
	@SkladisteId int
)
as 
	begin
		update SkladisteProizvodi
		set Stanje = Stanje + 1
		where ProizvodID = @ProizvodId and SkladisteID = @SkladisteId
	end
go

exec p_povecanjeStanja @ProizvodId = 1, @SkladisteId = 3 

select * from SkladisteProizvodi

/*4. Kreiranje indeksa u bazi podataka nad tabelama
a) Non-clustered indeks nad tabelom Proizvodi. Potrebno je indeksirati Sifru i Naziv. Također,
potrebno je uključiti kolonu Cijena
b) Napisati proizvoljni upit nad tabelom Proizvodi koji u potpunosti iskorištava indeks iz
prethodnog koraka
c) Uradite disable indeksa iz koraka a)
-Creating indexes in database over tables
a) Non-clustered index over the Products table. It is necessary to index the Code and Name. Also,
the Price column must be included
b) Write an arbitrary query over the Products table that takes full advantage of the index from
of the previous step
c) Do the disable indexes from step a)
*/

/*a)*/

create nonclustered index IX_ProizvodiSNC
on Proizvodi (Sifra, Naziv)
include (Cijena)

/*b)*/

select *
from Proizvodi

/*c)*/
alter index IX_ProizvodiSNC on Proizvodi disable

/*5. Kreirati view sa sljedećom definicijom. 
Objekat treba da prikazuje sifru, naziv i cijenu proizvoda,
oznaku, naziv i lokaciju skladišta, te stanje na skladištu.
-Create a view with the following definition.
The facility should show the product code, name and price,
the label, name and location of the warehouse, and the condition of the warehouse.*/

create view v_pregledSkladista 
as
	select P.Naziv [NazivProizvoda], P.Cijena, P.Sifra, 
			S.Lokacija, S.Naziv [NazivSkladista], S.Oznaka, 
			SP.Stanje
	from Proizvodi P inner join SkladisteProizvodi SP
		on P.ProizvodID = SP.ProizvodID
	inner join Skladista S
		on SP.SkladisteID = S.SkladisteID
go

select * from v_pregledSkladista
go

/*6. Kreirati uskladištenu proceduru koja će na osnovu unesene šifre proizvoda 
prikazati ukupno stanje zaliha na svim skladištima. 
U rezultatu prikazati sifru, naziv i cijenu proizvoda te ukupno stanje zaliha.
U proceduri koristiti prethodno kreirani view. Provjeriti ispravnost kreirane procedure.
-Create a stored procedure based on the product code entered
display the total inventory status of all warehouses.
In the result, show the code, name and price of the product and the total stock status.
Use the previously created view in the procedure. Check the correctness of the created procedure. */

create procedure p_prikazZaliha(
	@SifraProzivoda nvarchar(10)
)
as
	begin
		select V.Sifra, V.NazivProizvoda, V.Cijena, sum(Stanje) [Stanje]
		from v_pregledSkladista as V
		where V.Sifra = @SifraProzivoda
		group by V.Sifra, V.NazivProizvoda, V.Cijena
	end
go

select *
from v_pregledSkladista /* show Sifra to find and to insert in exec*/

exec p_prikazZaliha 'BK-M68B-42'
go

/*7. Kreirati uskladištenu proceduru koja će vršiti upis novih proizvoda, 
te kao stanje zaliha za uneseni proizvod postaviti na 0 za sva skladišta. 
Provjeriti ispravnost kreirane procedure.
-Create a stored procedure that will enroll new products,
and set the stock status for the product entered to 0 for all warehouses.
Check the correctness of the created procedure.*/

create procedure p_NewProizvod(
	@Sifra nvarchar(10),
	@NazivProizvoda nvarchar(50),
	@Cijena decimal(18, 2)
)
as
	begin
		insert into Proizvodi(Sifra, Naziv, Cijena)
		values(@Sifra, @NazivProizvoda, @Cijena)

		insert into SkladisteProizvodi(SkladisteID, ProizvodID, Stanje)
		select 1, ProizvodID, 0
		from Proizvodi
		where @Sifra = Sifra

		insert into SkladisteProizvodi(SkladisteID, ProizvodID, Stanje)
		select 2, ProizvodID, 0
		from Proizvodi
		where @Sifra = Sifra

		insert into SkladisteProizvodi(SkladisteID, ProizvodID, Stanje)
		select 3, ProizvodID, 0
		from Proizvodi
		where @Sifra = Sifra
	end
go

exec p_NewProizvod 'Prvi1', 'Proizvod1', 1

select * from Proizvodi

select * from SkladisteProizvodi

/*8. Kreirati uskladištenu proceduru koja će za unesenu šifru proizvoda vršiti brisanje proizvoda
uključujući stanje na svim skladištima. Provjeriti ispravnost procedure.
-Create a stored procedure that will delete the product for the entered product code
including the condition at all warehouses. Check the correctness of the procedure.
*/
	
create procedure p_Delete(
	@SifraProizvoda nvarchar(10)
)
as
	begin
		delete from SkladisteProizvodi
		where ProizvodID = (select ProizvodID
					from Proizvodi
					where Sifra = @SifraProizvoda)
		delete from Proizvodi
		where Sifra = @SifraProizvoda
	end
go

exec p_Delete 'Prvi1'
go

/*9. Kreirati uskladištenu proceduru koja će za unesenu šifru proizvoda, oznaku skladišta
ili lokaciju skladišta vršiti pretragu prethodno kreiranim view-om (zadatak 5).
Procedura obavezno treba da vraća rezultate bez obrzira da li su vrijednosti 
parametara postavljene. 
Testirati ispravnost procedure u sljedećim situacijama:
a) Nije postavljena vrijednost niti jednom parametru (vraća sve zapise)
b) Postavljena je vrijednost parametra šifra proizvoda, a ostala dva parametra nisu
c) Postavljene su vrijednosti parametra šifra proizvoda i oznaka skladišta, a lokacija
nije
d) Postavljene su vrijednosti parametara šifre proizvoda i lokacije, a oznaka skladišta
nije
e) Postavljene su vrijednosti sva tri parametra
-Create a stored procedure that, for the entered product code, is the storage tag
or search the location of the repository with a previously created view (Task 5).
The procedure should return results without considering whether they are values
parameters set.
Test the correctness of the procedure in the following situations:
a) No parameter was set (returns all records)
b) The product code parameter value is set and the other two parameters are not
c) The parameter values of the product code and the warehouse code and the location are set
is not
d) Product and location code parameter values are set and the storage tag is set
is not
e) Values of all three parameters are set*/

create procedure p_ViewPretraga(
	@Sifra nvarchar(10) = null,
	@Oznaka nvarchar(10) = null,
	@Lokacija nvarchar(50) = null
)
as
	begin
		select *
		from v_pregledSkladista V
		where (@Sifra = V.Sifra or @Oznaka = V.Oznaka 
			or @Lokacija = V.Lokacija) or 
			(@Sifra is null
			 and @Oznaka is null 
			 and @Lokacija is null)
	end
go
/*a)*/
exec p_ViewPretraga
/*b)*/
exec p_ViewPretraga @Sifra = 'BK-M68B-42'
/*c)*/
exec p_ViewPretraga @Sifra = 'BK-M68B-42', @Oznaka = 'Skl1'
/*d)*/
exec p_ViewPretraga @Sifra = 'BK-M68B-42', @Lokacija = 'Mostar'
/*e)*/
exec p_ViewPretraga @Sifra = 'BK-M68B-42', @Oznaka = 'Skl1', @Lokacija = 'Mostar'

/*10. Napraviti full i diferencijalni backup baze podataka na default lokaciju servera:
C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup ili proizvoljno
-To make a full and differential backup of the database to the default server location:
C: \ Program Files \ Microsoft SQL Server \ MSSQL12.MSSQLSERVER \ MSSQL \ Backup or arbitrary
*/


backup database name
to disk = 'C:\Program Files\Microsoft SQL Server\Backup\name.bak'

backup database name
to disk = 'C:\Program Files\Microsoft SQL Server\Backup\nameDiff.bak'
with differential
