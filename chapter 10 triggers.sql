############# 10.1 触发器  #############
##创建触发器 当对payments表插入新数据时，invoices表自动更新数据
delimiter $$
create trigger payment_after_insert
    after insert on payments      ####当对payments表插入数据后
    for each row
begin
    update invoices               ####更新invoices表的数据
    set payment_total = payment_total + new.amount   ####invoices表中的payment_total列更新成新插入的数据
    where invoice_id = new.invoice_id;
    end$$
delimiter ;
insert into payments
values (default,5,3,'2024-04-01',10,1);
    
####练习 create a trigger that gets fired when we delete a payment entry
delimiter $$
create trigger payment_after_delete
    after delete on payments
    for each row
begin
    update invoices
    set payment_total = payment_total - old.amount  ####用old.amount来代表被删除的数值
    where invoice_id = old.invoice_id;
    end$$
delimiter ;
delete from payments
where payment_id=9;


######################### 10.2 查看触发器  ####################
show triggers;
## or
show triggers like 'payments%';  ##加‘字符串%’只看相关的触发器


########################## 10.3 删除触发器
drop trigger if exists payments_after_   ;


#################### 10.4 使用触发器进行审计  ################
#更新invoices表后，使payments_audit表自动一条说明是新增或删除的记录
#新增
drop trigger if exists payment_after_insert;
delimiter $$
create trigger payment_after_insert
    after insert on payments      ####当对payments表插入数据后
    for each row
begin
    update invoices               ####更新invoices表的数据
    set payment_total = payment_total + new.amount   ####invoices表中的payment_total列更新成新插入的数据
    where invoice_id = new.invoice_id;
    
    insert into payments_audit
    values(new.client_id,new.date,new.amount,'Insert',now());
    
    end$$
delimiter ;
#删除
drop trigger if exists payment_after_delete; 
delimiter $$
create trigger payment_after_delete
    after delete on payments
    for each row
begin
    update invoices
    set payment_total = payment_total - old.amount  ####用old.amount来代表被删除的数值
    where invoice_id = old.invoice_id;
    
    insert into payments_audit
    values(old.client_id,old.date,old.amount,'Delete',now());
    
    end$$
delimiter ;
#检查audit表中是否有记录
insert into payments
values(default,5,3,'2024-04-01',10,1);
delete from payments
where payment_id=12;



################## 10.5 事件events ###############
show variables like 'event%';  ##查看event scheduler是否开启
##创建事件  将老旧audit记录删除
drop event if exists yearly_delete_stale_audit_rows;

delimiter $$
create event yearly_delete_stale_audit_rows   ##一般用时间频率来做前缀，方便找
on schedule     -- at '2024-5-01' ##一次    -- every 1 hour/day/week ect.  ##周期性
    every 1 year starts '2019-01-01' ends '2029-01-01'
do begin
    delete from payments_audit
    where action_date < now() - interval 1 year;
end $$
delimiter ;


################ 10.6 查看、删除、更改事件 ####################
show events like 'yearly%';
drop event if exists yearly_XXXXXX;
alter event yearly_delete_stale_audit_rows disable; ##停用或enable启动event











