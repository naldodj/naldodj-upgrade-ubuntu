#!/bin/bash
# Atualiza a lista de pacotes e faz o upgrade dos pacotes instalados no sistema

# Permissões de execução
# chmod +x update_ubuntu.sh

# Mostrar a data e hora atuais
echo "Data e Hora: $(date)"

# Mostrar os pacotes que podem ser atualizados
echo -e "\nPacotes que podem ser atualizados:"
upgradable=$(apt list --upgradable 2>/dev/null | grep -v Listing)

if [ -z "$upgradable" ]; then
  echo "Todos os pacotes estão atualizados."
else
  echo "$upgradable"

  # Atualizar a lista de pacotes disponíveis
  echo -e "\nAtualizando a lista de pacotes..."
  sudo apt update

  # Atualizar os pacotes
  echo -e "\nAtualizando pacotes..."
  sudo apt upgrade -y

  # Fazer uma atualização completa do sistema
  echo -e "\nFazendo uma atualização completa do sistema..."
  sudo apt full-upgrade -y

  # Instalar os pacotes que podem ser atualizados
  echo -e "\nInstalando pacotes atualizáveis..."
  for pkg in $(echo "$upgradable" | awk -F/ '{print $1}'); do
    sudo apt-get install --only-upgrade -y "$pkg"
  done

  # Limpar pacotes antigos e desnecessários
  echo -e "\nLimpando pacotes antigos e desnecessários..."
  sudo apt autoremove -y
  sudo apt autoclean
fi

# Verificar a versão instalada e mostrar informações do sistema
echo -e "\nMostrando a versão instalada e informações do sistema:"
neofetch
