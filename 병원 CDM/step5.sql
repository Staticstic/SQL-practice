-- 첫 처방일 기준 전, 후로 수축기 혈압 측정기록이 모두 있는 환자 추출
create table #sbp
(person_id bigint
,before_sbp_mean float
,after_sbp_mean float
)
insert into #sbp
select
a.person_id
,a.before_sbp_mean
,b.after_sbp_mean
from #sbp_before a
inner join #sbp_after b on a.person_id=b.person_id

/* 코드 설명
앞에서 생성한 Baseline, Follow-up 수축기 혈압 테이블들을 이용하여 처방 전 후로 수축기 혈압 기록이 모두 존재하는 환자들만을 추출하여 수축기 혈압 테이블을 생성합니다. 
동일한 방법으로 이완기 혈압 테이블 역시 생성합니다. */


-- 최종 테이블 생성
-- 아모잘탄 첫 처방일 전, 후 수축기, 이완기 혈압
create table #hypertension
(person_id bigint
,before_sbp_mean float
,after_sbp_mean float
,before_dbp_mean float
,after_dbp_mean float
)
insert into #hypertension
select
a.person_id
,a.before_sbp_mean 
,a.after_sbp_mean 
,b.before_dbp_mean 
,b.after_dbp_mean
from #sbp a
inner join #dbp b on a.person_id=b.person_id

select * from #hypertension
order by person_id

/* 코드 설명
수축기 혈압 테이블, 이완기 혈압 테이블을 합쳐 최종 혈압 분석 테이블을 생성합니다. */