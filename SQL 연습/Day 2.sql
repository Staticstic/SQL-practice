-- Quest #2
--1 국가별 DAU를 구하세요
SELECT country, date(log_time) log_data, COUNT(DISTINCT WID)  
FROM project.raw_login_data 
GROUP BY 1, 2

-- 국가별 MAU 구하기
SELECT country, FORMAT_DATE('%Y-%m', log_time) yy_mm, COUNT(DISTINCT WID)  
FROM project.raw_login_data 
GROUP BY 1, 2

--2 guest 계정과 guest 계정이 아닌 경우를 SNS로 정의하여 가입한 유저 수를 집계하세요 (단, country가 Null인 경우, undefined로 구분)
SELECT COUNT(DISTINCT WID) user_num, CASE WHEN country IS NULL then 'undefined'
	ELSE CASE WHEN register_channel = 'guest' THEN 'guest'
		ELSE 'SNS' END
	END user_type
FROM project.raw_register_data 
GROUP BY 2

-- 다른 풀이
SELECT 
CASE WHEN country IS NULL THEN 'undefined'
		WHEN register_channel = 'guest' then 'guest'
		ELSE 'SNS' END channel_group
		, COUNT(DISTINCT WID) register_users
FROM project.raw_register_data 
GROUP BY 1

--3 월별 아이템별 매출, 구매유저 수, ARPPU, 판매일수, 총 판매 양을 집계하세요
SELECT FORMAT_DATE('%Y-%m', date), item_id 
, SUM(revenue) total_revenue
, COUNT(DISTINCT WID) PU
, SUM(revenue) / COUNT(DISTINCT WID) ARPPU
, COUNT(DISTINCT date) total_days
, SUM(buy_count) total_count
FROM project.daily_sales 
GROUP BY 1, 2
ORDER BY 2, 1

-- DATE_TRUNC를 이용하여 날짜 계산
-- 원하는 곳 까지 날짜를 달라줌 -> DATA TYPE은 date
SELECT DATE_TRUNC(date, MONTH), item_id 
, SUM(revenue) total_revenue
, COUNT(DISTINCT WID) PU
, SUM(revenue) / COUNT(DISTINCT WID) ARPPU
, COUNT(DISTINCT date) total_days
, SUM(buy_count) total_count
FROM project.daily_sales 
GROUP BY 1, 2
ORDER BY 2, 1

--4 가입 유저 중 WID가 W10500 ~ W11000이며, 국적이 KR인 유저들의 가입정보 추출
SELECT * 
FROM project.raw_register_data 
WHERE country = 'KR' 
AND (WID BETWEEN 'W10500' AND 'W11000') -- 문자도 부등호, BETWEEN 계산이 가능함

--5 구매 수량이 5개 이상이면 regular, 10개 이상이면 large, 5개 미만인 경우 small로 정의한 buy_size 별로 구매 건수와 매출 총액, 구매 유저 수를 구하세요
SELECT *
FROM project.daily_sales 