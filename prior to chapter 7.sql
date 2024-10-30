##################
select
      date,
      name as payment_method,
      sum(amount) as payment_total
from payments
join payment_methods on payments.payment_method=payment_methods.payment_method_id
group by date,payment_method
order by date;
############################### having

select customer_id,first_name,state,sum(quantity*unit_price) as spent from customers
join orders using(customer_id)
join order_items using(order_id)
group by customer_id
having spent>100 and state='va';

################################# rollup
select name as payment_method,sum(amount) from payments
left join payment_methods on payments.payment_method=payment_methods.payment_method_id
group by name with rollup;

##############################次查询subqueries
select * from products
where unit_price>
	 (select unit_price from products
      where product_id=3) ;

select * from employees
where salary > 
      (select avg(salary) from employees);
      
      
############in运算符
select * from products
where product_id not in 
       (select distinct product_id from order_items);
       
select * from clients
where client_id not in 
       (select distinct client_id from invoices);
       
########次查找vs连接 subqueries vs join
###找出没有发票的client
##次查找
select * from clients
where client_id not in 
       (select distinct client_id from invoices);
##用外连接join
select * from clients
left join invoices using (client_id)
where invoice_id is null;

##找出购买了生菜的顾客
select * from customers
where customer_id in
      (select distinct customer_id from orders
      join order_items using(order_id)
      where product_id=3)
order by customer_id;


#########ALL#####
###选出比顾客3最大的发票更大额的发票
##方法一
select * from invoices
where invoice_total>
		(select max(invoice_total) from invoices
		where client_id=3);

##方法二
select * from invoices
where invoice_total>
			all(select invoice_total from invoices
			 where client_id = 3);

###########ANY#######
#####找出有至少两张发票的顾客##
######方法一
select * from clients
where client_id in 
		(select client_id from invoices
		group by client_id
		having count(*)>=2);

#####方法二 any
select * from clients
where client_id =  
		any (select client_id from invoices
		group by client_id
		having count(*)>=2);
        
        
#############      相关子查询   好难好神奇的逻辑
######找出比同办公室的平均工资高的员工
select * from sql_hr.employees as e
where salary > 
(select avg(salary) from sql_hr.employees
where office_id = e.office_id);     #######针对左表每一条的office_id来对比

##练习##找出invoices表中每个顾客比自己的平均消费额大的发票
select * from invoices i
where invoice_total > 
(select avg(invoice_total) from invoices
where client_id = i.client_id)
order by client_id;

###########     EXISTS        ########
####找出有发票的顾客
##方法一
select * from clients
where client_id in 
		(select distinct client_id from invoices);

##方法二
select distinct client_id,name from clients
join invoices using(client_id);

###方法三 exists
select * from clients c
where exists                       ####在invoices表里出现过的client
		(select client_id from invoices
        where client_id = c.client_id);
        
###练习 找出从未被订购的商品
select * from products p
where not exists
		(select distinct product_id from order_items
        where product_id = p.product_id);


############     SELECT句中的subqueries     ###########
select invoice_id, 
       invoice_total,
       (select avg(invoice_total) from invoices) as invoice_average,
       invoice_total-(select invoice_average) as difference
       from invoices;
       
####练习 找出每位客户的sales total,并与平均相比
select client_id,
       name,
       (select sum(invoice_total) from invoices 
        where client_id = c.client_id) as total_sales,     #######用相关子查询！！！！
       (select avg(invoice_total) from invoices) as average,
       (select average)-(select total_sales) as difference
       from clients c;

##################    FROM句中的子查询    ######
####从之前做好的表中再查找
select * from
    (select client_id,
           name,
           (select sum(invoice_total) from invoices 
            where client_id = c.client_id) as total_sales,     #######用相关子查询！！！！
           (select avg(invoice_total) from invoices) as average,
           (select average)-(select total_sales) as difference
     from clients c) 
as sales_summary
where total_sales is not null
    
























