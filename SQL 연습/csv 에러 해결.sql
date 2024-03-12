-- cp949 codec can't decode byte 0xec 해결하기
-- 빈 테이블 생성하기
CREATE TABLE tablename (
    customer_no VARCHAR(255),
    age INT,
    gender INT,
    order_no VARCHAR(255),
    order_date DATE,
    channel VARCHAR(50),
    item_category VARCHAR(100),
    item_code VARCHAR(100),
    item_name VARCHAR(255),
    price INT,
    qty INT,
    order_amount INT,
    discount_amount INT,
    paid_amount INT
);

-- csv 파일 불러오기
LOAD DATA LOCAL INFILE '/path/to/your/file.csv'
INTO TABLE tablename
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;