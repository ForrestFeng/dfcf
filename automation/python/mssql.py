#coding=utf-8
#!/usr/bin/env python
#-------------------------------------------------------------------------------
# Name: pymssqlTest.py
# Purpose: 测试 pymssql库，该库到这里下载：http://www.lfd.uci.edu/~gohlke/pythonlibs/#pymssql
#
# Author: scott
#
# Created: 04/02/2012
#-------------------------------------------------------------------------------

import pymssql

class MSSQL:
    """
    对pymssql的简单封装
    pymssql库，该库到这里下载：http://www.lfd.uci.edu/~gohlke/pythonlibs/#pymssql
    使用该库时，需要在Sql Server Configuration Manager里面将TCP/IP协议开启

    注意事项：
    使用pymssql进行中文操作时候可能会出现中文乱码，我解决的方案是：

    文件头加上 #coding=utf8
    sql语句中有中文的时候进行encode
       insertSql = "insert into WeiBo([UserId],[WeiBoContent],[PublishDate]) values(1,'测试','2012/2/1')".encode("utf8")
     连接的时候加入charset设置信息
        pymssql.connect(host=self.host,user=self.user,password=self.pwd,database=self.db,charset="utf8")

    用法：

    """

    def __init__(self,host,user,pwd,db):
        self.host = host
        self.user = user
        self.pwd = pwd
        self.db = db

    def __GetConnect(self):
        """
        得到连接信息
        返回: conn.cursor()
        """
        if not self.db:
            raise(NameError,"没有设置数据库信息")
        self.conn = pymssql.connect(host=self.host,user=self.user,password=self.pwd,database=self.db,charset="utf8")
        cur = self.conn.cursor()
        if not cur:
            raise(NameError,"连接数据库失败")
        else:
            return cur

    def ExecQuery(self, sql, arg=None):
        """
        执行查询语句
        返回的是一个包含tuple的list，list的元素是记录行，tuple的元素是每行记录的字段

        调用示例：
                ms = MSSQL(host="localhost",user="sa",pwd="123456",db="PythonWeiboStatistics")
                resList = ms.ExecQuery("SELECT id,NickName FROM WeiBoUser")
                for (id,NickName) in resList:
                    print str(id),NickName
        """
        cur = self.__GetConnect()
        cur.execute(sql, arg)
        resList = cur.fetchall()
        print(resList)

        #查询完毕后必须关闭连接
        self.conn.close()
        return resList

    def ExecNonQuery(self,sql,arg=None):
        """
        执行非查询语句

        调用示例：
            cur = self.__GetConnect()
            cur.execute(sql)
            self.conn.commit()
            self.conn.close()
        """
        cur = self.__GetConnect()
        cur.execute(sql, arg)
        self.conn.commit()
        self.conn.close()

def main():
## ms = MSSQL(host="localhost",user="sa",pwd="123456",db="PythonWeiboStatistics")
## #返回的是一个包含tuple的list，list的元素是记录行，tuple的元素是每行记录的字段
## ms.ExecNonQuery("insert into WeiBoUser values('2','3')")

    ms = MSSQL(host="localhost", user="sa", pwd="Health123", db="Dfcf")
    dir(ms)


    query = '''SELECT *  FROM [Dfcf].[dbo].[Test]'''
    try:
        resList = ms.ExecQuery(query)
        print(len(resList))
        for (id, weibocontent) in resList:
            print(str(weibocontent).decode("utf8"))
    except Exception as e:
        print(e)

if __name__ == '__main__':
    main()

#(20009, b'DB-Lib error message 20009, severity 9:\nUnable to connect: Adaptive Server is unavailable or does not exist\nNet-Lib error during Unknown error (10035)\n')
#[Finished in 60.5s]

#http://stackoverflow.com/questions/7317195/mssql-in-python-2-7
