##########第七章
#######1 数值函数
select round(5.73);  ##输出为6    round() for rounding a number 四舍五入
select round(5.73,1);  ##输出为5.7， “1”表示四舍五入保留1位小数
select truncate(5.7345,2);  ##输出为5.73，truncate() 截断
select ceiling(5.73);  ##输出为6，ceiling 向上取整
select floor(5.73);  ##输出为5，floor 向下取整
select abs(-5);  ##输出为5，absolute 取绝对值
select rand();   ##输出0-1之间的随机值


#######2 字符串函数
select length('jade');  ##输出4，字符串长度
select upper('jade');  ##输出JADE，将字符串改成大写
select lower('JADE');  ##输出jade，将字符串改成小写
select ltrim('  jade');  ##输出jade，left trim删掉左边空格键
select rtrim('jade  ');  ##输出jade,right trim删掉右边空格键
select trim('  jade  ');  ##输出jade, trim删掉前后空格键，not中间though
select left('jadetong',4);  ##输出jade,左边4个字母
select right('jadetong',4);  ##输出tong,右边4个字母
select substring('jadetong',2,3);  ##输出ade, 从第2个字母开始取3个字母
select locate('a','jadetong');  ##输出2，定位指定字母在字符串中的位置
select locate('tong','jadetong');  ##输出5
select replace('jade is good','good','best');  ##输出'jade is best'，替换字符串
select concat('jade','tong');  ##输出jadetong，concat串联字符串
#concat例子  输出customers表中的顾客全名
select concat(first_name,' ',last_name) as full_name from customers;



#########3 日期函数
 select now(),curdate(),curtime();  ##current date,current time
select year(now());  ##提取当前时间的年份
select month(now());  ##提取当前时间的月份
select day(now());  ##提取当前时间的日份
select hour(now());  ##提取当前时间的小时数
SELECT MINUTE(NOW());  ##提取当前时间的分钟数
select second(now());  ##提取当前时间的秒钟数

select dayname(now());  ##输出当前时间为星期几
select monthname(now());  ##输出当前时间为几月

select extract(year from now());



########## 4 格式化日期和时间
select date_format(now(),'%y');   ##小写输出24
select date_format(now(),'%Y');   ##大写输出2024
select date_format(now(),'%m');   ##小写输出03
select date_format(now(),'%M');   ##大写输出MARCH
select date_format(now(),'%d');   ##小写输出28
select date_format(now(),'%D');   ##大写输出28th
 
select date_format(now(),'%M %D %Y');  ##输出March 28th 2024

########### 5 计算日期和时间
select date_add(now(),interval 1 day);  ##现日期加一天
select date_add(now(),interval -1 day);  ##现日期减一天
##减一天也可用date_sub()
select date_sub(now(),interval 1 day);

select datediff('2024-01-02','2024-01-01');  ##计算两个日期之间的差距

select time_to_sec('01:00');  ##输出离零点零分的秒数
select time_to_sec('01:00') - time_to_sec('00:30');  ##输出两个时间相差的秒数



##############6 ifnull函数和coalesce函数 
#####将orders表中没有发货人的订单标记为‘未指定’
select 
    order_id,
    ifnull(shipper_id,'not assigned') as shipper      ####用ifnull可以用其它内容来替换空值
from orders;

select 
    order_id,
    coalesce(shipper_id,comments,'not assigned') as shipper ##用coalesce，可提供一系列选择，将返回第一个非空值
from orders;

##练习 用customers表 输出顾客全民和电话号码，电话号码为空值则输出‘unknown’
select 
    concat(first_name,' ',last_name) as customer,
    ifnull(phone,'unknown') as phone
from customers;


################## 7 if函数  if(expression,first(if true),second(if false))
select 
    order_id,
    order_date,
    if(year(order_date)>=2019,'active','archived') as customer_category
from orders;

######练习 算出每个产品被下单的次数，并分类成多次或一次
select 
    product_id,
    name,
    count(name) as orders,
    if(count(name)>1,'many times','once') as frequecy
from order_items
join products using(product_id)
group by product_id;


######################### 8 case运算符   if函数只允许二选一条件，case允许多个条件
select 
    order_id,order_date,
    case
        when year(order_date)=2019 then 'active'
        when year(order_date)=2018 then 'last year'
        else 'archived'
        end as customer_category
from orders;

####练习 用case 将顾客以积分来分类
select 
    concat(first_name,' ',last_name) as customer,
    points,
    case
        when points>=3000 then 'gold'
        when points<2000 then 'bronze'
        else 'sliver'
        end as category
from customers
order by points desc;




##############  第八章 1-创建视图  create view xxx as (query)
####创建一个视图 来查看客户余额（invoice_total-payment_total)
use sql_invoicing;
create view client_balance as
    (select 
        client_id,
        name,
        sum(invoice_total-payment_total) as balance from clients
    join invoices using (client_id)
    group by client_id
    order by client_id);


############8.2 更改或删除视图 
##drop view xxx
##create or replace view xxx as (重写query)  


###########8.3 可更改视图 
#如果视图里没有distinct、aggregate function、group by、having、union这些函数 就可以更改视图

create or replace view invoice_with_balance as 
    (select 
        invoice_id,
        number,
        client_id,
        invoice_total,
        payment_total,
        invoice_total-payment_total as balance,
        invoice_date,
        due_date,
        payment_date
    from invoices);

delete from invoice_with_balance
where invoice_id=1;

update invoice_with_balance
set due_date=date_add(due_date,interval 2 day)
where invoice_id=2;


update invoice_with_balance
set payment_total=invoice_total
where invoice_id=2












