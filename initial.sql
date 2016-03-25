-- create database uploads default charset utf8;
-- grant all on uploads.* to 'up'@'localhost' identified by 'upload';
use uploads

drop table if exists ctbUser;
create table ctbUser(
iUid int UNSIGNED PRIMARY KEY AUTO_INCREMENT,
iStatus tinyint default 1,
dtInsert timestamp DEFAULT CURRENT_TIMESTAMP,
chInsertby char(6),
dtUpdate timestamp ON UPDATE CURRENT_TIMESTAMP,
chUpdateby char(6),
chUserNo varchar(20) not null,
chUserCN varchar(50) not null,
iDept tinyint comment '1:admin;2:supervisor;11:ICT',
chUdf1 varchar(100),
chUdf2 varchar(100),
chUdf3 varchar(100),
chUdf4 varchar(100),
chUdf5 varchar(100),
constraint uk_ctbUser unique(chUserNo)
)ENGINE=InnoDB AUTO_INCREMENT=1001 DEFAULT CHARSET=utf8;

drop table if exists ctbPWD;
create table ctbPWD(
iUid int UNSIGNED PRIMARY KEY AUTO_INCREMENT,
dtInsert timestamp DEFAULT CURRENT_TIMESTAMP,
chInsertby char(6),
dtUpdate timestamp ON UPDATE CURRENT_TIMESTAMP,
chUpdateby char(6),
iUser int,
chPwd char(32),
encrypt char(4),
constraint uk_ctbPWD unique(iUser)
)ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

drop table if exists ctbLogs;
create table ctbLogs(
iUid int UNSIGNED PRIMARY KEY AUTO_INCREMENT,
dtInsert timestamp DEFAULT CURRENT_TIMESTAMP,
chOperator varchar(100) not null,
iSuccess tinyint not null,
chTag varchar(20),
chStep varchar(20),
chInfo varchar(100),
chUdf1 varchar(100),
chUdf2 varchar(100),
chUdf3 varchar(100),
chUdf4 varchar(100),
chUdf5 varchar(100)
)ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

delimiter //
DROP function IF EXISTS cfnGetUid//
create function cfnGetUid(v_user varchar(10))
returns int
BEGIN
set @re=0;
set @re=(select iUid from ctbUser where chUserNo=v_user limit 1);
return @re;
END//

drop procedure IF EXISTS cspUser_mod//
create procedure cspUser_mod(
v_iUid varchar(10),
v_Unit varchar(10),
v_chUnit varchar(50),
v_iDept int,
v_pwd varchar(50),
v_user int,
out iRet int) -- 0:false/1:success/2:exist userNo/3:no found
label_pro:BEGIN
	set iRet=0;
	if (select count(table_name) from information_schema.tables where table_name='ctbUser' or table_name='ctbPWD')<2 then
		leave label_pro;
	end if;
	if exists(select iUid from ctbUser where iUid<>v_iUid and chUserNo=v_Unit) then
		set iRet=2;
		leave label_pro;
	end if;
	if (not exists(select iUid from ctbUser where iUid=v_iUid and iStatus=1) and v_iUid<>'') then
		set iRet=3;
		leave label_pro;
	end if;
	if v_iUid='' then
		set @i=0;
		set @v='';
		while @i<4 do
			set @v=concat(@v,(select char( rand()*25+97 )));
			set @i:=@i+1;
		end while;
		insert into ctbUser(iStatus,chInsertby,chUpdateby,chUserNo,chUserCN,iDept,
							chUdf1,chUdf2,chUdf3,chUdf4,chUdf5)
		values(1,v_user,v_user,v_Unit,v_chUnit,v_iDept,null,null,null,null,null);
		if (v_pwd<>'') then
			insert into ctbPWD(iUser,chInsertby,chPwd,encrypt)
			values(LAST_INSERT_ID(),v_user,md5(concat(md5(v_pwd),@v)),@v);
		end if;
	else
		if v_Unit<>'' then
			update ctbUser set chUpdateby=v_user,chUserNo=v_Unit,chUserCN=v_chUnit,iDept=v_iDept
			where iUid=v_iUid;
		end if;
		if v_pwd<>'' then
			update ctbPWD set chUpdateby=v_user,chPwd=md5(concat(md5(v_pwd),encrypt)) where iUser=v_iUid;
		end if;
	end if;
	set iRet=1;
