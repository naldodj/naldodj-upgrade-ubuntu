#!/bin/bash
# 🧠 Script de atualização do Ubuntu com detecção e correção automática de erros GPG
# Autor: Naldo DJ
# Uso: chmod +x upgrade_ubuntu.sh && ./upgrade_ubuntu.sh

echo "=========================================================="
echo "🚀 Iniciando atualização do sistema — $(date)"
echo "=========================================================="

# Função para corrigir erros GPG automaticamente
fix_gpg_errors() {
  echo -e "\n⚙️  Corrigindo possíveis erros de assinatura GPG..."

  # Reinstalar pacotes críticos de verificação
  sudo apt-get install --reinstall gnupg gpgv ca-certificates debian-archive-keyring ubuntu-keyring -y

  # Limpar listas antigas
  sudo rm -rf /var/lib/apt/lists/*
  
  # Tentar recuperar chave padrão (se necessário)
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32 2>/dev/null || true

  echo -e "\n🔄 Tentando atualizar novamente após correção..."
  sudo apt update
}

# Função para checar se o erro GPG ocorreu
check_gpg_error() {
  grep -q "Unknown error executing gpgv" /tmp/apt_update.log
}

# Atualiza lista de pacotes e verifica erros
echo -e "\n🔍 Atualizando lista de pacotes..."
sudo apt-get clean
sudo apt-get update 2>&1 | tee /tmp/apt_update.log

if check_gpg_error; then
  echo -e "\n❌ Erro de assinatura GPG detectado!"
  fix_gpg_errors
else
  echo -e "\n✅ Nenhum erro GPG detectado."
fi

# Mostra pacotes atualizáveis
echo -e "\n📦 Verificando pacotes que podem ser atualizados..."
upgradable=$(apt list --upgradable 2>/dev/null | grep -v Listing)

if [ -z "$upgradable" ]; then
  echo "✨ Todos os pacotes estão atualizados."
else
  echo "$upgradable"

  echo -e "\n⬆️  Atualizando pacotes..."
  sudo apt upgrade -y

  echo -e "\n🧩 Fazendo atualização completa do sistema..."
  sudo apt full-upgrade -y

  echo -e "\n🧹 Limpando pacotes antigos e desnecessários..."
  sudo apt autoremove -y
  sudo apt autoclean
fi

# Exibir versão e informações do sistema
echo -e "\n🧠 Exibindo informações do sistema:"
if command -v neofetch >/dev/null 2>&1; then
  neofetch
else
  echo "(neofetch não encontrado — instale com: sudo apt install neofetch)"
fi

echo "=========================================================="
echo "✅ Atualização finalizada — $(date)"
echo "=========================================================="
