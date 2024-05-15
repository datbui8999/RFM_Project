select CustomerID ,
              (datediff(day,max(cast(Purchase_Date as date)),'2022-09-01')) as recency,
              round(cast((count(distinct(cast(Purchase_Date as date)))) as float)  /
              cast(datediff(year,cast(created_date as date),'2022-09-01') as float),2) as frequency ,
              (sum(gmv)) /
              datediff(year,cast(created_date as date),'2022-09-01') as monetary ,
              row_number() over (order by (datediff(day,max(cast(Purchase_Date as date)),'2022-09-01')) ) as rn_recency,
              row_number() over (order by (round(cast((count(distinct(cast(Purchase_Date as date)))) as float)  /
              cast(datediff(year,cast(created_date as date),'2022-09-01') as float),2)) ) as rn_frequency ,
              row_number() over (order by (sum(gmv)) ) as rn_monetary
into #calculation
from Customer_Transaction T
join Customer_Registered R on T.CustomerID = R.ID
where customerID != 0
group by CustomerID , created_date

select * , case
    when recency < ((select recency from #calculation
                                    where rn_recency = ((((select cast(count(distinct(customerid))*0.25 as int)
                                                           from #calculation))))
             and recency >= (select recency from #calculation where rn_recency = 1)))
        then '1'
    when recency >= ((select recency from #calculation
                                    where rn_recency = ((select cast(count(distinct(customerid))*0.25 as int)
                                    from #calculation))))
             and recency < ((select recency from #calculation
                                    where rn_recency = ((select cast(count(distinct(customerid))*0.5 as int)
                                    from #calculation))))
        then '2'
    when recency >= ((select recency from #calculation
                                    where rn_recency = ((select cast(count(distinct(customerid))*0.5 as int)
                                    from #calculation))))
             and recency < ((select recency from #calculation
                                    where rn_recency = ((select cast(count(distinct(customerid))*0.75 as int)
                                    from #calculation))))
        then '3'
else '4' end as R ,
    case
    when frequency < ((select frequency from #calculation
                                    where rn_frequency = ((select cast(count(distinct(customerid))*0.25 as int)
                                                           from #calculation))))
             and frequency >= (select frequency from #calculation where rn_frequency = 1)
        then '1'
    when frequency >= ((select frequency from #calculation
                                    where rn_frequency = ((select cast(count(distinct(customerid))*0.25 as int)
                                                           from #calculation))))
             and frequency < ((select frequency from #calculation
                                    where rn_frequency = ((select cast(count(distinct(customerid))*0.5 as int)
                                                           from #calculation))))
        then '2'
    when frequency >= ((select frequency from #calculation
                                    where rn_frequency = ((select cast(count(distinct(customerid))*0.5 as int)
                                                           from #calculation))))
             and frequency < ((select frequency from #calculation
                                    where rn_frequency = ((select cast(count(distinct(customerid))*0.75 as int)
                                                           from #calculation))))
        then '3'
else '4' end as F ,
    case
    when monetary < ((select monetary from #calculation
                                    where rn_monetary = ((select cast(count(distinct(customerid))*0.25 as int)
                                                          from #calculation))))
             and monetary >= (select monetary from #calculation where rn_monetary = 1)
        then '1'
    when monetary >= ((select monetary from #calculation
                                    where rn_monetary = ((select cast(count(distinct(customerid))*0.25 as int)
                                                          from #calculation))))
             and monetary < ((select monetary from #calculation
                                    where rn_monetary = ((select cast(count(distinct(customerid))*0.5 as int)
                                                          from #calculation))))
        then '2'
    when monetary >= ((select monetary from #calculation
                                    where rn_monetary = ((select cast(count(distinct(customerid))*0.5 as int)
                                                          from #calculation))))
             and monetary < ((select monetary from #calculation
                                    where rn_monetary = ((select cast(count(distinct(customerid))*0.75 as int)
                                                          from #calculation))))
        then '3'
else '4' end as M
into #result 
    from #calculation
select monetary FROM #result where m =1

select * from #calculation
select R, count(CustomerID) as 'Total Customer' from  #result 
group by r
order by r

select F, count(CustomerID) as 'Total Customer' from  #result 
group by f
order by f

select M, count(CustomerID) as 'Total Customer' from  #result 
group by M
order by M


select DISTINCT concat(R,F,M) as [group] from #result
where concat(R,F,M) like '2%'

select *,concat(R,F,M) as [group]  ,
case when concat(R,F,M) in (434, 442, 443, 444,344) then 'VIP'
     when concat(R,F,M) in (442, 441, 433, 431, 343, 342, 341, 441, 433)  then 'Loyal Customer'
    when concat(R,F,M) in (424, 432, 423, 323, 413, 414, 343, 334) then 'Potential customers'
    when concat(R,F,M) in (333,332,331, 422, 313, 422, 421, 411, 321, 312, 322, 324, 412, 314, 311) then 'Value Customer'
when concat(R,F,M) like '2%' then 'Need Attention'
when concat(R,F,M) in (144, 143, 111,112, 113,114, 121, 122, 123,124, 141, 142) then 'Lost Customer' end as Segmentation
     from #result
     
group by concat(R,F,M)

SELECT count(dis)






