-- 환자들의 처방일 계산
-- (첫 처방일, 마지막 처방일, 첫 처방일 기준 90일 전, 첫 처방일 기준 후 28일 이후 90일 이내)
create table #anam_drug_date (
[person_id] bigint
,[drug_start_date] date
,[drug_end_date] date
,[before_90] date
,[after_28] date
,[after_90] date
)
insert into #anam_drug_date
select 
[person_id]
,min(drug_exposure_start_date) as drug_start_date
,max(drug_exposure_end_date) as drug_end_date
,dateadd(d,-90,min(drug_exposure_start_date)) as before_90
,dateadd(d,28,min(drug_exposure_start_date)) as after_28
,dateadd(d,90 ,min(drug_exposure_start_date)) as after_90
from [TEMP_DB2].[dbo].[EFFICACY_ANAM] group by person_id order by person_id, drug_start_date

select * from #anam_drug_date
order by person_id, drug_start_date

/* 코드 설명
생성한 테이블을 이용하여 첫 처방 시점 90일 전, 첫 처방 시점 28일 이후, 90일 이내 날짜를 계산하여 날짜 테이블을 생성합니다.*/

-- 안암 병원의 수축기 혈압 기록 추출
create table #anam_sbp(
[person_id] bigint
,[measurement_date] date
,[measurement_concept_id] bigint
,[value_as_number] bigint
) 
insert into #anam_sbp
select
[person_id] 
,[measurement_date] 
,[measurement_concept_id] 
,[value_as_number] 
from [ANAM_CDM_V5].[dbo].[measurement]
where measurement_concept_id in (xxx)
and [measurement_date] between convert(date, convert(varchar(10), 20081231)) and convert(date, convert(varchar(10), 20200101))
order by person_id

select * from #anam_sbp
order by person_id

/* 코드 설명
안암 데이터베이스의 measurement 테이블에서 2009년 1월 1일부터 2019년 12월 31일 까지의 수축기 혈압 기록을 전부 가져와 테이블을 생성합니다. */