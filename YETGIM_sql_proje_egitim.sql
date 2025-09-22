      ---ÇALIŞMALARIN SONUCUNDA SON PROJE SORGULARIM---

--(WORD-1)Çalışanların isim,soy isim,maaş,meslek ve %30 zamlı maaşlarını veren sorgu...
select e.first_name AS isim,
    e.last_name AS soy_isim,
    e.job_id AS meslek,
    e.salary AS mevcut_maas,
    (e.salary * 1.3) AS zamli_maas
FROM hr.employees e;

--(WORD-2)Çalışanların isim,soyisim,ülke,adres ve departmanlarını veren sorgu...
select e.first_name as isim,
e.last_name as soy_isim,
c.country_name as ulke,
l.street_address as adres,
e.job_id as departman
FROM hr.EMPLOYEES e
left join HR.DEPARTMENTS d on e.DEPARTMENT_ID = d.DEPARTMENT_ID
left join hr.LOCATIONS l on d.LOCATION_ID = l.LOCATION_ID 
LEFT JOIN hr.countries c   ON l.country_id = c.country_id;

--(WORD-3)(CTE Versiyon)Çalışanların isim,soyisim,ülke,adres ve departmanlarını veren sorgu...
WITH dept_bolge AS (
 select d.department_id,
        l.street_address,
        c.country_name
 from hr.departments d
 left JOIN hr.locations l 
    ON d.location_id = l.location_id
 left join hr.countries c 
    ON l.country_id = c.country_id
)
select e.first_name AS isim,
    e.last_name AS soy_isim,
    cte.country_name AS ulke,
    cte.street_address AS adres,
    e.job_id AS departman
from hr.employees e
left join dept_bolge cte
    ON e.department_id = cte.department_id;


--(WORD-4)Çalışanın isim, soy isim, çalıştığı yıl sayısı, maaşı ve maaşın çalıştığı yıla oranını veren sorgu...
select e.first_name,
    e.last_name,
    TRUNC(MONTHS_BETWEEN(SYSDATE, e.hire_date) / 12) AS calistigi_yil,
    e.salary,
    round(e.salary / NULLIF(TRUNC(MONTHS_BETWEEN(SYSDATE, e.hire_date) / 12), 0), 2) AS maas_yil_orani
from hr.employees e;

---
-- (WORD-5)Çalışanın isim, soy isim, maas, mesleki işe giriş, çalıştığı yıl, toplam ve ortalama kazancını veren sorgu...
select e.first_name as isim,
    e.last_name as soy_isim,
    e.salary as maas,
    d.department_name as meslegi,
    e.hire_date as ise_giris,
    TRUNC(MONTHS_BETWEEN(SYSDATE, e.hire_date) / 12) AS calistigi_yil,
    (e.salary * TRUNC(MONTHS_BETWEEN(SYSDATE, e.hire_date) / 12)) AS toplam_kazanc,
   ort_maas.ortalama_maas
from hr.employees e
left join hr.departments d 
    ON e.department_id = d.department_id
left join (
    select d.department_id,  ----- Departmanların ortalama maaşını bulan alt sorgu...
     ROUND(AVG(e.salary), 2) AS ortalama_maas
    from hr.employees e
    left join hr.departments d 
     ON e.department_id = d.department_id
    group by d.department_id
) ort_maas
    ON e.department_id = ort_maas.department_id
order by 
    ort_maas.ortalama_maas DESC NULLS LAST, -- nulları sona attık
    d.department_name NULLS LAST,             
    toplam_kazanc DESC NULLS LAST;            


