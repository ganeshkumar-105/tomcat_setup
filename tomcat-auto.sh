#!/bin/bash
# Ultimate auto-detect Tomcat setup with Manager & Host-Manager

TOMCAT="/opt/tomcat"
TOMCAT_USER=$(whoami)   # auto-detect current user
VER="9.0.73"
ADMIN="admin"
PASS="Admin@123"

# Stop old Tomcat
sudo pkill -f 'org.apache.catalina.startup.Bootstrap' 2>/dev/null

# Backup old Tomcat
[ -d "$TOMCAT" ] && sudo mv "$TOMCAT" "${TOMCAT}_old"

# Download & install clean Tomcat
cd /tmp
wget -q https://archive.apache.org/dist/tomcat/tomcat-9/v$VER/bin/apache-tomcat-$VER.tar.gz
tar -xzf apache-tomcat-$VER.tar.gz
sudo mv apache-tomcat-$VER "$TOMCAT"
sudo chown -R $TOMCAT_USER:$TOMCAT_USER "$TOMCAT"
sudo chmod -R 755 "$TOMCAT"

# Configure admin user
TOMCAT_USERS="$TOMCAT/conf/tomcat-users.xml"
sudo sed -i '/<\/tomcat-users>/d' $TOMCAT_USERS
sudo tee -a $TOMCAT_USERS > /dev/null <<EOL
<role rolename="manager-gui"/>
<role rolename="admin-gui"/>
<user username="$ADMIN" password="$PASS" roles="manager-gui,admin-gui"/>
</tomcat-users>
EOL

# Enable remote access
for app in manager host-manager; do
  ctx="$TOMCAT/webapps/$app/META-INF/context.xml"
  [ -f "$ctx" ] && sudo sed -i 's|<Valve className="org.apache.catalina.valves.RemoteAddrValve".*|<!-- RemoteAddrValve removed -->|' $ctx
done

# Start Tomcat
$TOMCAT/bin/startup.sh

echo "✅ Tomcat $VER ready!"
echo "Manager: http://<server-ip>:8080/manager/html"
echo "User/Pass: $ADMIN / $PASS"
echo "Old Tomcat (if any) backed up at ${TOMCAT}_old"
