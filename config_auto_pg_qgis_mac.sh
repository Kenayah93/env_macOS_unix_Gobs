#!/bin/bash

# Fichier source 
SRC_FILE="/Users/hbngoukoulou/gobs/postgresql/pg_service.conf"


# copie vers .pg_service.conf
cp "$SRC_FILE" "/Users/hbngoukoulou/gobs/postgresql/.pg_service.conf"
chmod 600 "/Users/hbngoukoulou/gobs/postgresql/.pg_service.conf"
echo "✅ ~/.pg_service.conf créé."


# Extraction des parametres
SERVICE=$(grep -oP '^\[\K[^\]]+' "$SRC_FILE")
HOST=$(grep '^host=' "$SRC_FILE" | cut -d= -f2)
PORT=$(grep '^port=' "$SRC_FILE" | cut -d= -f2)
DBNAME=$(grep '^dbname=' "$SRC_FILE" | cut -d= -f2)
USER=$(grep '^user=' "$SRC_FILE" | cut -d= -f2)
PASSWORD=$(grep '^password=' "$SRC_FILE" | cut -d= -f2)


# Creation du fichier .pgpass
echo "$HOST:$PORT:$DBNAME:$USER:$PASSWORD" > "/Users/hbngoukoulou/gobs/postgresql/pg_service.pgpass"
chmod 600 "/Users/hbngoukoulou/gobs/postgresql/pg_service.pgpass"
echo "✅ ~/.pgpass créé."


# creation duu fichier .plist pour macOS
PLIST="./Library/LaunchAgents/environment.pgservice.plist"
mkdir -p "./Library/LaunchAgents"

cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>environment.pgservice</string>
  <key>ProgramArguments</key>
  <array>
    <string>launchctl</string>
    <string>setenv</string>
    <string>PGSERVICEFILE</string>
    <string>/Users/hbngoukoulou/gobs/postgresql/.pg_service.conf</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
EOF


# charger la variable 
launchctl unload "$PLIST" 2>/dev/null
launchctl load "$PLIST"
echo "✅ Variable d'environnement PGSERVICEFILE chargée."


#verification 
echo "🔍 Vérification de la variable :"
launchctl getenv PGSERVICEFILE

echo "✅ Tout est prêt. Lance QGIS, choisis le service : $SERVICE"