-- (WORD-6)(CTE versiyonu)Çalışanın isim, soy isim, maas, mesleki işe giriş, çalıştığı yıl, toplam ve ortalama kazancını veren sorgu...
WITH ort_maas AS (   -- Departmanların ortalama maaşlarını hesaplayan CTE...
 select d.department_id,
    ROUND(AVG(e.salary), 2) AS ortalama_maas
 from hr.employees e
 left join hr.departments d 
    ON e.department_id = d.department_id
group by d.department_id
)
select 
    e.first_name as isim,
    e.last_name as soy_isim,
    e.salary as maas,
    d.department_name as meslegi,
    e.hire_date as ise_Giris,
    TRUNC(MONTHS_BETWEEN(SYSDATE, e.hire_date) / 12) AS calistigi_yil,
    (e.salary * TRUNC(MONTHS_BETWEEN(SYSDATE, e.hire_date) / 12)) AS toplam_kazanc,
    ort_maas.ortalama_maas
from hr.employees e
left join hr.departments d 
    ON e.department_id = d.department_id
left join ort_maas
    ON e.department_id = ort_maas.department_id
order by
    ort_maas.ortalama_maas DESC NULLS LAST, -- nulları sona attık
    d.department_name NULLS LAST,
    toplam_kazanc DESC NULLS LAST;


--(WORD-7)Calisan ismi, mesleği, maasi, departmanı, ortalama maaşi ve performansını gösteren,departman ve maaşa göre sıralayan CTE srogu...
WITH dept_avg AS (   
 select department_id,
  ROUND(AVG(salary),2) AS ortalama_maas
 from hr.employees
GROUP BY department_id
)

select e.first_name || ' ' || e.last_name AS calisan,  --Yüksek perf. çalışanlar
 e.job_id AS meslek,
 e.salary AS maas,
 d.department_name AS departman,
 da.ortalama_maas,
    'ÜSTÜN PERFORMANS' AS kategori
from hr.employees e
left join hr.departments d 
    ON e.department_id = d.department_id
left join dept_avg da 
    ON e.department_id = da.department_id
where e.salary > da.ortalama_maas

UNION ALL

select e.first_name || ' ' || e.last_name AS calisan, -- Düşük perf.
 e.job_id AS meslek,
 e.salary AS maas,
 d.department_name AS departman,
 da.ortalama_maas,
    'DÜŞÜK PERFORMANS' AS kategori
from hr.employees e
left join hr.departments d 
    ON e.department_id = d.department_id
left join dept_avg da 
    ON e.department_id = da.department_id
where e.salary <= da.ortalama_maas
order BY departman, maas DESC;

--(WORD-8)Çalışanların hiyerarşik levelini veren sorgu...
select employee_id, first_name as Calisan, manager_id, LEVEL
from hr.EMPLOYEES
start with manager_id is null
connect by PRIOR employee_id = manager_id
order by level desc;

--(WORD-9)Çalişan önceki maaşı ile güncel maaşı arası farkı çeken sorgu --LAG ile çektik.
select first_name as calisan,
 employee_id,
 salary as maas,
 LAG(salary) OVER (PARTITION BY department_id ORDER BY hire_date) AS onceki_maas,
 salary - LAG(salary) OVER (PARTITION BY department_id ORDER BY hire_date) AS maas_farki
from hr.employees
order BY department_id, hire_date;

--(WORD-10)Çalışan ağacı sorgusu PATH, ceodan başlar, döngüye karşı koruma var.
select employee_id,
 first_name,
 LEVEL AS seviye,
 SYS_CONNECT_BY_PATH(first_name, ' > ') AS path,
 CONNECT_BY_ISLEAF AS yaprak_mi,
 CONNECT_BY_ISCYCLE AS dongu_var_mi
from hr.employees
START WITH manager_id IS NULL          
CONNECT BY NOCYCLE PRIOR employee_id = manager_id;  



-----   KURSTA ÖĞRENDİKLERİM İLE KENDİ SORGULARIM  ----


select *    --tüm sütunları çektik
from hr.EMPLOYEES;

select first_name, last_name
from hr.EMPLOYEES;

--Komutların işlenme sırası:
--Önce 'FROM' çalışır. Gittiğimiz tablo
--Sonra filtreleme çalışır 'WHERE'
--aggregation varsa onu yapar 'GROUP BY'
--'HAVING' group by dan sonra çalışan kısıtlama
--'SELECT' artık ne kaldıysa getir
--'DISTINCT' deduplication yapar
--son olarak sıralama yapar 'ORDER BY'
--bazende enn en son filtreleme 'LIMIT'
--
select distinct department_id  ---distinct ile her farklı departman id sini çektik. deduplicate yaptı
from hr.EMPLOYEES;

