#!/bin/bash

# =============================================================================
# Instalador gráfico do Koha - MODO SIMULAÇÃO (sem confirmações intermediárias)
# =============================================================================
# Este script apenas SIMULA os passos, não faz mudanças reais no sistema.
# =============================================================================

echo "-----------------------------------------------"
echo "     Instalador Koha - Modo Simulação"
echo "-----------------------------------------------"

# -----------------------------------------------------------------------------
# Simula instalação do Yad se não existir
# -----------------------------------------------------------------------------
if ! command -v yad &> /dev/null
then
    if command -v zenity &> /dev/null
    then
        zenity --question --title="Instalador do Koha (Simulação)" \
        --text="O programa Yad não está instalado.\nDeseja simular a instalação do Yad agora?"

        if [ $? -eq 0 ]; then
            (
                echo "10"
                echo "# Simulando atualização de pacotes..."
                sleep 1
                echo "50"
                echo "# Simulando instalação do Yad..."
                sleep 1
                echo "100"
            ) | zenity --progress --title="Instalando Yad (Simulação)" \
                       --percentage=0 --auto-close --width=400
        else
            zenity --error --title="Instalação cancelada" \
            --text="Sem o Yad, não é possível continuar. Saindo."
            exit 1
        fi
    else
        echo "O programa Yad não está instalado."
        read -p "Deseja simular a instalação do Yad agora? [s/N]: " resp
        if [[ "$resp" =~ ^[sS]$ ]]; then
            echo "Simulando sudo apt update && sudo apt install yad"
            sleep 2
        else
            echo "Sem o Yad não é possível continuar. Saindo."
            exit 1
        fi
    fi
else
    echo "Yad já está instalado! (Simulação)"
fi

# -----------------------------------------------------------------------------
# Passo 2 - Simular atualização do sistema
# -----------------------------------------------------------------------------
(
echo "10"
echo "# Simulando: sudo apt update"
sleep 1
echo "50"
echo "# Simulando: sudo apt upgrade -y"
sleep 1
echo "100"
echo "# Sistema 'atualizado' com sucesso (simulação)."
) | yad --progress \
         --title="Atualizando sistema (Simulação)" \
         --text="Iniciando atualização simulada do sistema..." \
         --percentage=0 --auto-close

# -----------------------------------------------------------------------------
# Passo 3 - Simular configuração das chaves do repositório do Koha
# -----------------------------------------------------------------------------
(
echo "10"
echo "# Simulando: instalar pacotes essenciais (apt-transport-https ca-certificates curl)"
sleep 1
echo "30"
echo "# Simulando: criar diretório para chaves (/etc/apt/keyrings)"
sleep 1
echo "50"
echo "# Simulando: baixar chave GPG do Koha"
sleep 1
echo "70"
echo "# Simulando: atualizar lista de pacotes (apt update)"
sleep 1
echo "90"
echo "# Simulando: atualizar pacotes (apt upgrade)"
sleep 1
echo "100"
echo "# Configuração das chaves concluída (simulação)."
) | yad --progress \
         --title="Configurando repositórios do Koha (Simulação)" \
         --text="Configurando as chaves GPG e repositórios do Koha..." \
         --percentage=0 --auto-close

# -----------------------------------------------------------------------------
# Passo 4 - Simular adição do repositório Koha 24.11 e atualização do apt
# -----------------------------------------------------------------------------
(
echo "10"
echo "# Simulando: adicionando arquivo do repositório Koha 24.11"
sleep 1
echo "50"
echo "# Simulando: atualizando lista de pacotes (apt update)"
sleep 1
echo "100"
echo "# Repositório Koha 24.11 configurado (simulação)."
) | yad --progress \
         --title="Configurando repositório Koha 24.11 (Simulação)" \
         --text="Adicionando repositório Koha versão 24.11..." \
         --percentage=0 --auto-close

