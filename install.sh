#!/bin/bash

# CPU Cooler Controller - Go Version Installer
# Resilient installer for Linux

set -e

echo "🚀 Iniciando instalação do CPU Cooler Controller (Go)..."

# 1. Verificar dependências de build
if ! command -v go &> /dev/null; then
    echo "❌ Erro: Go não encontrado. Instale o Go (1.21+) primeiro."
    exit 1
fi

# Verificar libhidapi-dev (necessária para CGO)
if ! ldconfig -p | grep libhidapi-hidraw &> /dev/null; then
    echo "⚠️  Aviso: libhidapi-dev parece não estar instalada."
    echo "Tente: sudo apt install libhidapi-dev (Debian/Ubuntu) ou sudo dnf install hidapi-devel (Fedora)"
    read -p "Deseja continuar mesmo assim? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 2. Compilar o projeto
echo "📦 Compilando binário..."
go build -o cpu-cooler main.go
echo "✅ Binário 'cpu-cooler' gerado."

# 3. Configurar UDEV Rules
UDEV_FILE="/etc/udev/rules.d/99-cpu-cooler.rules"
echo "🔧 Configurando permissões USB (UDEV)..."
cat <<EOF | sudo tee $UDEV_FILE > /dev/null
SUBSYSTEMS=="usb", ATTRS{idVendor}=="5131", ATTRS{idProduct}=="2007", MODE="0666", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="cpu-cooler.service"
EOF

sudo udevadm control --reload-rules
sudo udevadm trigger
echo "✅ Regras UDEV instaladas em $UDEV_FILE"

# 4. Instalar binário globalmente
echo "🚚 Instalando binário em /usr/local/bin..."
sudo mv cpu-cooler /usr/local/bin/cpu-cooler
sudo chmod +x /usr/local/bin/cpu-cooler

# 5. Configurar Systemd User Service
SERVICE_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="$SERVICE_DIR/cpu-cooler.service"

echo "⚙️  Configurando serviço systemd (user)..."
mkdir -p "$SERVICE_DIR"

cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=CPU Cooler LCD Display Controller
After=network.target

[Service]
ExecStart=/usr/local/bin/cpu-cooler
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable cpu-cooler
systemctl --user start cpu-cooler

echo "✅ Serviço systemd ativado!"

echo ""
echo "🎉 Instalação concluída com sucesso!"
echo "Acompanhe os logs com: journalctl --user -u cpu-cooler -f"
