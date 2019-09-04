create database grup2
go
use grup2
go
create table urun 
(
	id int identity,
	urun_kodu varchar(20),
	urun_adi varchar(20)
)
select * from urun
create trigger urun_ko_ekle on urun after insert
as 
begin
	declare @degeral int, @sorgu varchar(30)
	set @degeral=(select max(id) from urun)
	set @sorgu='TR0304'+convert(varchar(20), @degeral)
	update urun set urun_kodu=@sorgu where id=@degeral
end

insert into urun(urun_adi) values ('�ikolata')
insert into urun(urun_adi) values ('Leblebi')

--�r�n tablosunda silme i�lemi yerine tablodaki veriyi silmeye
--�al��an kullan�c� bilgileri ve tarihi
--log tablosunda tutan tr�gger
create table log_tablosu
(
	log_id int identity,
	aciklama varchar(300)
)
select * from log_tablosu
create trigger log_tut on urun instead of delete 
as
begin
	declare @urun_kod varchar(30),@urun_adi varchar(30)
	select @urun_kod=urun_kodu,@urun_adi=urun_adi from deleted
	insert into log_tablosu(aciklama) values (@urun_kod+@urun_adi+'kayd�'+SUSER_SNAME()+'taraf�ndan'+convert(varchar(max),getdate())+'tarihinde silinmek istendi')
end

delete from urun where urun_adi='�ikolata'

Select * from urun
select * from log_tablosu

--urun tablosunda silinen �r�n siparis tablosunda mevcut ise silme i�lemi geri al�ns�n
create table siparis
(
	siparis_id int identity,
	urun_kod varchar(30),
	musteri_no int
)

insert into siparis(urun_kod,musteri_no) values('TR03041',32)
delete  from siparis  
select * from urun
select * from siparis
disable trigger log_tut on urun 
--urun tablosunda silinen �r�n siparis tablosunda mevcut ise silme i�lemi geri al�ns�n
create trigger silineni_geri_al on urun after delete
as
begin
	declare @urun_kod varchar(30)
	select @urun_kod=urun_kodu from deleted
	if exists (select * from siparis where urun_kod=@urun_kod)
	begin
		print 'Silinmez'
		rollback tran
		end
end
delete from urun where id=1
select * from urun