# -----------------------------------------------------------------------------
# Passo 5 - Simular instalação do Apache2
# -----------------------------------------------------------------------------
(
echo "10"
echo "# Simulando: instalando apache2"
sleep 2
echo "100"
echo "# Apache2 'instalado' (simulação)."
) | yad --progress \
         --title="Instalando Apache2 (Simulação)" \
         --text="Instalando servidor web Apache2..." \
         --percentage=0 --auto-close

# -----------------------------------------------------------------------------
# Passo 6 - Simular instalação do MariaDB
# -----------------------------------------------------------------------------
(
echo "10"
echo "# Simulando: instalando mariadb-server"
sleep 2
echo "100"
echo "# MariaDB 'instalado' (simulação)."
) | yad --progress \
         --title="Instalando MariaDB (Simulação)" \
         --text="Instalando servidor de banco de dados MariaDB..." \
         --percentage=0 --auto-close

# -----------------------------------------------------------------------------
# Passo 7 - Simular instalação do koha-common
# -----------------------------------------------------------------------------
(
echo "10"
echo "# Simulando: instalando koha-common"
sleep 2
echo "100"
echo "# koha-common 'instalado' (simulação)."
) | yad --progress \
         --title="Instalando Koha (Simulação)" \
         --text="Instalando pacote koha-common..." \
         --percentage=0 --auto-close
# -----------------------------------------------------------------------------
# Passo 8 - Simular alteração das portas em koha-sites.conf
# -----------------------------------------------------------------------------

(
echo "10"
echo "# Simulando backup do arquivo /etc/koha/koha-sites.conf"
sleep 1
echo "40"
echo "# Simulando alteração da linha INTRAPORT=\"80\" para INTRAPORT=8080"
sleep 1
echo "70"
echo "# Simulando alteração da linha OPACPORT=\"80\" para OPACPORT=8888"
sleep 1
echo "100"
echo "# Simulação concluída: portas configuradas no arquivo."
) | yad --progress \
    --title="Configurando portas Koha (Simulação)" \
    --text="Simulando a alteração das portas INTRAPORT e OPACPORT no arquivo koha-sites.conf..." \
    --percentage=0 --auto-close

yad --info --title="Portas configuradas (Simulação)" \
    --text="As portas INTRAPORT e OPACPORT foram 'alteradas' para 8080 e 8888, respectivamente.\n\n(Nota: esta é uma simulação — nenhuma alteração real foi feita.)"

# -----------------------------------------------------------------------------
# Passo 9 - Simular configuração do Apache (mod_cgi, mod_rewrite, headers, proxy_http)
# -----------------------------------------------------------------------------

(
echo "10"
echo "# Simulando ativação do módulo CGI no Apache (a2enmod cgi)"
sleep 1
echo "40"
echo "# Simulando ativação do módulo mod_rewrite (a2enmod rewrite)"
sleep 1
echo "60"
echo "# Simulando ativação dos módulos headers e proxy_http (a2enmod headers proxy_http)"
sleep 1
echo "90"
echo "# Simulando reinício do Apache (service apache2 restart)"
sleep 1
echo "100"
echo "# Configuração do Apache simulada com sucesso."
) | yad --progress \
    --title="Configurando Apache (Simulação)" \
    --text="Simulando habilitação dos módulos CGI, rewrite, headers e proxy_http no Apache e reinício do serviço..." \
    --percentage=0 --auto-close

yad --info --title="Configuração do Apache (Simulação)" \
    --text="A configuração do Apache foi simulada com sucesso.\n\nNenhuma alteração real foi feita."


# -----------------------------------------------------------------------------
# Mensagem final única (após todos os passos)
# -----------------------------------------------------------------------------
yad --info --title="Instalação Simulada Concluída" \
    --text="Todos os passos foram concluídos com sucesso (simulação).\n\nObrigado por usar o instalador Koha!"

echo "-----------------------------------------------"
echo "Instalador Koha (Simulação) concluído."
echo "-----------------------------------------------"

exit 0
