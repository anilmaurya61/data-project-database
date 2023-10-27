-- 1. Number of matches played per year for all the years in IPL.

select season, count(1) 
from matches 
group by season 
order by season;

-- 2. Number of matches won per team per year in IPL.

select season, count(*), winner 
from matches 
where winner 
IS NOT NULL group by winner, season 
order by season;

-- 3. Extra runs conceded per team in the year 2016

select bowling_team, sum(extra_runs) from deliveries 
where match_id in(select id from matches where season = 2016) 
group by bowling_team;


select d.bowling_team as "Team_Name", sum(d.extra_runs) as "Extra_Runs"
from matches mat inner join deliveries d 
on mat.id = d.match_id 
where mat.season = 2016 
group by d.bowling_team;


-- 4. Top 10 economical bowlers in the year 2015

select d.bowler as "Bowler", 
(sum(d.total_runs)/(count(d.ball) - count(CASE WHEN d.wide_runs != 0 THEN 1 END)- count(CASE WHEN d.noball_runs != 0 THEN 1 END))::float)*6
as "Economy Rate"
from matches mat inner join deliveries d 
on mat.id = d.match_id 
where mat.season = 2015 
group by d.bowler order by "Economy Rate" LIMIT 10;

-- 5. Find the number of times each team won the toss and also won the match

select toss_winner as "Team_Name", 
count(*) from matches 
where toss_winner = winner 
group by toss_winner;

-- 6. Find a player who has won the highest number of Player of the Match awards for each season

WITH PlayerAwards AS (
    SELECT season, player_of_match, COUNT(*) AS awards_count
    FROM matches
    GROUP BY season, player_of_match
),
RankedAwards AS (
    SELECT
        season,
        player_of_match,
        awards_count,
        RANK() OVER (PARTITION BY season ORDER BY awards_count DESC) AS rank
    FROM PlayerAwards
)
SELECT season, player_of_match, awards_count
FROM RankedAwards
WHERE rank = 1;

-- 7. Find the strike rate of a batsman for each season

SELECT season,batsman,
ROUND(SUM(batsman_runs)*100.0/COUNT(CASE WHEN noball_runs = 0 AND wide_runs = 0 THEN 1 ELSE NULL END),2) AS strike_rate
FROM matches m INNER JOIN deliveries d ON m.id = d.match_id
GROUP BY season,batsman
ORDER BY season,strike_rate DESC

-- 8. Find the highest number of times one player has been dismissed by another player

SELECT batsman,bowler,count(*) AS num_of_times FROM deliveries
WHERE dismissal_kind != 'run out'
GROUP BY batsman,bowler
ORDER BY num_of_times DESC LIMIT 1;


-- 9. Find the bowler with the best economy in super overs

SELECT
    d.bowler AS "Bowler",
    (SUM(d.total_runs) / (COUNT(d.ball) - COUNT(CASE WHEN d.wide_runs != 0 THEN 1 END) - COUNT(CASE WHEN d.noball_runs != 0 THEN 1 END))::float) * 6 AS "Economy Rate"
FROM
    matches mat
INNER JOIN
    deliveries d ON mat.id = d.match_id
WHERE
   d.is_super_over = 1
GROUP BY
    d.bowler
ORDER BY
    "Economy Rate" LIMIT 1;