--
select first_name, salary
from hr.EMPLOYEES
where salary > 5000 and salary < 10000 -- where ile maaş aralığını filtreledik. where = filtre elemanı
where salary between 5000 and 10000; -- bu şekilde between ilede yazabilirdik
-- Karşılaştırma opt. : =,!=,<,>,<=,>=

select first_name, job_id
from hr.EMPLOYEES
where job_id = 'IT_PROG'; --- job idsi IT_PROG olanları çektik

--Mantıksal opt. : 
--And: İki koşulda aynı anda doğruysa
--Or: Koşullardan biri doğruysa
--Not: Olumsuz
select first_name, salary
from hr.EMPLOYEES
where salary > 8000 and department_id = 90;
 -- iki koşul aynı anda 

select first_name, salary, DEPARTMENT_ID
from hr.EMPLOYEES
where salary > 10000 or department_id = 90; -- iki koşuldan biri


select first_name, salary, DEPARTMENT_ID
from hr.EMPLOYEES
where Not salary < 11000 and department_id != 90; -- dümdüz NOT
--

select first_name, department_id
from hr.EMPLOYEES
where department_id IN (10,20,30);  --- IN : içinde belirtilen değerler olanları çekti

--

select first_name
from hr.EMPLOYEES
where first_name LIKE 'A%'; --- LIKE ile ismi A ile başlayanları çektik. Büyük küçük harf duyarlı

select first_name
from hr.EMPLOYEES
where first_name LIKE '_a%'; -- "_" tek karakter atlıyor. Örneğin ikinci harfi a olanları çektik

---

select FIRST_NAME as isim, 
last_name as soyisim, 
department_id as departman, 
salary as maas
from hr.EMPLOYEES
where salary > 1 
order by salary desc;   -- kolonları isimlendirdik ve çalışanları maaşlarına göre sıraladık.
--dipnot: ";" sorgunun bittiğini söyler. bundan sonrakiler ayrı sorgudur

--Departmanı 50 veya 80 olan ve ismi "S" harfiyle başlayan çalışanların isim,
-- departman ve işe giriş tarihini (hire_date) listele.

select first_name,last_name,hire_date
from hr.EMPLOYEES
where first_name LIKE 'S%';

--- Karakter Fonksiyonları

select UPPER(First_name) as buyuk_isim, -- UPPER ile çıktıyıbüyük harf yaptık 
LOWER(LAST_NAME) --- LOWER ile çıktıyı küçük harf yaptık
from hr.EMPLOYEES;

--

select INITCAP(first_name) as Ozel_isim -- INITCAP: ilk hatfi büyütür
from hr.employees;

--

select SUBSTR(first_name, 2, 3) as ilk_uc_harf -- "2, 3" diyerek 2. karakterden sonraki 3 harfi yazdırdık.
from hr.employees

--
select first_name, LENGTH(first_name) as uzunluk -- LENGTH ile ismin string uzunluğunu yazdırdık
from hr.employees

---Sayısal Fonksiyonlar
select round(235.532, 2) as yuvarlanmis_Sayi -- parantez içini yuvarladı
 
select first_name as isim, round(salary, -1) as yuvarlanmis_maas -- maas kolonundaki verileri yuvarladı
from hr.EMPLOYEES; -- (..., n) buradaki n pozitifse virgülden sonra kaç ondalık, negatifse virgülden geriye kaç ondalık yuvarlanacağını belirler

--

select TRUNC(314.643, 0) as kesilmis_Sayi -- Trunc'ta (..., n) n virgülden sonra veya önce nereden kesileceğini belirler
-- 0 virgüldür ama -1,-2 vb kesme işlemlerinde ondalık satırı silmez sıfıra yuvarlar

