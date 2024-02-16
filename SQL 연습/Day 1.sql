-- 기본 데이터 확인
SELECT * FROM project.raw_register_data
ORDER BY log_time DESC 
LIMIT 5

SELECT *, ROW_NUMBER() OVER(ORDER BY log_time DESC) AS row_num
FROM project.raw_register_data

-- DAU 구하기
SELECT date(log_time) AS DAY, 
COUNT(DISTINCT WID) AS DAU
FROM project.raw_login_data
GROUP BY date(log_time)

SELECT date(log_time) log_date
, COUNT(WID) num_of_login
, COUNT(DISTINCT WID) DAU
FROM project.raw_login_data 
GROUP BY 1

-- 아이템별 매출, 구매유저 수, ARPPU 구하기
SELECT item_id, 
SUM(revenue) AS total_revenue,
COUNT(DISTINCT WID) AS PU,
ROUND(SUM(revenue) / COUNT(DISTINCT WID), 2) AS ARPPU
FROM project.daily_sales
group by item_id


--Quest #1
--1 로그인 데이터 중 레벨 60 이상인 것을 찾으세요
SELECT * 
FROM project.raw_login_data 
WHERE level >= 60

-- 변형: 로그인 데이터에서 현재 기준으로 레벨을 정의하고, 각 유저의 최종 레벨을 기준으로 60 이상을 추출
SELECT WID, MAX(level) AS current_level
FROM project.raw_login_data 
GROUP BY 1
HAVING current_level >= 60

--2 2023년 3번 모드를 플레이 했거나, 2022년에 4번 모드를 플레이한 기록을 조회하세요
SELECT *
FROM project.daily_play
WHERE (EXTRACT(year from date) = 2022 AND mode = 4) OR (EXTRACT(year from date) = 2023 AND mode = 3)

-- Bigquery에서 날짜 불러오는 방식
date between '2022-01-01' and '2022-12-31'
EXTRACT(year from date) = 2022
FORMAT_DATE('%Y', date) = 2022

--3 한국의 facebook으로 가입한 유저, 일본의 guest로 가입한 유저가 몇명인지 구하세요
SELECT country, register_channel, COUNT(DISTINCT WID) AS num_ID
FROM project.raw_register_data 
WHERE (country = 'KR' AND register_channel = 'facebook') OR (country = 'JP' AND register_channel = 'guest')
GROUP BY country, register_channel

-- 다른 방법
SELECT 
COUNT(DISTINCT CASE WHEN country = 'KR' AND register_channel = 'facebook' THEN WID ELSE NULL END) AS KR_facebook,
SUM(CASE WHEN country = 'KR' AND register_channel = 'facebook' THEN 1 ELSE 0 END) AS KR_facebook_sum,
COUNT(DISTINCT CASE WHEN country = 'JP' AND register_channel = 'guest' THEN WID ELSE NULL END) AS JP_guest,
SUM(CASE WHEN country = 'JP' AND register_channel = 'guest' THEN 1 ELSE 0 END) AS JP_guest_sum
FROM project.raw_register_data 

--4 우리 프로젝트의 총 매출, 구매 유저 수를 구하세요
SELECT COUNT(DISTINCT WID) AS PU,
SUM(revenue) AS TOTAL_PRICE
FROM project.daily_sales 

--5 각 유저의 현재 레벨(최고), 최근 로그인 시간, 로그인 횟수, 로그인 일수를 구하세요
SELECT WID, 
MAX(level) AS current_level,
MAX(log_time) AS log_time,
COUNT(*) AS log_count,
COUNT(DISTINCT (EXTRACT(day from log_time))) AS log_day
FROM project.raw_login_data 
GROUP BY WID
