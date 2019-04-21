echo "# Installing Tika"
#mkdir install
#curl https://codeload.github.com/apache/tika/zip/trunk -o trunk.zip
#unzip trunk.zip
#cd tika-trunk
#mvn -DskipTests=true clean install
#cp tika-server/target/tika-server-1.*-SNAPSHOT.jar /srv/tika-server-1.*-SNAPSHOT.jar



curl https://www-eu.apache.org/dist/tika/tika-server-1.20.jar -o tika-server.jar