select first_name as isim,salary as maas,
TRUNC(salary, -2) as ondalik_atilmis
from hr.employees;

--
select MOD(10 ,4) as kalan; -- MOD: klasik mod alma işlemi, bölümden kalanı verir

-- Çalışanın maaşının, isminin harf sayısına bölümünden kalanı yazan garip bir sorgu :D
select first_name as isim, last_name as soy_isim, 
salary as maas,
MOD(salary, LENGTH(first_name)) as maas_uzn_kalan
from hr.employees;

-- Tarih Fonksiyonları

select SYSDATE; --bugünün sistem tarihi

--
select add_months(SYSDATE, 6) as alti_ay_sonra; -- sistem tarihine 6 ay ekledi

-- Çalışanların ne kadar süredir çalıştığını ay ve yıl bazında çeken sorgu
select first_name, TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date), 0) as kac_aydir,
TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date) / 12) as kac_yildir
from hr.employees;  

select next_Day(SYSDATE, 'MONDAY') as sonraki_pazartesi--sonraki pazartesi
select last_Day(SYSDATE) -- ayın son günü- bilgi bilgidir

-- Null FOnksiyonları
--NVL
select first_name, NVL(COMMISSION_PCT, 0) as komisyon --- null olan komisyonları 0 olarak değiştirdik
from hr.EMPLOYEES;
--NVL2 -- Null olup olmadığına göre iki farklı değer yazdırabiliyoruz çıktıya.
select first_name, NVL2(COMMISSION_PCT, 'Var', 'Yok') as komisyon
from hr.EMPLOYEES;
--COALESCE
select first_name, COALESCE(COMMISSION_PCT, salary, 0)
from hr.EMPLOYEES;


--Çalışanların işe giriş tarihinden bugüne kadar 
--kaç ay geçtiğini hesapla ve maaşı NULL olan varsa 0 yaz
--Çalışanlar çalışma sürelerine göre yüksekten düşüğe sıralansın.

select first_name as isim,
last_name as soy_isim,
TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date), 0) as kac_Ay_Cls,
NVL(salary, 0) as maas,
salary * 12 as yillik_maas, -- TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date) / 12) önce böyle yaptım sonra güldüm
salary * TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date), 0) as toplam_maas
from hr.EMPLOYEES
order by hire_date asc; -- order by TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date), 0) desc; böylede desc olarak yazabilirdim.


----Çok Satırlı Fonksiyonlar
select count(*) as calisan_sayisi --- count: satır sayısını sorar
from hr.EMPLOYEES;

select sum(salary) as toplam_maas  -- sum: kolondaki tüm değerleri toplar 
from hr.employees;

select trunc(avg(salary), 0) as ort_maas -- avg: ortalama işlemi yapar (değer çok küsüratlıydı trunc ile küsürat attım)
from hr.employees;

select min(salary), max(salary)  --- min/max: tipik en düşük ve en yüksek değer.
from hr.employees;

-- Group By - Having
select department_id, trunc(avg(salary),0) as ort_maas 
from hr.employees
group by department_id  -- Çoklu verilerde gruplama yapmak için kullanılır
Having avg(salary) > 6000;  --- Gruplanmış sonuçlara koşul koyar(filtreleme).

-- JOINLER: Veriler birden fazla tablolarda saklanır ve biz ilişkili bilgiler almak için bu tabloları join ve türleri ile birleştiririz.
SELECT <sütunlar>
FROM tabloA a
JOIN tabloB b
ON <eşleme-koşulu>;
--inner join : Her iki tabloda da eşleyen satırların kesişimlerini bize çıkarır.

select e.employee_id, e.first_name, d.department_name
from hr.employees e
inner join hr.departments d
 on e.department_id = d.department_id;
--left join: Adı üzerinde sol tablodaki(fromdan önceki) tüm veriyi çeker ama sağ tablodan eşleşme olan veriyi getirir. Eşleşme yoksa null döndürür.

select e.employee_id, e.first_name, d.department_name
from hr.employees e
left join hr.departments d
 on e.department_id = d.department_id
