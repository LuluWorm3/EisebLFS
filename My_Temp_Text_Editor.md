http://localhost:8080/EisebLFS/livestock

http://localhost:8080/EisebLFS/valuations

http://localhost:8080/EisebLFS/sales

http://localhost:8080/EisebLFS/expenses

http://localhost:8080/EisebLFS/reports

http://localhost:8080/EisebLFS/contact


re launch the app

cd /home/mammon/NetBeansProjects/EisebLFS
mvn clean package
cp target/EisebLFS.war ~/GlassFish_Server/glassfish/domains/domain1/autodeploy/


copy al files

cd /home/mammon/NetBeansProjects/EisebLFS

# Backend – all Java files
find src -name "*.java" -exec echo "==== {} ====" \; -exec cat {} \; > /tmp/eiseb_backend.txt 2>&1

# Frontend – all JSP, XML, CSS, JS
find src -name "*.jsp" -o -name "*.xml" -o -name "*.css" -o -name "*.js" | sort | while read f; do
  echo "==== $f ====" >> /tmp/eiseb_frontend.txt
  cat "$f" >> /tmp/eiseb_frontend.txt
done

echo "Backend: $(wc -l < /tmp/eiseb_backend.txt) lines"
echo "Frontend: $(wc -l < /tmp/eiseb_frontend.txt) lines"


PUSHING TO GIT
cd /home/mammon/NetBeansProjects/EisebLFS
git add .
git commit -m "Final audit fixes - HTML table validation, CSS cleanup, duplicate UI elements removed"
git push -u origin main

Safest method is to stash your local changes, pull, then reapply them.


cd /home/mammon/NetBeansProjects/EisebLFS

# 1. Stash your local commits (saves them temporarily)
git stash

# 2. Pull the remote changes and merge them
git pull origin main --no-rebase

# 3. Reapply your stashed changes
git stash pop

# 4. Push everything
git push -u origin main