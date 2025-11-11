/*
 Завдання на SQL до лекції 03.
 */


/*
1.
Вивести кількість фільмів в кожній категорії.
Результат відсортувати за спаданням.
*/
-- SQL code goes here...

SELECT C.NAME, COUNT(*)
FROM FILM F 
JOIN FILM_CATEGORY FC ON FC.FILM_ID = F.FILM_ID 
JOIN CATEGORY C ON C.CATEGORY_ID = FC.CATEGORY_ID 
GROUP BY C.NAME
ORDER BY COUNT(*) DESC;

/*
2.
Вивести 10 акторів, чиї фільми брали на прокат найбільше.
Результат відсортувати за спаданням.
*/
-- SQL code goes here...

SELECT A.FIRST_NAME, A.LAST_NAME, COUNT(R.RENTAL_ID) AS RENTAL_COUNT
FROM ACTOR A 
JOIN FILM_ACTOR FA ON FA.ACTOR_ID = A.ACTOR_ID 
JOIN INVENTORY I ON I.FILM_ID  = FA.FILM_ID 
JOIN RENTAL R ON R.INVENTORY_ID = I.INVENTORY_ID 
GROUP BY A.FIRST_NAME, A.LAST_NAME
ORDER BY RENTAL_COUNT DESC, A.FIRST_NAME, A.LAST_NAME
LIMIT 10;

/*
3.
Вивести категорія фільмів, на яку було витрачено найбільше грошей
в прокаті
*/
-- SQL code goes here...

--1: створюємо CTE з назвами категорій та сумою оплат за них
WITH SUMS AS (
SELECT C.NAME, SUM(P.AMOUNT) AS AMOUNT
FROM CATEGORY C 
JOIN FILM_CATEGORY FC ON FC.CATEGORY_ID = C.CATEGORY_ID 
JOIN FILM F ON F.FILM_ID = FC.FILM_ID 
JOIN INVENTORY I ON I.FILM_ID = F.FILM_ID 
JOIN RENTAL R ON R.INVENTORY_ID = I.INVENTORY_ID 
JOIN PAYMENT P ON P.RENTAL_ID = R.RENTAL_ID 
GROUP BY C.NAME 
)
--2: вибираємо з цієї CTE лише ту категорію, яка має максимальну суму оплат
SELECT NAME, AMOUNT
FROM SUMS
WHERE AMOUNT = (SELECT MAX(AMOUNT) FROM SUMS);



/*
4.
Вивести назви фільмів, яких не має в inventory.
Запит має бути без оператора IN
*/
-- SQL code goes here...

SELECT F.TITLE 
FROM FILM F 
LEFT JOIN INVENTORY I ON I.FILM_ID  = F.FILM_ID 
WHERE I.INVENTORY_ID IS NULL;


/*
5.
Вивести топ 3 актори, які найбільше зʼявлялись в категорії фільмів “Children”.
*/
-- SQL code goes here...

SELECT A.FIRST_NAME, A.LAST_NAME, COUNT(*) AS FILM_COUNT
FROM ACTOR A 
JOIN FILM_ACTOR FA ON FA.ACTOR_ID = A.ACTOR_ID 
JOIN FILM_CATEGORY FC ON FC.FILM_ID = FA.FILM_ID 
WHERE FC.CATEGORY_ID = (SELECT CATEGORY_ID FROM CATEGORY WHERE NAME = 'CHILDREN')
GROUP BY A.FIRST_NAME , A.LAST_NAME 
ORDER BY FILM_COUNT DESC, A.FIRST_NAME, A.LAST_NAME 
LIMIT 3;