where d.department_name = 'Marketing'; -- Where kullandığımızda ise leftjoin etkisi kaybolur. Çünkü where satırları filtreler ve nullar elenir.

--right join: Sağ tablodaki tüm verileri getirir, solda eşleşme varsa çeker yoksa null döndürür.
--çoğunlukla kod okunurluğu için left join kullanılır. Çünkü tabloların yerlerini değiştirerekte aynı çıktı elde edilir.

select e.employee_id, e.first_name, d.department_name
from hr.employees e
right join hr.departments d
 on e.department_id = d.department_id;

 --full outer join: İki tabloyuda tamamen çeker Eşleşme yoksa null döndürür.

 select e.employee_id, e.first_name, d.department_name
from hr.employees e
full outer join hr.departments d
 on e.department_id = d.department_id;

-- cross join:Tabloların kartezyen çarpımı, yani her a sayırı ile her b satırı kombinasyonu
--self join: aynı tabloya join atar. örnek olarak çalışan-yönetici gibi kendi satırların aralarında ilişki kurması...

select e.first_name as calisan, m.first_name as yonetici
FROM hr.employees e
left join hr.employees m
    on e.manager_id = m.employee_id;

--En önemli konulardan biri olduğu için gbt den kolay orta zor alıştırmalar istedim. Pekişsin
--Kolay: employees ile departments INNER JOIN yapıp first_name, last_name, department_name getir.
--Orta: employees ile departments LEFT JOIN yap; departmanı olmayanları da listele (department_name NULL).
--Zor: employees tablosundan çalışan-yönetici (employee-manager) çift listesini yöneticisi olmayan çalışanları da gösterecek şekilde yaz;
--sonuçta employee, manager (NULL varsa boş) ve manager_level (manager’ın yöneticisinin adı) getirsin (iki seviye self join).
--Kolay:
select e.First_name, e.last_name, d.department_name
from hr.employees e
inner JOIN hr.departments d
    on e.department_id = d.department_id;
--Orta:
select e.first_name as Calisan, d.department_name as Gorev
from hr.employees e
left join hr.departments d
    on e.department_id = d.department_id;
--Zor:
select e.first_name as Calisan, m.first_name as Yonetici, d.department_name as Yonetici_Gorev
from hr.employees e
left join hr.employees m
    on e.manager_id = m.employee_id
left join hr.departments d
    on m.department_id = d.department_id;

-- yaşadığı ülke , id si ve ismini yazan tablo , yaşadığı yer bilinmiyorsa null
select c.country_name,e.employee_id, e.first_name
from HR.EMPLOYEES e
left JOIN hr.DEPARTMENTS d on e.DEPARTMENT_ID = d.DEPARTMENT_ID
left JOIN hr.LOCATIONS l on d.location_id = l.location_id
left JOIN hr.COUNTRIES c on l.country_id = c.country_id;

--- Alt sorgu türleri
--scalar sub
select e.first_name as isim,
        (select department_name --alt sorgu ile tablolar arası veri çektik
        from hr.departments d 
        where d.department_id = e.department_id) as dept_adi
from hr.employees e;

-- in,any,all
select first_name as isim, last_name as soy_isim
from hr.employees
where department_id IN(  ---in ile altsorgu şartlarına sahip tüm çalışanları çektik
    select department_id
    from hr.DEPARTMENTS
    where location_id =1700
);
--EXISTS alt sorgu içinde ilk bulunan satırda true döner 
select d.department_name
from hr.departments d
Where exists(
    select 1 from hr.employees e
    where e.department_id = d.department_id
);
--Correlated subquery
select e.first_name, e.salary, e.DEPARTMENT_ID
from hr.employees e
where e.salary > (
    select avg(ee.salary)
    from hr.employees ee
    where ee.department_id = e.department_id
);

-- x > any(subq)
-- x > all(subq)  değerler karşılanırsa true döndürür

---CTE Neden kullanırız? (With)
--Karmaşık sorguları parçalara ayırmak, okunurluk sağlamak.
--Bir ara sonucu birden fazla yerde kullanmak.
--Recursive sorgular için temiz yapı.

