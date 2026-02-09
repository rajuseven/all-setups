#!/bin/bash
# -----------------------------------------------------------
# Automated Apache Tomcat 9 Installation on Ubuntu
# Using latest Tomcat 9 (9.0.115)
# -----------------------------------------------------------

set -e  # Exit on any error

# ------------------ VARIABLES -------------------
TOMCAT_VERSION=9.0.115
INSTALL_DIR=/opt/tomcat
TOMCAT_USER=tomcat
TOMCAT_PASSWORD=raju123  # your chosen password

# ------------------ UPDATE & JAVA -------------------
echo "Updating system packages..."
sudo apt update -y
sudo apt upgrade -y

echo "Installing Java..."
sudo apt install -y openjdk-17-jdk wget curl

# ------------------ CREATE TOMCAT USER -------------------
echo "Creating Tomcat user..."
sudo useradd -m -U -d $INSTALL_DIR -s /bin/false $TOMCAT_USER || true

# ------------------ DOWNLOAD TOMCAT -------------------
echo "Downloading Tomcat $TOMCAT_VERSION..."
cd /tmp
wget https://downloads.apache.org/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

# ------------------ INSTALL TOMCAT -------------------
echo "Installing Tomcat..."
sudo mkdir -p $INSTALL_DIR
sudo tar xzf apache-tomcat-$TOMCAT_VERSION.tar.gz -C $INSTALL_DIR --strip-components=1

# ------------------ PERMISSIONS -------------------
echo "Setting permissions..."
sudo chown -R $TOMCAT_USER:$TOMCAT_USER $INSTALL_DIR
sudo chmod +x $INSTALL_DIR/bin/*.sh

# ------------------ CONFIGURE TOMCAT USER -------------------
echo "Configuring tomcat-users.xml..."
sudo tee $INSTALL_DIR/conf/tomcat-users.xml > /dev/null <<EOF
<tomcat-users>
  <role rolename="manager-gui"/>
  <role rolename="manager-script"/>
  <user username="$TOMCAT_USER" password="$TOMCAT_PASSWORD" roles="manager-gui,manager-script"/>
</tomcat-users>
EOF

# ------------------ SYSTEMD SERVICE -------------------
echo "Creating systemd service..."
sudo tee /etc/systemd/system/tomcat.service > /dev/null <<EOF
[Unit]
Description=Apache Tomcat Web Server
After=network.target

[Service]
Type=forking
User=$TOMCAT_USER
Group=$TOMCAT_USER
Environment="JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64"
Environment="CATALINA_PID=$INSTALL_DIR/temp/tomcat.pid"
Environment="CATALINA_HOME=$INSTALL_DIR"
Environment="CATALINA_BASE=$INSTALL_DIR"
ExecStart=$INSTALL_DIR/bin/startup.sh
ExecStop=$INSTALL_DIR/bin/shutdown.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# ------------------ START TOMCAT -------------------
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl enable tomcat

echo "----------------------------------------------------"
echo "Tomcat $TOMCAT_VERSION installed successfully!"
echo "Access it at http://<your-vm-ip>:8080"
echo "Username: $TOMCAT_USER | Password: $TOMCAT_PASSWORD"
echo "----------------------------------------------------"
FrajuF
