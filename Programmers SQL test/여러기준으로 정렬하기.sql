-- 여러 기준으로 정렬하기
SELECT ANIMAL_ID, NAME, DATETIME 
from ANIMAL_INS
order by NAME asc, DATETIME desc;