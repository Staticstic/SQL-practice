-- date table 생성
create table #anam_date (
[person_id] bigint
,[drug_start_date] date
,[drug_end_date] date
,[before_180] date
)
insert into #anam_date
select
[person_id]
,min(drug_exposure_start_date) as drug_start_date
,max(drug_exposure_end_date) as drug_end_date
,dateadd(d,-180,min(drug_exposure_start_date)) as before_180
from temp_db2.[dbo].[POP_ANAM] group by person_id order by person_id, drug_start_date

select * from #anam_date
order by person_id

/* 코드 설명
해당 연구에서는 Baseline characteristics들의 유효기간을 첫 처방 시점 180일 전으로 정의를 하였습니다. 
따라서 먼저 6.1.2의 연구 대상자 추출 테이블에서 각 환자들의 첫 처방일, 첫 처방 시점 180일 전 날짜를 계산한 테이블을 생성합니다. */