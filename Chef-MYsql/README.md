#MYsql is mysql cookbook for chef 


##Dependencies 

mysql Cookbook https://github.com/chef-cookbooks/mysql



##Databags

Data bags are used to store the root user information for the mysql as rtpass.json


##Login 

mysql -S /var/run/mysql-mysql/mysqld.sock -u root -p
