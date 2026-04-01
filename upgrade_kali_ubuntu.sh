#!/bin/bash
# 🧠 Upgrade inteligente para Ubuntu / Kali / Frankenstein híbrido
# Autor: Naldo DJ (versão adaptada)

LOG_FILE="/tmp/apt_update.log"

echo "=========================================================="
echo "🚀 Iniciando atualização — $(date)"
echo "=========================================================="

# Detecta distro
detect_distro() {
  if grep -qi kali /etc/os-release; then
    DISTRO="kali"
  elif grep -qi ubuntu /etc/os-release; then
    DISTRO="ubuntu"
  else
    DISTRO="unknown"
  fi

  echo "🧬 Distro detectada: $DISTRO"
}

# Corrigir keyrings conforme distro
fix_keys() {
  echo -e "\n🔑 Corrigindo keyrings..."

  sudo apt-get install --reinstall -y \
    gnupg gpgv ca-certificates

  case $DISTRO in
    kali)
      echo "🐉 Ajustando chaves do Kali..."
      sudo apt-get install --reinstall -y kali-archive-keyring
      ;;
    ubuntu)
      echo "🟠 Ajustando chaves do Ubuntu..."
      sudo apt-get install --reinstall -y ubuntu-keyring
      ;;
    *)
      echo "⚠️ Distro desconhecida — instalando ambos keyrings (modo gambiarra consciente)"
      sudo apt-get install --reinstall -y kali-archive-keyring ubuntu-keyring || true
      ;;
  esac

  sudo rm -rf /var/lib/apt/lists/*
}

# Detectar erro GPG
check_gpg_error() {
  grep -Eqi "gpg|NO_PUBKEY|EXPKEYSIG|BADSIG" "$LOG_FILE"
}

# Corrigir sources híbridos
fix_sources_warning() {
  echo -e "\n⚠️ Verificando mistura de repositórios..."

  if grep -qi kali /etc/apt/sources.list && grep -qi ubuntu /etc/apt/sources.list; then
    echo "🔥 Sistema híbrido detectado (Ubuntu + Kali)"
    echo "👉 Isso é instável por natureza. Seguindo com cuidado..."
  fi
}

# Atualização segura
safe_update() {
  echo -e "\n🔍 Atualizando lista de pacotes..."
  sudo apt-get clean
  sudo apt-get update 2>&1 | tee "$LOG_FILE"

  if check_gpg_error; then
    echo -e "\n❌ Erro GPG detectado — tentando corrigir..."
    fix_keys
    sudo apt-get update
  else
    echo -e "\n✅ Sem erros GPG."
  fi
}

# Upgrade
do_upgrade() {
  echo -e "\n⬆️ Atualizando pacotes..."
  sudo apt upgrade -y || true

  echo -e "\n🧩 Full upgrade (modo agressivo)..."
  sudo apt full-upgrade -y || true

  echo -e "\n🧹 Limpando..."
  sudo apt autoremove -y
  sudo apt autoclean
}

# Info final
show_info() {
  echo -e "\n🧠 Info do sistema:"
  if command -v neofetch >/dev/null 2>&1; then
    neofetch
  else
    echo "Instale: sudo apt install neofetch"
  fi
}

# Execução
detect_distro
fix_sources_warning
safe_update
do_upgrade
show_info

echo "=========================================================="
echo "✅ Finalizado — $(date)"
echo "=========================================================="
