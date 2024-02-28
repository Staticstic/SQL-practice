-- before
-- 첫 처방일 기준 90일 전 이내 혈압 추출
create table #anam_sbp_before(
[person_id] bigint
,[measurement_date] date
,[measurement_concept_id] bigint
,[value_as_number] bigint
,[drug_start_date] date
,[drug_end_date] date
)
insert into #anam_sbp_before
select
a.person_id
, b.measurement_date
, b.measurement_concept_id
, b.value_as_number
, a.drug_start_date
, a.drug_end_date
from #anam_drug_date a
left join #anam_sbp b on a.person_id=b.person_id
where b.measurement_date between a.before_90 and a.drug_start_date
and value_as_number >50 and value_as_number<300

select * from #anam_sbp_before
order by person_id

-- 같은 날짜에 혈압을 여러번 측정한 경우, 평균으로 계산
select person_id, measurement_date, avg(convert(float,value_as_number)) as mean_value 
into #anam_before_sbp_mean
from #anam_sbp_before 
group by person_id, measurement_date
order by person_id, measurement_date

/* 코드 설명
 처음에 생성한 안암 대상자 날짜 테이블과 안암 병원 수축기 혈압 테이블을 환자 ID (person_id)를 key 값으로 조인하여 생성합니다. 
 이 때 where 절을 이용하여 환자들의 첫 처방일과 첫 처방 시점 90일 전 사이에 혈압 기록만을 가져와 Baseline 수축기 혈압 테이블을 생성합니다. 
 또한 본 연구에서는 수축기 혈압을 50 초과 300 미만으로 정의하였습니다.
 만약 같은 날짜에 한 환자의 수축기 혈압 기록이 여러 개 있는 경우 해당 수축기 혈압은 여러 번 측정된 기록들의 평균을 계산하여 사용하였습니다. */


-- 측정 기준일(첫 처방일 기준 90일 전 이내)에 가장 가까운 두개 혈압 추출
select * into #before_sbp_rank from 
(select *,
rank() over(partition by person_id order by measurement_date desc) as [rnk] 
from #anam_before_sbp_mean) a
where a.rnk<3

-- 두개 혈압의 평균 계산
select person_id, avg(convert(float, mean_value)) as before_sbp_mean into #sbp_before
from #before_sbp_rank group by person_id 
order by person_id

/* 코드 설명
본 연구에서는 약 처방 전 후로 각각 2번씩 측정한 혈압기록의 평균값으로 비교하였습니다. 
따라서 위의 코드는 환자 별 첫 처방 시점 90일 전 이내의 혈압 기록들 중 첫 처방일에 가장 가까운 두 개의 혈압을 추출하여 평균을 계산하는 과정입니다. */