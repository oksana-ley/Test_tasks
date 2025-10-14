-- 1. Активность по времени публикации
WITH time_periods AS (
 SELECT 
 CASE
 WHEN EXTRACT(HOUR FROM date) BETWEEN 6 AND 12 THEN 'Утро (6-12)'
 WHEN EXTRACT(HOUR FROM date) BETWEEN 12 AND 18 THEN 'День (12-18)'
 WHEN EXTRACT(HOUR FROM date) BETWEEN 18 AND 23 THEN 'Вечер (18-23)'
 ELSE 'Ночь (23-6)'
 END AS time_period,
 likes
 FROM posts.posts
)
SELECT 
 time_period,
 COUNT(*) as posts_count,
 ROUND(AVG(likes), 1) as avg_likes,
 MAX(likes) as max_likes,
 MIN(likes) as min_likes
FROM time_periods
GROUP BY time_period
ORDER BY avg_likes DESC;

-- 2. Активность по дню недели публикации
WITH weekday_data AS (
 SELECT 
 CASE EXTRACT(DOW FROM date)::int
 WHEN 0 THEN 'Воскресенье'
 WHEN 1 THEN 'Понедельник'
 WHEN 2 THEN 'Вторник'
 WHEN 3 THEN 'Среда'
 WHEN 4 THEN 'Четверг'
 WHEN 5 THEN 'Пятница'
 WHEN 6 THEN 'Суббота'
 END as weekday,
 likes
 FROM posts.posts
)
SELECT 
 weekday,
 COUNT(*) as posts_count,
 ROUND(AVG(likes), 2) as avg_likes,
 MAX(likes) as max_likes,
 MIN(likes) as min_likes
FROM weekday_data
GROUP BY weekday
ORDER BY avg_likes DESC;

-- 3. Активность в зависимости от промежутка между публикациями
WITH post_intervals AS (
 SELECT 
 date,
 likes,
 EXTRACT(EPOCH FROM date - LAG(date) OVER (ORDER BY date))/86400 as interval_days
 FROM posts.posts
)
SELECT 
 CASE
 WHEN interval_days = 1 THEN '1 день'
 WHEN interval_days = 2 THEN '2 дня'
 WHEN interval_days BETWEEN 3 AND 7 THEN '3-7 дней'
 ELSE 'Более 7 дней'
 END as interval_group,
 COUNT(*) as posts_count,
 ROUND(AVG(likes), 1) as avg_likes,
 MAX(likes) as max_likes,
 MIN(likes) as min_likes
FROM post_intervals
GROUP BY interval_group
ORDER BY interval_group;
