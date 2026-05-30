http://localhost:8080/EisebLFS/livestock

http://localhost:8080/EisebLFS/valuations

http://localhost:8080/EisebLFS/sales

http://localhost:8080/EisebLFS/expenses

http://localhost:8080/EisebLFS/reports

http://localhost:8080/EisebLFS/contact



cd /home/mammon/NetBeansProjects/EisebLFS
mvn clean package
cp target/EisebLFS.war ~/GlassFish_Server/glassfish/domains/domain1/autodeploy/