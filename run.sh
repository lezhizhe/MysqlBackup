#!/bin/sh

#数据库信息
DB_HOST="localhost"
DB_PORT="3306"
DB_USER="root"
DB_PWD="123456"

#远程备份ftp相关信息
FTP_IP="10.0.1.18";
FTP_USER="ftpuser";
FTP_PASS="123456";
FTP_PORT="21";

MYSQL_PATH="/usr/bin"; #数据库程序路径
BACK_DIR="/data/backup/mysql"; #数据库备份目录

#生成对应日期目录
today=`date '+%Y_%m_%d'`;
curdate=`date '+%Y_%m_%d_%H'`;
todaydir="${BACK_DIR}/${today}";
curdir="${todaydir}/${curdate}";

#生成今天的目录备份结构
if [ ! -d "$curdir" ]; then
	mkdir -p "${curdir}";
else 
	rm -rf "${curdir}";
	mkdir -p "${curdir}";
fi
#获取数据库名称
database=`${MYSQL_PATH}/mysql -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PWD} -Ne "show databases"`;
#遍历数据库备份
for i in $database
	do
		if [ $i != "mysql" -a $i != "test" -a $i != "mydata" -a $i != "information_schema" -a $i != "performance_schema" ]; then
		${MYSQL_PATH}/mysqldump -h${DB_HOST} -P${DB_PORT} -u${DB_USER} -p${DB_PWD} --lock-tables=false $i | /bin/gzip > ${curdir}/$i.sql.gz
		echo $i;
		fi
	done

#将备份文件传输到远程FTP
/usr/bin/lftp $FTP_IP:$FTP_PORT <<END
user $FTP_USER $FTP_PASS
rmdir -f ${MONTH_AGO}
mkdir ${DATE}
cd ${DATE}
put ${DB_BAK_DIR}/${DATE}.sql.gz
put ${FILE_BAK_DIR}/${DATE}code.tar.gz bye
END
 
#删除一月之前的数据备份
weekago=`date -d '-30 days' +%Y_%m_%d`;
weekagodir="${BACK_DIR}/${weekago}";
if [ -d "$weekagodir" ]; then
	rm -rf "${weekagodir}";
fi
