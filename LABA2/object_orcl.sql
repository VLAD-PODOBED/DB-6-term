CREATE VIEW VW_CAR AS
SELECT c.REGISTRATION_NUM, b.BRAND_NAME AS BRAND, col.COLOR_NAME AS COLOR, c.MODEL, c.YEAR
FROM CAR c
INNER JOIN BRAND b ON c.BRAND_ID = b.ID
INNER JOIN COLOR col ON c.COLOR_ID = col.ID;


CREATE OR REPLACE VIEW VW_DRIVER_CAR AS
SELECT dc.DRIVER_ID, d.NAME AS DRIVER_NAME, dc.CAR_ID, c.MODEL
FROM DRIVER_CAR dc
INNER JOIN DRIVER d ON dc.DRIVER_ID = d.ID
INNER JOIN CAR c ON dc.CAR_ID = c.REGISTRATION_NUM;


CREATE OR REPLACE VIEW VW_ORDER AS
SELECT o.ID,o.DATETIME,o.COST,
       c.NAME AS CLIENT_NAME, c.EMAIL AS CLIENT_EMAIL,
       dr.NAME AS DRIVER_NAME, dr.PHONE_NUMBER AS DRIVER_NUMBER,
        car.REGISTRATION_NUM AS REG_NUM, car.BRAND, car.MODEL, car.COLOR
FROM "ORDER" o
INNER JOIN CLIENT c ON o.CLIENT_ID = c.ID
INNER JOIN DRIVER dr ON o.DRIVER_ID = dr.ID
INNER JOIN DRIVER_CAR dr_car ON dr_car.DRIVER_ID = dr.ID AND to_date( dr_car."DATE",'YYYY-MM-DD')=to_date( o.DATETIME,'YYYY-MM-DD')
INNER JOIN VW_CAR car ON car.REGISTRATION_NUM = dr_car.CAR_ID;

CREATE OR REPLACE VIEW VW_REVIEW AS
SELECT r.ORDER_ID AS ID, r.TEXT, r.STARS,  c.NAME
FROM REVIEW r
INNER JOIN "ORDER" o ON r.ORDER_ID = o.ID
INNER JOIN CLIENT c ON c.ID =o.CLIENT_ID;


CREATE OR REPLACE VIEW VW_ACTIVE_ORDERS AS SELECT * FROM VW_ORDER;



CREATE OR REPLACE PROCEDURE UPDATE_ORDER_STATUS(
    p_order_id    IN INT,
    p_new_status  IN INT
)
AS
BEGIN
    UPDATE "ORDER"
    SET STATUS = p_new_status
    WHERE ID = p_order_id;

    COMMIT;
END;


CREATE OR REPLACE PROCEDURE ADD_DRIVER(
    p_name         IN NVARCHAR2,
    p_surname      IN NVARCHAR2,
    p_license      IN INT,
    p_phone_number IN VARCHAR2,
    p_email        IN NVARCHAR2
)
AS
BEGIN
    INSERT INTO DRIVER (NAME, SURNAME, LICENSE, PHONE_NUMBER, EMAIL)
    VALUES (p_name, p_surname, p_license, p_phone_number, p_email);

    COMMIT;
END;


CREATE OR REPLACE PROCEDURE GET_CARS_BY_COLOR(
    p_color_id IN INT
)
AS
BEGIN
    SELECT c.REGISTRATION_NUM, b.BRAND_NAME, c.MODEL, c.YEAR
    FROM CAR c
    INNER JOIN BRAND b ON c.BRAND_ID = b.ID
    WHERE c.COLOR_ID = p_color_id;
END;

CREATE OR REPLACE PROCEDURE ADD_REVIEW(
    p_order_id IN INT,
    p_text     IN NVARCHAR2,
    p_stars    IN INT
)
AS
BEGIN
    INSERT INTO REVIEW (ORDER_ID, TEXT, STARS)
    VALUES (p_order_id, p_text, p_stars);

    COMMIT;
END;


CREATE INDEX IDX_ORDER_CLIENT_ID ON "ORDER" (CLIENT_ID);
CREATE UNIQUE INDEX IDX_DRIVER_LICENSE ON DRIVER (LICENSE);
CREATE INDEX IDX_CAR_BRAND_ID ON CAR (BRAND_ID);
CREATE INDEX IDX_CLIENT_NAME_SURNAME ON CLIENT (NAME, SURNAME);


CREATE TRIGGER CAR_DELETE_DRIVER_CAR
AFTER DELETE ON CAR
FOR EACH ROW
BEGIN
    DELETE FROM DRIVER_CAR
    WHERE CAR_ID = OLD.REGISTRATION_NUM;
END;


CREATE TRIGGER ORDER_UPDATE_COST
AFTER UPDATE OF COST ON "ORDER"
FOR EACH ROW
BEGIN
    IF NEW.COST < 0 THEN
        RAISE EXCEPTION '��������� ������ �� ����� ���� �������������.';
    END IF;
END;




SELECT * FROM VW_CAR;

SELECT * FROM VW_DRIVER_CAR;

SELECT * FROM VW_ORDER;

SELECT * FROM "ORDER";

SELECT *FROM DRIVER_CAR;

SELECT *FROM VW_REVIEW;



SELECT *FROM "ORDER";

UPDATE "ORDER"
SET STATUS = 3
WHERE ID = 2;

SELECT *
FROM DRIVER_CAR;


BEGIN
    DBMS_OUTPUT.PUT_LINE('SOme');
END;


CREATE OR REPLACE FUNCTION GET_ALL_BRANDS
RETURN SYS_REFCURSOR
AS
    brands_cursor SYS_REFCURSOR;
BEGIN
    OPEN brands_cursor FOR
    SELECT BRAND_NAME
    FROM BRAND;

    RETURN brands_cursor;
END;

CREATE OR REPLACE FUNCTION GET_ALL_COLORS
RETURN SYS_REFCURSOR
AS
    colors_cursor SYS_REFCURSOR;
BEGIN
    OPEN colors_cursor FOR
    SELECT COLOR_NAME
    FROM COLOR;

    RETURN colors_cursor;
END;

CREATE OR REPLACE FUNCTION GET_CAR_BY_REGISTRATION_NUM
(
    p_registration_num IN INT
)
RETURN SYS_REFCURSOR
AS
    car_cursor SYS_REFCURSOR;
BEGIN
    OPEN car_cursor FOR
    SELECT c.REGISTRATION_NUM, b.BRAND_NAME, c.MODEL, c.YEAR, cl.COLOR_NAME, c.CAPACITY
    FROM CAR c
    INNER JOIN BRAND b ON c.BRAND_ID = b.ID
    INNER JOIN COLOR cl ON c.COLOR_ID = cl.ID
    WHERE c.REGISTRATION_NUM = p_registration_num;

    RETURN car_cursor;
END;