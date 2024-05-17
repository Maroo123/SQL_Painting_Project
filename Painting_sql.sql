select * from artist;
select * from canvas_size;
select * from image_link;
select * from museum_hours;
select * from museum;
select * from product_size;
select * from subject;
select * from work ;

-Identify the museums which are open on both Sunday and Monday. Display museum name, city.

select m.name as museum_name , m.city
from museum_hours mh1
join museum m on m.museum_id = mh1.museum_id
where day='Sunday'
and exists (select 1 from museum_hours mh2
		    where mh2.museum_id = mh1.museum_id
		    and mh2.day = 'Monday')
			
-Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?
-- use subquery to take only the first rank
select * from (
	select m.name as museum_name, m.state , mh.open, mh.day
	, to_timestamp(open, 'HH:MI AM') as open_time
	, to_timestamp(close, 'HH:MI PM ')as close_time
	, to_timestamp(close, 'HH:MI PM ') - to_timestamp(open, 'HH:MI AM') as duration
	, rank () over(order by (to_timestamp(close, 'HH:MI PM ') - to_timestamp(open, 'HH:MI AM')) desc ) as rnk
	from museum_hours mh
	join museum m on m.museum_id = mh.museum_id ) x
where x.rnk = 1 ;

-Display the country and the city with most no(number) of museums. Output 2 seperate columns to mention the city and country. If there are multiple value, seperate them with comma.

with cte_country as 
			(select country, count(1)
			, rank() over(order by count(1) desc) as rnk
			from museum
			group by country),
		cte_city as
			(select city, count(1)
			, rank() over(order by count(1) desc) as rnk
			from museum
			group by city)
select string_agg(distinct country.country,', ') as country , string_agg(city.city,', ') as city
from cte_country country
cross join cte_city city
where country.rnk = 1
and city.rnk = 1;

-Fetch the top 10 most famous painting subject

	select * 
	from (
		select s.subject,count(1) as no_of_paintings
		,rank() over(order by count(1) desc) as ranking
		from work w
		join subject s on s.work_id=w.work_id
		group by s.subject ) x
	where ranking <= 10;


-Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)

	select a.full_name as artist, a.nationality,x.no_of_painintgs
	from (	select a.artist_id, count(1) as no_of_painintgs
			, rank() over(order by count(1) desc) as rnk
			from work w
			join artist a on a.artist_id=w.artist_id
			group by a.artist_id) x
	join artist a on a.artist_id=x.artist_id
	where x.rnk<=5;

Identify the artist and the museum where the most expensive and least expensive painting is placed. 
Display the artist name, sale_price, painting name, museum name, museum city and canvas label

	with cte as 
		(select *
		, rank() over(order by sale_price desc) as rnk
		, rank() over(order by sale_price ) as rnk_asc
		from product_size )
	select w.name as painting
	, cte.sale_price
	, a.full_name as artist
	, m.name as museum, m.city
	, cz.label as canvas
	from cte
	join work w on w.work_id=cte.work_id
	join museum m on m.museum_id=w.museum_id
	join artist a on a.artist_id=w.artist_id
	join canvas_size cz on cz.size_id = cte.size_id::NUMERIC
	where rnk=1 or rnk_asc=1;

-Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality.

	select full_name as artist_name, nationality, no_of_paintings
	from (
		select a.full_name, a.nationality
		,count(1) as no_of_paintings
		,rank() over(order by count(1) desc) as rnk
		from work w
		join artist a on a.artist_id=w.artist_id
		join subject s on s.work_id=w.work_id
		join museum m on m.museum_id=w.museum_id
		where s.subject='Portraits'
		and m.country != 'USA'
		group by a.full_name, a.nationality) x
	where rnk=1;	

