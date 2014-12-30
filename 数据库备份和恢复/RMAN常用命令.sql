﻿http://blog.csdn.net/tianlesoftware/article/details/4976998

报告数据库结构
	report schema;
  
  report {device, need, obsolete, schema, unrecoverable}
  
  report schema;
  report obsolete;
  report unrecoverable;--不可恢复的数据文件
  report need backup;
  report need backup days 3 或者指定表空间  report need backup days 3 tablespace users; --报告最近3天内没有备份的文件
  report need backup redundancy=3; --报告冗余次数（备份次数）小于3的数据文件。
  report need backup recovery window of 2 days;
 --报告出恢复需要2天归档日志的数据文件
  report need backup incremental=3;--需要多少个增量备份文件才能恢复的数据文件。(如果出问题，这些数据文件将需要3个增量备份才能恢复) 
  --需要进行完整备份
  
  report absolete redundancy 3;--超过3次的陈旧备份 可以采用delete absolete
  
    2.1.report schema;
    报告数据库模式

    22.report obsolete;
    报告已丢弃的备份集(配置了保留策略)。

    2.3.report unrecoverable;
    报告当前数据库中不可恢复的数据文件(即没有这个数据文件的备份、或者该数据文件的备份已经过期)

    2.4.report need backup;
    报告需要备份的数据文件(根据条件不同)
        report need backup days=3;
        --最近三天没有备份的数据文件(如果出问题的话，这些数据文件将需要最近3天的归档日志才能恢复)
        report need backup incremental=3;
        --需要多少个增量备份文件才能恢复的数据文件。(如果出问题，这些数据文件将需要3个增量备份才能恢复)
        report need backup redundancy=3;
        --报告出冗余次数小于3的数据文件
        --例如数据文件中包含2个数据文件system01.dbf和users01.dbf.
        --在3次或都3次以上备份中都包含system01.dbf这个数据文件，而users01.dbf则小于3次
        --那么，报告出来的数据文件就是users01.dbf
        --即，报告出数据库中冗余次数小于 n 的数据文件
        report need backup recovery window of 2 days;
        --报告出恢复需要2天归档日志的数据文件
  
列出数据文件备份集
 list backup of database;
	list backup of tablespace users;
  list backup of datafile 1,2,3;



LIST BACKUP tag='TAG20141202T051249'


LIST BACKUP 22;
LIST BACKUPSET; 好像backup和backupset是同一个概念

列出控制文件备份集	
	list backup of controlfile;
归档日志
	list backup of archivelog all;
SPFILE
	list backup of spfile;

RMAN>  SHOW CONTROLFILE AUTOBACKUP;

RMAN configuration parameters are:

CONFIGURE CONTROLFILE AUTOBACKUP OFF; # default
列出备份信息——LIST命令
　　LIST 命令用来查看通过RMAN生成的备份集、备份镜像、归档文件等，这个命令使用也比较简单，用LIST+相应关键字即可，例如：

•列出数据库中所有的备份信息：
RMAN> LIST BACKUP;

•列出所有备份的控制文件信息：
RMAN> LIST BACKUP OF CONTROLFILE;

•列出指定数据文件的备份信息：
RMAN> LIST BACKUP OF DATAFILE  ' F:\ORACLE\ORADATA\JSSBOOK\SCOTT_TBS01.DBF ' ;
　　或
RMAN> LIST BACKUP OF DATAFILE 5;
　　注：DATAFILE序号可以通过动态性能视图 V$DATAFILE 或数据字典 DBA_DATA_FILES 中查询。

•列出所有备份的归档文件信息：
RMAN> LIST BACKUP OF ARCHIVELOG ALL;

•列出指定表空间的备份信息：
RMAN> LIST COPY OF TABLESPACE  ' SYSTEM ' ;

•列出某个设备上的所有信息：
RMAN> LIST DEVICE TYPE DISK BACKUP;

•列出数据库当前所有归档：
RMAN> LIST ARCHIVELOG ALL;

•列出所有无效备份：
RMAN> LIST EXPIRED BACKUP;


--检查备份文件crosscheck

crosscheck BACKUP of database
crosscheck backup of tablespace users;
crosscheck backup of datafile 5;

crosscheck backup of controlfile;

--delete

用于删除RMAN备份记录及相应的物理文件。当使用RMAN执行备份操作时，会在RMAN资料库（RMAN Repository）中生成RMAN备份记录，默认情况下RMAN备份记录会被存放在目标数据库的控制文件中，如果配置了恢复目录（Recovery  C atalog ），那么该备份记录也会被存放到恢复目录中。

RMAN 中的DELETE命令就是用来删除记录（某些情况下并非删除记录，而是打上删除标记），以及这些记录关联的物理备份片段。

•删除过期备份。当使用RMAN命令执行备份操作时，RMAN会根据备份冗余策略确定备份是否过期。
RMAN> report obsolete
RMAN>  DELETE OBSOLETE;--DELETE noprompt OBSOLETE;

•删除无效备份。首先执行 CROSSCHECK 命令核对备份集，如果发现备份无效（比如备份对应的数据文件损坏或丢失），RMAN会将该备份集标记为EXPIRED状态。要删除相应的备份记录，可以执行 DELETE EXPIRED BACKUP 命令：
RAMN》 crosscheck archivelog all;
RMAN>  DELETE EXPIRED BACKUP;
•删除EXPIRED副本，如下所示：
RMAN>  DELETE EXPIRED COPY;

•删除特定备份集，如下所示：
RMAN>  DELETE BACKUPSET 19;

•删除特定备份片，如下所示：
RMAN>  DELETE BACKUPPIECE  ' d:\backup\DEMO_19.bak ' ;

•删除所有备份集，如下所示：
RMAN>  DELETE BACKUP;

•删除特定映像副本，如下所示：
RMAN>  DELETE DATAFILE COPY  ' d:\backup\DEMO_19.bak ' ;

•删除所有映像副本，如下所示：
RMAN>  DELETE COPY;

•在备份后删除输入对象，如下所示：
RMAN>  BACKUP ARCHIVELOG ALL DELETE INPUT;

RMAN>  DELETE BACKUPSET 22 FORMAT  =  'd:\backup\%u.bak'  DELETE INPUT;

--保存策略 (retention policy)
   configure retention policy to recovery window of 7 days;
   configure retention policy to redundancy 5;
   configure retention policy clear;
CONFIGURE RETENTION POLICY TO NONE;
第一种recover window是保持所有足够的备份，可以将数据库系统恢复到最近七天内的任意时刻。任何超过最近七天的数据库备份将被标记为obsolete。
第二种redundancy 是为了保持可以恢复的最新的5份数据库备份，任何超过最新5份的备份都将被标记为redundancy。它的默认值是1份。
第三四：NONE 可以把使备份保持策略失效，Clear 将恢复默认的保持策略

一般最安全的方法是采用第二种保持策略。

