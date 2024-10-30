###############第九章 存储过程 stored procedure
#################  9.2   创建存储过程
DELIMITER $$   ####将分隔符改成$$
create procedure get_clients()
BEGIN
    select * from clients;
END$$
DELIMITER ;   ###将分隔符变回;

###  call get_clients()   召唤此存储过程

####练习 创建一个叫“get_invoices_with_balance”的存储过程，
delimiter $$
create procedure get_invoiced_with_balance()
begin
    select * from invoices
    where invoice_total-payment_total > 0;
end$$
delimiter ;

###################  9.4 删除存储过程 drop procedure
drop procedure if exists get_clients;

###################  9.5 带参数
##建立一个存储过程 以州来调出客户
delimiter $$
create procedure get_clients_by_state(state char(2))
begin
    select * from clients
    where clients.state = state;
end$$
delimiter ;
call get_clients_by_state('CA');

###练习 建立一个存储过程 以客户来调出发票
delimiter $$
create procedure get_invoices_by_client(client_id int)
begin
    select * from invoices
    where invoices.client_id = client_id;
end$$
delimiter ;
call get_invoices_by_client(1);


#################### 9.6 带默认值的参数
drop procedure if exists get_clients_by_state;
delimiter $$
create procedure get_clients_by_state(state char(2))
begin
    if state is null then set state='CA';    ###如果call时不输入具体state,则默认输出state='CA'的结果
    end if;
    select * from clients
    where clients.state = state;
end$$
delimiter ;
call get_clients_by_state(null);

#####如果call时没有指定state，则输出全部客户   方法一
drop procedure if exists get_clients_by_state;
delimiter $$
create procedure get_clients_by_state(state char(2))
begin
    if state is null then             #####如果call时没有指定state，则输出全部客户
        select * from clients;
    else 
        select * from clients
        where clients.state = state;
    end if;
end$$
delimiter ;
call get_clients_by_state(null);

#####如果call时没有指定state，则输出全部客户   方法二 clever！！
drop procedure if exists get_clients_by_state;
delimiter $$
create procedure get_clients_by_state(state char(2))
begin
    select * from clients
    where clients.state = ifnull(state,clients.state);   ####ifnull()中第一个值为空值的话，将输出第二个值，即如果输入null,将输出clients表里的结果
end$$
delimiter ;
call get_clients_by_state(null);

##练习 创建一个带两个参数的存储过程‘get_payments’，client_id（int）和payment_method_id（tinyint）
drop procedure if exists get_payments;
delimiter $$
create procedure get_payments(client_id int,payment_method_id tinyint)
begin
    select * from payments
    where payments.client_id = ifnull(client_id,payments.client_id)
    and payments.payment_method = ifnull(payment_method_id,payments.payment_method);
end$$
delimiter ;
call get_payments(null,null);


####################### 9.7 更改数据并验证参数 
###更改某一指定invoice_id的其它数据
delimiter $$
create procedure make_payment(
    invoice_id int,
    payment_amount decimal(9,2),
    payment_date date
)
begin
    update invoices
    set invoices.payment_total=payment_amount,    ##更改项
        invoices.payment_date=payment_date        ##更改项
    where invoices.invoice_id=invoice_id;         ##指定 
end$$
delimiter ;

####################### 9.8 输出参数
drop procedure if exists get_unpaid_invoices_for_client;
delimiter $$
create procedure get_unpaid_invoices_for_client(
    client_id int,                     ##需要人工输入client_id
    out invoices_count int,            ##输出
    out invoices_total decimal(9,2)    ##输出
)
begin
    select count(*),sum(invoice_total)
    into invoices_count,invoices_total   
    from invoices
    where invoices.client_id=client_id and payment_total=0;
end$$
delimiter ;


######################## 9.9 变量
drop procedure if exists get_risk_factor;
delimiter $$
create procedure get_risk_factor()
begin 
    declare risk_factor decimal(9,2) default 0;     ##declare先说明变量
    declare invoices_count int;
    declare invoices_total decimal(9,2);
    
    select count(*),sum(invoice_total)
    into invoices_count,invoices_total          ##自变量的来源
    from invoices;
    
    set risk_factor=(invoices_total/invoices_count)*5;   ##因变量与自变量的关系
    
    select risk_factor;      ##输出的是risk_factor
end$$
delimiter ;


############################# 9.10 函数
drop function if exists get_risk_factor_for_client;
delimiter $$
CREATE FUNCTION get_risk_factor_for_client(client_id int) 
RETURNS int
    READS SQL DATA      ###有三种 deterministic、READS SQL DATA、modifies sql data
BEGIN
	declare risk_factor decimal(9,2) default 0;     ##declare先说明变量
    declare invoices_count int;
    declare invoices_total decimal(9,2);
    
    select count(*),sum(invoice_total)
    into invoices_count,invoices_total          ##自变量的来源
    from invoices
    where invoices.client_id=client_id;
    
    set risk_factor=(invoices_total/invoices_count)*5;   ##因变量与自变量的关系

RETURN ifnull(risk_factor,0);
END$$
delimiter ;

select 
    client_id,
    name,
    get_risk_factor_for_client(client_id) as risk_factor
from clients


