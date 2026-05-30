cd /home/mammon/NetBeansProjects/EisebLFS

echo "===== PROJECT STRUCTURE ====="
find src -type f | sort

echo ""
echo "===== web.xml ====="
cat src/main/webapp/WEB-INF/web.xml

echo ""
echo "===== nav.jsp ====="
cat src/main/webapp/WEB-INF/nav.jsp

echo ""
echo "===== SERVLETS ====="
for f in src/main/java/com/eiseb/servlet/*.java; do
  echo "----- $(basename $f) -----"
  cat "$f"
done

echo ""
echo "===== DAOs ====="
for f in src/main/java/com/eiseb/dao/*.java; do
  echo "----- $(basename $f) -----"
  cat "$f"
done

echo ""
echo "===== UTILS ====="
for f in src/main/java/com/eiseb/util/*.java; do
  echo "----- $(basename $f) -----"
  cat "$f"
done

echo ""
echo "===== JSP PAGES ====="
for f in src/main/webapp/pages/*.jsp src/main/webapp/index.jsp; do
  echo "----- $(basename $f) -----"
  cat "$f"
done

echo ""
echo "===== pom.xml ====="
cat pom.xml