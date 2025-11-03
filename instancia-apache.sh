#!/bin/bash
set -e

# Actualizar sistema
sudo apt update -y
sudo apt upgrade -y

# Instalar Apache, UFW y Curl
sudo apt install -y apache2 ufw curl git

# Habilitar Apache en el arranque
sudo systemctl enable apache2
sudo systemctl start apache2

# Nombre del dominio (ajustar según tu grupo)
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
    <title>Proyecto de Migración AWS - $DOMINIO</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f0f4f8; text-align: center; padding-top: 50px; }
        h1 { color: #232F3E; }
        .container { max-width: 800px; margin: 0 auto; padding: 20px; }
        .service-box { background: white; margin: 15px 0; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h2 { color: #FF9900; }
        p { color: #333; font-size: 16px; line-height: 1.6; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Proyecto de Migración a AWS</h1>
        <div class="service-box">
            <h2>Almacenamiento de Objetos</h2>
            <p>Implementación de S3 para archivos estáticos</p>
        </div>
        <div class="service-box">
            <h2>Redes Seguras</h2>
            <p>Configuración de VPC y acceso seguro desde TECSUP</p>
        </div>
        <div class="service-box">
            <h2>Despliegue de Servidores</h2>
            <p>Servidor de prueba en EC2: $DOMINIO</p>
        </div>
    </div>
</body>
</html>
EOF

# Configurar VirtualHost sin restricción de IP
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