with dept_ort as(
    select department_id, trunc(avg(salary), 0) as ort_sal
    from hr.EMPLOYEES
    group by department_id
)
select e.first_name, e.salary, d.ort_sal
from hr.employees e
left join dept_ort d on e.department_id = d.department_id;

--Union: İki sorgunun sonuçlarını birleştirir, tekrar eden çıktıların bir kez tekrarlanmasını sağlar
select first_name,
    last_name,
    department_id
    from hr.EMPLOYEES
where department_id = 60
Union
select first_name,
    last_name,
    department_id
    from hr.EMPLOYEES
where department_id = 40;

--Union ALL: Unionla aynı işlevi görür fakat tekrar edenleride gösterir. yani deduplicate yapmaz
--Deduplicate yapmadığı için daha hızlı çalışır çünkü veri ayıklama yapmaz
select first_name,
    last_name,
    department_id
    from hr.EMPLOYEES
where department_id = 60
Union ALL
select first_name,
    last_name,
    department_id
    from hr.EMPLOYEES
where department_id = 40;

--Connect By ve Start With : sırali hiyerarşik listeler oluşturulur
select employee_id, first_name, manager_id, LEVEL
from hr.EMPLOYEES
start with manager_id is null
connect by PRIOR employee_id = manager_id -- prior: priorty den gelir öncelik 
order by level desc;

-- order siblings by : aynı seviyedeki düğümleri sıralamak için kullanılır
select first_name, LEVEL
from hr.employees
start with manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id
ORDER SIBLINGS BY first_name;
--döngü kontrolu NOCYCLE ve CONNECT_BY_ISCYCLE : veri hatalıysa döngünün sonsuza gider, bu komut bunu kontrol eder

select employee_id,
manager_id,
CONNECT_BY_ISCYCLE as dongu
from hr.EMPLOYEES
start with manager_id IS NULL
CONNECT BY NOCYCLE PRIOR employee_id = manager_id;

--Önemli fonk. ve açıklamaları:
--ROW_NUMBER(): Her partition içinde sıralamaya göre sıra numarası (1,2,3,...). Eşitler farklı sıra alır.
--RANK(): Eşit değerlere aynı rank verip arada gap bırakır (1,1,3).
--DENSE_RANK(): Eşit değerlere aynı rank verip gap bırakmaz (1,1,2).
--NTILE(n): Partition’ı n adet eşit bucket’a böler ve bucket numarasını döndürür.
--LAG(expr, offset, default): Partition içindeki önceki satırın değerini getirir.
--LEAD(expr, offset, default): Sonraki satırın değerini getirir.
--FIRST_VALUE, LAST_VALUE, NTH_VALUE: Partition içindeki ilk/son/n'ci değer.
--SUM() OVER(...), AVG() OVER(...): Partition içinde kümülatif veya pencere hesapları.
--COUNT() OVER(...): Partition içinde satır sayısı (her satıra count yazılabilir).


select e.employee_id, e.first_name as calisan, e.department_id, e.salary as maas,
       ROW_NUMBER() OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS rn_sira
FROM hr.employees e;

--Çalişan önceki maaş bilgisi çeken sorgu
select e.first_name as calisan,e.employee_id, e.salary,
       LAG(salary,1) OVER (PARTITION BY department_id order BY hire_date) AS onceki_maas
from hr.employees e;
--Çalışan ağacı PATH:
select employee_id,
       first_name,
       LEVEL AS seviye,
       SYS_CONNECT_BY_PATH(first_name, ' > ') AS path,
       CONNECT_BY_ISLEAF AS yaprak_mi,
       CONNECT_BY_ISCYCLE AS dongu_var_mi
from hr.employees
START WITH manager_id IS NULL          -- En üst yöneticiden başla (CEO)
CONNECT BY NOCYCLE PRIOR employee_id = manager_id;  -- Döngüye karşı koruma


---Okuyana teşekkürler :D
