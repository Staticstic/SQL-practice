-- 안암 병원에서 아모잘탄 패밀리를 처방 받은 환자 추출
create table #anam
(
[person_id] bigint
,sex char(5)
,age int	
,[drug_concept_id] bigint
,[drug_exposure_start_date] date
,[drug_exposure_end_date] date
,[quantity] int
,[days_supply] int
)
insert into #anam
select
a.[person_id]
,iif(b.gender_concept_id=8507, 1, 0) as sex -- Female : 0, Male : 1
,datepart(YYYY,a.[drug_exposure_start_date])-b.year_of_birth+1 as age
,a.[drug_concept_id]
,a.[drug_exposure_start_date]
,a.[drug_exposure_end_date]
,a.[quantity]
,a.[days_supply]
from [ANAM_CDM_V5].[dbo].[drug_exposure] a
left join
[ANAM_CDM_V5].[dbo].[person] b on a.person_id=b.person_id
where [drug_exposure_start_date] between convert(date, convert(varchar(10), 20081231)) and convert(date, convert(varchar(10), 20200101))
and a.drug_concept_id in (xxx, ... , xxx)
order by person_id, drug_exposure_start_datetime

select * from #anam
order by person_id, drug_exposure_start_date

/* 코드 설명
해당 과정은 안암 병원에서 2009년 1월 1일부터 2019년 12월 31일까지 아모잘탄, 아모잘탄큐, 아모잘탄플러스를 처방받은 환자들을 추출하여 테이블을 생성하는 과정입니다. 
안암병원 데이터베이스의 Person 테이블에서 환자 ID, 생년월일, 성별을 가져오고, Drug_exposure 테이블에서 처방약의 종류, 처방 날짜, 처방 기간을 가져와 환자 ID(person_id)를 key 값으로 조인하여 새로운 테이블을 생성합니다. 
이 때 where 절을 사용하여 처방약의 종류(drug_concept_id)를 아모잘탄 패밀리로 하고 처방날짜를 2009년 1월 1일부터 2019년 12월 31일까지로 조건을 주게 되면 안암 병원의 대상자 선정 테이블 생성됩니다. */
