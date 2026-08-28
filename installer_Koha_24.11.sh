#!/usr/bin/env bash

# =============================================================================
# Instalador gráfico do Koha - MODO SIMULAÇÃO (Ações do sistema comentadas)
# =============================================================================
# ATENÇÃO: Os comandos do sistema estão comentados com # para segurança.
# Para aplicar as mudanças na VM, descomente os comandos reais conforme necessário.
# =============================================================================

# -----------------------------------------------------------------------------
# Passo 1: Instalação do Yad se não existir
# -----------------------------------------------------------------------------
if ! command -v yad &> /dev/null
then
    if command -v zenity &> /dev/null
    then
        zenity --question --title="Instalador do Koha" \
        --text="O programa Yad não está instalado.\nDeseja instalar o Yad agora?"

        if [ $? -eq 0 ]; then
            (
                echo "10"
                echo "# Atualizando pacotes..."
                # sudo apt update
                sleep 1
                echo "50"
                echo "# Instalando Yad..."
                # sudo apt install -y yad
                sleep 2
                echo "100"
            ) | zenity --progress --title="Instalando Yad" \
                       --percentage=0 --auto-close --width=400
        else
            zenity --error --title="Instalação cancelada" \
            --text="Sem o Yad, não é possível continuar. Saindo."
            exit 1
        fi
    else
        echo "O programa Yad não está instalado."
        read -p "Deseja instalar o Yad agora? [s/N]: " resp
        if [[ "$resp" =~ ^[sS]$ ]]; then
            echo "Executando: sudo apt update && sudo apt install -y yad"
            # sudo apt update
            # sudo apt install -y yad
            sleep 2
        else
            echo "Sem o Yad não é possível continuar. Saindo."
            exit 1
        fi
    fi
else
    echo "Yad já está instalado!"
fi

