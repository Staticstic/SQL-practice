-- Quest #3
--1 매출이 가장 높은 유저의 로그인 기록
SELECT * FROM project.raw_login_data
WHERE WID = (SELECT WID
FROM (
SELECT WID, SUM(revenue) total_rev
FROM project.daily_sales
GROUP BY 1
ORDER BY 2 DESC LIMIT 1))

-- 상위 N명을 구할 때
SELECT * FROM project.raw_login_data
WHERE WID IN (SELECT WID
FROM (
SELECT WID, SUM(revenue) total_rev,
RANK() OVER(ORDER BY SUM(revenue) DESC) rnk 
FROM project.daily_sales
GROUP BY 1)
WHERE rnk<=3)
ORDER BY WID

-- WITH 절 사용
WITH vip_user AS (SELECT WID
FROM (
SELECT WID, SUM(revenue) total_rev,
RANK() OVER(ORDER BY SUM(revenue) DESC) rnk 
FROM project.daily_sales
GROUP BY 1)
WHERE rnk<=3)
SELECT * FROM project.raw_login_data
WHERE WID IN (SELECT * FROM vip_user)

-- WITH와 JOIN 사용
WITH vip_user AS (SELECT WID
FROM (
SELECT WID, SUM(revenue) total_rev,
RANK() OVER(ORDER BY SUM(revenue) DESC) rnk 
FROM project.daily_sales
GROUP BY 1)
WHERE rnk<=3)
SELECT * FROM project.raw_login_data A
JOIN vip_user B
ON A.WID = B.WID

--2 각 레벨별 유저 수를 구하세요(현재 레벨 기준)
SELECT cur_level, COUNT(DISTINCT WID)
FROM(
SELECT WID, MAX(level) cur_level
FROM project.raw_login_data
GROUP BY 1)
GROUP BY 1
ORDER BY 1

-- 비율까지 계산하는 법
-- CROSS JOIN 사용
-- JOIN KEY가 없을 때 JOIN 가능하게 해주는 함수
SELECT cur_level, user, ROUND(user/total_user*100, 2) rate 
FROM (
	SELECT cur_level, COUNT(DISTINCT WID) user
	FROM (
		SELECT WID, MAX(level) cur_level
		FROM project.raw_login_data
		GROUP BY 1)
	GROUP BY 1)
CROSS JOIN (SELECT COUNT(DISTINCT WID) total_user FROM project.raw_login_data)
ORDER BY 1


--3 일별 ARPDAU와 PUR을 구하세요
-- ARPPU : Average Revenue Per Paying User -> 구매력 확인
-- ARPDAU : Average Revenue Daily Per Daily Active User -> 객단가
-- PUR : Paying User Rate = PU / AU -> 구매 전환율
SELECT log_date, COALESCE(total_rev, 0)/DAU ARPDAU,
COALESCE(PU, 0)/DAU PUR
FROM (
SELECT date(log_time) log_date, COUNT(DISTINCT WID) DAU FROM project.raw_login_data
GROUP BY 1) A
LEFT JOIN (
SELECT date, SUM(revenue) total_rev, COUNT(DISTINCT WID) PU FROM project.daily_sales
GROUP BY 1) B
ON A.log_date = B.date
ORDER BY 1

--4 국가별, OS별, 가입채널에 따른 구매 유저 수와 비구매 유저 수를 구하세요
SELECT country, os, register_channel,
COUNT(DISTINCT B.WID) PU,
COUNT(DISTINCT A.WID) - COUNT(DISTINCT B.WID) NON_PU,
COUNT(DISTINCT CASE WHEN B.WID IS NULL THEN A.WID END) NON_PU
FROM project.raw_register_data A
LEFT JOIN project.daily_sales B
ON A.WID = B.WID
GROUP BY 1, 2, 3

--5 레벨 30 이상과 미만의 DAU와 당일 플레이 유저 수 비중을 일별로 구하세요(단 한 유저의 레벨응 당일 최고 기준)
SELECT log_date, CASE WHEN max_level >= 30 THEN 'high' ELSE 'low' END level_group,
COUNT(DISTINCT A.WID) DAU,
ROUND(COUNT(DISTINCT B.WID) / COUNT(DISTINCT A.WID), 2) GAU_ratio
FROM project.raw_login_data GROUP BY 1, 2) A
LEFT JOIN project.daily_play B
ON A.WID = B.WID AND A.log_date = B.date
GROUP BY 1, 2
