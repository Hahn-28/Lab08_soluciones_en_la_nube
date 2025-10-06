#!/bin/bash
set -e

# Actualizar sistema
sudo apt update -y
sudo apt upgrade -y

# Instalar Apache
sudo apt install apache2 ufw curl -y

# Habilitar Apache en el arranque
sudo systemctl enable apache2
sudo systemctl start apache2

# Configurar dominio
DOMINIO="lab08castro.asesoresti.net"
sudo mkdir -p /var/www/$DOMINIO/public_html
sudo chown -R ubuntu:ubuntu /var/www/$DOMINIO/public_html
sudo chmod -R 755 /var/www

# Crear index.html
cat <<EOF | sudo tee /var/www/$DOMINIO/public_html/index.html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>$DOMINIO</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f0f4f8; text-align: center; padding-top: 80px; }
        h1 { color: #0073bb; }
        p { color: #333; font-size: 18px; }
    </style>
</head>
<body>
    <h1>Bienvenido a $DOMINIO</h1>
    <p>Servidor web configurado automáticamente con script en Amazon EC2.</p>
</body>
</html>
EOF

# Configuración de Apache con restricción de acceso
sudo bash -c "cat > /etc/apache2/sites-available/$DOMINIO.conf" <<EOL
<VirtualHost *:80>
    ServerAdmin admin@$DOMINIO
    ServerName $DOMINIO
    DocumentRoot /var/www/$DOMINIO/public_html

    <Directory /var/www/$DOMINIO/public_html>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require ip 45.236.45.0/24
        Require local
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL

# Activar sitio
sudo a2ensite $DOMINIO.conf
sudo a2dissite 000-default.conf
sudo apache2ctl configtest
sudo systemctl reload apache2

# Reglas de firewall
sudo ufw allow from 45.236.45.0/24 to any port 80
sudo ufw enable

# Probar respuesta
echo "Probando el sitio con curl..."
curl http://localhost

echo " Configuración completada correctamente para: $DOMINIO"
