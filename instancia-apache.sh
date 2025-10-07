#!/bin/bash
set -e

# Actualizar sistema
sudo apt update -y
sudo apt upgrade -y

# Instalar Apache, UFW y Curl
sudo apt install -y apache2 ufw curl

# Habilitar Apache en el arranque
sudo systemctl enable apache2
sudo systemctl start apache2

# Nombre del dominio (será apuntado por el profesor)
DOMINIO="g27.castro.asesoresti.net"

# Crear estructura de directorios
sudo mkdir -p /var/www/$DOMINIO/public_html
sudo chown -R ubuntu:ubuntu /var/www/$DOMINIO/public_html
sudo chmod -R 755 /var/www/$DOMINIO

# Crear página web básica
cat <<EOF | sudo tee /var/www/$DOMINIO/public_html/index.html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Widget Inc. - $DOMINIO</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f0f4f8; text-align: center; padding-top: 80px; }
        h1 { color: #0073bb; }
        p { color: #333; font-size: 18px; }
    </style>
</head>
<body>
    <h1>Bienvenido a Widget Inc. Castro Hector :)</h1>
    <p>Servidor configurado automáticamente en Amazon EC2.</p>
    <p>Dominio: $DOMINIO</p>
</body>
</html>
EOF

# Configurar VirtualHost de Apache con restricción de acceso
sudo bash -c "cat > /etc/apache2/sites-available/$DOMINIO.conf" <<EOL
<VirtualHost *:80>
    ServerAdmin admin@$DOMINIO
    ServerName $DOMINIO
    DocumentRoot /var/www/$DOMINIO/public_html

    <Directory /var/www/$DOMINIO/public_html>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL

# Activar sitio y reiniciar Apache
sudo a2ensite $DOMINIO.conf
sudo a2dissite 000-default.conf
sudo apache2ctl configtest
sudo systemctl reload apache2
sudo systemctl restart apache2

# Configurar firewall UFW
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow ssh
sudo ufw --force enable

# Probar conexión interna
echo "Probando el sitio localmente..."
curl http://localhost || true

echo "Configuración completada correctamente para: $DOMINIO"