END//

drop procedure IF EXISTS cspUser_del//
create procedure cspUser_del(
v_eid varchar(10),
v_iStat tinyint,
v_user varchar(10),
out iRet int) -- 0:false/1:success/2:not exist
label_pro:BEGIN
	set iRet=0;
	if not exists(select table_name from information_schema.tables where table_name='ctbUser') then
		leave label_pro;
	end if;
	if not exists(select iUid from ctbUser where iUid=cfnGetUid(v_eid) and iStatus=abs(1-v_iStat)) then
		set iRet=2;
		leave label_pro;
	end if;
	update ctbUser set chUpdateby=v_user,iStatus=v_iStat where iUid=cfnGetUid(v_eid) and iStatus=abs(1-v_iStat);
	set iRet=1;
END//

drop procedure IF EXISTS cspUserCode_check//	-- id match code or code unused
create procedure cspUserCode_check(
v_eid varchar(10),
v_cd varchar(10),
out iRet tinyint) -- 0:useless/1:useful
label_pro:BEGIN
	set iRet=0;
	if not exists(select table_name from information_schema.tables where table_name='ctbUser') then
		leave label_pro;
	end if;
	if not exists(select iUid from ctbUser where chUserNo=v_cd and iUid<>v_eid) then
		set iRet=1;
	end if;
END//

DROP PROCEDURE IF EXISTS cspCheckLogin//
create procedure cspCheckLogin(
v_eid varchar(10),
v_chpwd varchar(20),
out iRet varchar(50)) -- 0:failure/UserID,UserName,DeptID
label_pro:BEGIN
	set iRet='0';
	if not exists(select table_name from information_schema.tables where table_name='ctbPWD') then
		leave label_pro;
	end if;
	if v_eid='' or v_chpwd='' then
		leave label_pro;
	end if;
	if exists (select iUid from ctbPWD where iUser=(select iUid from ctbUser where iStatus=1 and iUid=cfnGetUid(v_eid)) and chPwd=md5(concat(md5(v_chpwd),encrypt))) then
		set iRet= (select concat(iUid,'#',chUserNo,'#',chUserCN) from ctbUser where iUid=cfnGetUid(v_eid));
	end if;
END//

DROP PROCEDURE IF EXISTS cspLogs_ins//
create procedure cspLogs_ins(
v_sc tinyint,
v_tag varchar(20),
v_step varchar(20),
v_info varchar(100),
v_user varchar(50),
out iRet tinyint) -- 0:failure/1:true
label_pro:BEGIN
	set iRet=0;
	if not exists(select table_name from information_schema.tables where table_name='ctbLogs') then
		leave label_pro;
	end if;
	insert into ctbLogs(chOperator,iSuccess,chTag,chStep,chInfo)
	values(v_user,v_sc,v_tag,v_step,v_info);
	set iRet=1;
END//

/*
-- 				uid   no.     cn   dept |pwd |opt |return
call cspUser_mod('','96001','eric',11,'eric',0,@x);
call cspUser_mod('','96002','susan',11,'12345',0,@x);
call cspUser_mod('','96003','chris',11,'12345',0,@x);
call cspUser_mod('1002','96002','tina',11,'eric1234',0,@x);

--					uid   del|opt|return
-- call cspUser_del('96003',0,0,@x); 

call cspCheckLogin('96001','eric',@x);
select @ret;

call cspUserCode_check('1001','96002',@x);
select @ret;

call cspLogs_ins(1,'','login','',1001,@x);
*/
delimiter ;