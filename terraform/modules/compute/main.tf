# Fetch the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# Security Group for the web server
resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-web-sg"
  description = "Security group for web server allowing HTTP, HTTPS, and SSH"

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH access for GitHub Actions"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.project_name}-sg" })
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
#!/bin/bash
# 1. Update system and install basic tools
dnf update -y
dnf install -y git nodejs httpd mod_ssl

# 2. Install system graphics libraries (CRITICAL for chartjs-node-canvas in app.js)
dnf install -y cairo pango libjpeg-turbo giflib pixman pango-devel cairo-devel

# 3. Install PM2 to manage Node.js process in the background
npm install -g pm2

# 4. Generate Self-Signed certificate (Cognito requires HTTPS)
mkdir -p /etc/ssl/private /etc/ssl/certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/selfsigned.key \
  -out /etc/ssl/certs/selfsigned.crt \
  -subj "/C=PL/ST=State/L=City/O=Organization/CN=localhost"

# 5. Configure Apache as Reverse Proxy to port 3000
cat << 'CONFIG' > /etc/httpd/conf.d/express.conf
<VirtualHost *:80>
    ProxyPreserveHost On
    ProxyPass / http://localhost:3000/
    ProxyPassReverse / http://localhost:3000/
</VirtualHost>

<VirtualHost *:443>
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/selfsigned.key

    ProxyPreserveHost On
    ProxyPass / http://localhost:3000/
    ProxyPassReverse / http://localhost:3000/
</VirtualHost>
CONFIG

# 6. Start Apache and enable autostart
systemctl start httpd
systemctl enable httpd

# 7. Prepare application directory for GitHub Actions
mkdir -p /var/www/app
chown -R ec2-user:ec2-user /var/www/app
EOF

  tags = merge(var.tags, { Name = "${var.project_name}-web-server" })
}