# -----------------------------------------------------------------------------
# Passo 2: Detectar distro e versão
# -----------------------------------------------------------------------------
if [ -f /etc/os-release ]; then
    DISTRO_ID=$(grep -E '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]')
    DISTRO_VERSION=$(grep -E '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
    
    if [ -z "$DISTRO_ID" ] || [ -z "$DISTRO_VERSION" ]; then
        yad --error --title="Erro" \
            --text="⚠️ Não foi possível identificar completamente sua distribuição Linux.\nA instalação será abortada."
        exit 1
    fi
else
    yad --error --title="Erro" \
        --text="⚠️ Não foi possível identificar sua distribuição Linux.\nA instalação será abortada."
    exit 1
fi

if [[ "$DISTRO_ID" == "debian" && ( "$DISTRO_VERSION" == "12" || "$DISTRO_VERSION" == "11" ) ]] || \
   [[ "$DISTRO_ID" == "ubuntu" && ( "$DISTRO_VERSION" == "24.04" || "$DISTRO_VERSION" == "22.04" ) ]]; then

    yad --question --title="Sistema Detectado" \
        --text="✅ Sistema detectado: <b>$DISTRO_ID $DISTRO_VERSION</b>\n\nEste sistema é suportado oficialmente.\nDeseja prosseguir com a instalação?" \
        --button="Cancelar:1" --button="<b>Prosseguir</b>:0" || exit 1
else
    yad --question --title="Compatibilidade do Koha 24.11" \
        --text="⚠️ Seu sistema foi detectado como:\n\n<b>$DISTRO_ID $DISTRO_VERSION</b>\n\nNão está na lista oficial de suporte do Koha 24.11.\nDeseja prosseguir mesmo assim?" \
        --button="Cancelar:1" --button="<b>Prosseguir</b>:0" || exit 1
fi

# -----------------------------------------------------------------------------
# Passo 3: Atualização do sistema
# -----------------------------------------------------------------------------
(
echo "10"
echo "# Executando: sudo apt update"
# sudo apt update
sleep 2
echo "50"
echo "# Executando: sudo apt upgrade -y"
# sudo apt upgrade -y
sleep 3
echo "100"
echo "# Sistema atualizado com sucesso."
) | yad --progress \
         --title="Atualizando sistema" \
         --text="Iniciando atualização do sistema..." \
         --percentage=0 --auto-close

yad --question --title="Atualização do sistema" \
    --text="✅ A atualização da lista de pacotes e instalação concluídas.\nQuer prosseguir com a instalação?" \
    --button="Cancelar:1" --button="<b>Prosseguir</b>:0" || exit 1

# -----------------------------------------------------------------------------
# Passo 4: Configuração das chaves do repositório do Koha 24.11
# -----------------------------------------------------------------------------
(
echo "10"
echo "# Instalando pacotes essenciais..."
# sudo apt install -y apt-transport-https ca-certificates curl gnupg
sleep 2
echo "30"
echo "# Criando diretório para chaves..."
# sudo mkdir -p /etc/apt/keyrings
sleep 1
echo "50"
echo "# Baixando chave GPG do Koha..."
# curl -fsSL https://debian.koha-community.org/koha/gpg.asc | sudo gpg --dearmor -o /etc/apt/keyrings/koha.gpg --overwrite
sleep 2
echo "70"
echo "# Adicionando repositório Koha 24.11..."
# echo "deb [signed-by=/etc/apt/keyrings/koha.gpg] https://debian.koha-community.org/koha 24.11 main" | sudo tee /etc/apt/sources.list.d/koha.list
sleep 1
echo "90"
echo "# Atualizando lista de pacotes..."
# sudo apt update
sleep 2
echo "100"
echo "# Repositório e chaves configurados."
) | yad --progress \
         --title="Configurando repositórios do Koha" \
         --text="Configurando as chaves GPG e repositório Koha 24.11..." \
         --percentage=0 --auto-close

# -----------------------------------------------------------------------------
# Passos 5, 6 e 7: Instalação dos Serviços Base (Apache2, MariaDB e Koha Common)
# -----------------------------------------------------------------------------
(
echo "10"
echo "# Instalando Apache2..."
# sudo apt install -y apache2
sleep 2
echo "40"
echo "# Instalando MariaDB..."
# sudo apt install -y mariadb-server
# sudo systemctl start mariadb
# sudo systemctl enable mariadb
sleep 2
echo "70"
echo "# Instalando Koha-Common..."
# sudo apt install -y koha-common
sleep 3
echo "100"
echo "# Serviços base instalados com sucesso."
) | yad --progress \
         --title="Instalando Serviços Base" \
         --text="Instalando Apache2, MariaDB e Koha-Common..." \
         --percentage=0 --auto-close

# -----------------------------------------------------------------------------
# Passo 8: Configuração das portas
# -----------------------------------------------------------------------------
check_port() {
    local port=$1
    if command -v ss &>/dev/null; then
        ss -tuln | grep -qE ":$port\s" && return 1 || return 0
    else
        (echo > /dev/tcp/127.0.0.1/"$port") &>/dev/null && return 1 || return 0
    fi
}

INTRAPORT=""
OPACPORT=""
PORT_SET=""

if check_port 8080 && check_port 8888; then
    INTRAPORT=8080; OPACPORT=8888; PORT_SET="Conjunto 1: 8080/8888"
elif check_port 9080 && check_port 9123; then
    INTRAPORT=9080; OPACPORT=9123; PORT_SET="Conjunto 2: 9080/9123"
elif check_port 9876 && check_port 12021; then
    INTRAPORT=9876; OPACPORT=12021; PORT_SET="Conjunto 3: 9876/12021"
else
    yad --error --title="Erro - Portas não disponíveis" \
        --text="Nenhuma combinação de portas livre (8080/8888, 9080/9123, 9876/12021)."
    exit 1
fi

yad --info --title="Configuração das Portas" \
    --text="Portas disponíveis para o Koha:\n\n$PORT_SET\n\n• INTRAPORT (Staff): $INTRAPORT\n• OPACPORT (OPAC): $OPACPORT"

(
echo "10"
echo "# Fazendo backup do koha-sites.conf..."
# sudo cp /etc/koha/koha-sites.conf /etc/koha/koha-sites.conf.backup
sleep 1
echo "50"
echo "# Configurando INTRAPORT para $INTRAPORT e OPACPORT para $OPACPORT..."
# sudo sed -i "s/^INTRAPORT=.*/INTRAPORT=\"$INTRAPORT\"/" /etc/koha/koha-sites.conf
# sudo sed -i "s/^OPACPORT=.*/OPACPORT=\"$OPACPORT\"/" /etc/koha/koha-sites.conf
sleep 1
echo "100"
echo "# Portas configuradas no arquivo koha-sites.conf."
) | yad --progress \
    --title="Configurando portas Koha" \
    --text="Configurando INTRAPORT e OPACPORT..." \
    --percentage=0 --auto-close

# -----------------------------------------------------------------------------
# Passo 9: Configuração de Módulos do Apache
# -----------------------------------------------------------------------------
(
echo "10"
echo "# Habilitando módulos do Apache (cgi, rewrite, headers, proxy_http, deflate)..."
# sudo a2enmod cgi rewrite headers proxy_http deflate
sleep 2
echo "70"
echo "# Reiniciando Apache..."
# sudo systemctl restart apache2
sleep 2
echo "100"
echo "# Módulos do Apache habilitados."
) | yad --progress \
    --title="Configurando Apache" \
    --text="Habilitando módulos essenciais no Apache..." \
    --percentage=0 --auto-close

# -----------------------------------------------------------------------------
# Passo 10 e 11: Criar instância, Plack e Tradução
# -----------------------------------------------------------------------------
INSTANCE_NAME=""
KOHA_PASS="[Senha aparecerá aqui ao descomentar os comandos]"

yad --question --title="Criar instância do Koha?" \
    --text="Deseja criar uma instância do Koha agora?"

if [ $? -eq 0 ]; then
    INSTANCE_NAME=$(yad --entry --title="Nome da Instância" \
        --text="Digite o nome da instância do Koha:" \
        --entry-text="biblioteca")
    
    if [ -n "$INSTANCE_NAME" ]; then
        (
        echo "10"
        echo "# Criando instância: $INSTANCE_NAME..."
        # sudo koha-create --create-db "$INSTANCE_NAME"
        sleep 2
        echo "40"
        echo "# Habilitando e iniciando Plack..."
        # sudo koha-plack --enable "$INSTANCE_NAME"
        # sudo koha-plack --start "$INSTANCE_NAME"
        sleep 2
        echo "70"
        echo "# Instalando tradução pt-BR..."
        # sudo koha-translate --install pt-BR
        sleep 2
        echo "90"
        echo "# Ajustando sites do Apache..."
        # sudo a2dissite 000-default
        # sudo a2ensite "$INSTANCE_NAME"
        # sudo systemctl reload apache2
        sleep 1
        echo "100"
        echo "# Instância '$INSTANCE_NAME' configurada com sucesso!"
        ) | yad --progress \
             --title="Criando Instância do Koha" \
             --text="Criando e configurando instância: $INSTANCE_NAME..." \
             --percentage=0 --auto-close
        
        # Recuperação de senha real (comentada)
        # KOHA_PASS=$(sudo koha-passwd "$INSTANCE_NAME")
    fi
fi

# -----------------------------------------------------------------------------
# Passo 12: Liberar portas no ports.conf do Apache
# -----------------------------------------------------------------------------
(
echo "10"
echo "# Verificando e liberando portas $INTRAPORT e $OPACPORT no Apache..."
# grep -q "Listen $INTRAPORT" /etc/apache2/ports.conf || echo "Listen $INTRAPORT" | sudo tee -a /etc/apache2/ports.conf
# grep -q "Listen $OPACPORT" /etc/apache2/ports.conf || echo "Listen $OPACPORT" | sudo tee -a /etc/apache2/ports.conf
sleep 2
echo "80"
echo "# Reiniciando Apache2..."
# sudo systemctl restart apache2
sleep 1
echo "100"
echo "# Apache escutando nas portas $INTRAPORT e $OPACPORT."
) | yad --progress \
         --title="Configurando portas do Apache" \
         --text="Liberando portas $INTRAPORT e $OPACPORT no ports.conf..." \
         --percentage=0 --auto-close

# -----------------------------------------------------------------------------
# Passo 13: Tela Final de Acesso
# -----------------------------------------------------------------------------
IP_MACHINE=$(hostname -I | awk '{print $1}')

yad --info \
    --title="Instalação Web do Koha" \
    --width=480 \
    --text="<b>Instalação Pronta para o Instalador Web</b>\n\n"\
"• <b>Acesso Interno (Staff):</b>\n<a href='http://localhost:$INTRAPORT'>http://localhost:$INTRAPORT</a>\n\n"\
"• <b>Acesso em Rede:</b>\n<a href='http://$IP_MACHINE:$INTRAPORT'>http://$IP_MACHINE:$INTRAPORT</a>\n\n"\
"• <b>Catálogo OPAC:</b>\n<a href='http://localhost:$OPACPORT'>http://localhost:$OPACPORT</a>\n\n"\
"<b>Credenciais Iniciais:</b>\n"\
"• Usuário: <code>koha_$INSTANCE_NAME</code>\n"\
"• Senha: <code>$KOHA_PASS</code>\n\n"\
"<i>Aba do navegador pronta para ser finalizada no instalador web após executar na VM.</i>"

exit 0