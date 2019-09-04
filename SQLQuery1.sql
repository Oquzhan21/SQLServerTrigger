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

insert into urun(urun_adi) values ('Çikolata')
insert into urun(urun_adi) values ('Leblebi')

--Ürün tablosunda silme iþlemi yerine tablodaki veriyi silmeye
--çalýþan kullanýcý bilgileri ve tarihi
--log tablosunda tutan trýgger
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
	insert into log_tablosu(aciklama) values (@urun_kod+@urun_adi+'kaydý'+SUSER_SNAME()+'tarafýndan'+convert(varchar(max),getdate())+'tarihinde silinmek istendi')
end

delete from urun where urun_adi='Çikolata'

Select * from urun
select * from log_tablosu

--urun tablosunda silinen ürün siparis tablosunda mevcut ise silme iþlemi geri alýnsýn
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
--urun tablosunda silinen ürün siparis tablosunda mevcut ise silme iþlemi geri alýnsýn
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