installer_Koha.sh
@@ -1,217 +0,0 @@
#!/bin/bash

# =============================================================================
# Instalador gráfico do Koha - MODO REAL (ações comentadas para segurança)
# =============================================================================
# ATENÇÃO: Este script contém comandos reais do sistema!
# Descomente as linhas conforme necessário e execute com cuidado.
# =============================================================================

echo "-----------------------------------------------"
echo "     Instalador Koha - Modo Real"
echo "-----------------------------------------------"
echo "ATENÇÃO: As ações estão comentadas para segurança!"
echo "Descomente as linhas conforme necessário."
echo "-----------------------------------------------"

# -----------------------------------------------------------------------------
# Verifica se o usuário tem privilégios sudo
# -----------------------------------------------------------------------------
if ! sudo -n true 2>/dev/null; then
    echo "Este script precisa de privilégios sudo para funcionar."
    echo "Executando teste sudo..."
    sudo -v || exit 1
fi

# -----------------------------------------------------------------------------
# Instalação do Yad se não existir
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
# Passo 2 - Atualização do sistema
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

# -----------------------------------------------------------------------------
# Passo 3 - Configuração das chaves do repositório do Koha
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
# curl -fsSL https://debian.koha-community.org/koha/gpg.asc | sudo gpg --dearmor -o /etc/apt/keyrings/koha.gpg
sleep 2
echo "70"
echo "# Atualizando lista de pacotes..."
# sudo apt update
sleep 1
echo "90"
echo "# Atualizando pacotes..."
# sudo apt upgrade -y
sleep 2
echo "100"
echo "# Configuração das chaves concluída."
) | yad --progress \
         --title="Configurando repositórios do Koha" \
         --text="Configurando as chaves GPG e repositórios do Koha..." \
         --percentage=0 --auto-close

# -----------------------------------------------------------------------------
# Passo 4 - Adição do repositório Koha 24.11 e atualização do apt
# -----------------------------------------------------------------------------
(
echo "10"
echo "# Adicionando repositório Koha 24.11..."
#sudo tee /etc/apt/sources.list.d/koha.sources <<EOF
# Types: deb
# URIs: https://debian.koha-community.org/koha/
# Suites: 24.11
# Components: main
# Signed-By: /etc/apt/keyrings/koha.asc 
# EOF
sleep 1
echo "50"

echo "# Atualizando lista de pacotes..."
# sudo apt update
sleep 2
echo "100"
echo "# Repositório Koha 24.11 configurado."
) | yad --progress \
         --title="Configurando repositório Koha 24.11" \
         --text="Adicionando repositório Koha versão 24.11..." \
         --percentage=0 --auto-close

# -----------------------------------------------------------------------------
# Passo 5 - Instalação do Apache2
# -----------------------------------------------------------------------------
(
echo "10"
echo "# Instalando apache2..."
# sudo apt install -y apache2
sleep 3
echo "100"
echo "# Apache2 instalado com sucesso."
) | yad --progress \
         --title="Instalando Apache2" \
         --text="Instalando servidor web Apache2..." \
         --percentage=0 --auto-close

# -----------------------------------------------------------------------------
# Passo 6 - Instalação do MariaDB
# -----------------------------------------------------------------------------
(
echo "10"
echo "# Instalando mariadb-server..."
# sudo apt install -y mariadb-server
sleep 3
echo "50"
echo "# Iniciando serviço MariaDB..."
# sudo systemctl start mariadb
# sudo systemctl enable mariadb
sleep 1
echo "100"
echo "# MariaDB instalado e iniciado."
) | yad --progress \
         --title="Instalando MariaDB" \
         --text="Instalando servidor de banco de dados MariaDB..." \
         --percentage=0 --auto-close

# -----------------------------------------------------------------------------
# Passo 7 - Instalação do koha-common
# -----------------------------------------------------------------------------
(
echo "10"
echo "# Instalando koha-common..."
# sudo apt install -y koha-common
sleep 4
echo "100"
echo "# koha-common instalado com sucesso."
) | yad --progress \
         --title="Instalando Koha" \
         --text="Instalando pacote koha-common..." \
         --percentage=0 --auto-close

# -----------------------------------------------------------------------------
# Função para verificar se uma porta está em uso
# -----------------------------------------------------------------------------
check_port() {
    local port=$1
    if netstat -tuln | grep -q ":$port "; then
        return 1  # Porta em uso
    else
        return 0  # Porta livre
    fi
}

# -----------------------------------------------------------------------------
# Passo 8 - Configuração das portas com sequência específica
# -----------------------------------------------------------------------------

INTRAPORT=""
OPACPORT=""
PORT_SET=""

# Teste 1: Portas 8080 e 8888
if check_port 8080 && check_port 8888; then
    INTRAPORT=8080
    OPACPORT=8888
    PORT_SET="Conjunto 1: 8080/8888"
# Teste 2: Portas 9080 e 9123
elif check_port 9080 && check_port 9123; then
    INTRAPORT=9080
    OPACPORT=9123
    PORT_SET="Conjunto 2: 9080/9123"
# Teste 3: Portas 9876 e 12021
elif check_port 9876 && check_port 12021; then
    INTRAPORT=9876
    OPACPORT=12021
    PORT_SET="Conjunto 3: 9876/12021"
# Nenhuma combinação disponível
else
    yad --error --title="Erro - Portas não disponíveis" \
        --text="Nenhuma das combinações de portas está disponível:\n\n• Conjunto 1: 8080/8888\n• Conjunto 2: 9080/9123\n• Conjunto 3: 9876/12021\n\nPor favor, verifique quais portas estão em uso e libere uma das combinações antes de continuar."
    exit 1
fi

# Mostrar as portas que serão usadas
yad --info --title="Configuração das Portas" \
    --text="Portas TCP/IP disponíveis para o Koha:\n\n$PORT_SET\n\n• INTRAPORT (Staff): $INTRAPORT\n• OPACPORT (OPAC): $OPACPORT\n\nPressione OK para continuar com a configuração."

# Configurar as portas no arquivo koha-sites.conf
(
echo "10"
echo "# Fazendo backup do arquivo koha-sites.conf..."
# sudo cp /etc/koha/koha-sites.conf /etc/koha/koha-sites.conf.backup
sleep 1
echo "40"
echo "# Configurando INTRAPORT para $INTRAPORT..."
# sudo sed -i "s/INTRAPORT=\"80\"/INTRAPORT=\"$INTRAPORT\"/" /etc/koha/koha-sites.conf
sleep 1
echo "70"
echo "# Configurando OPACPORT para $OPACPORT..."
# sudo sed -i "s/OPACPORT=\"80\"/OPACPORT=\"$OPACPORT\"/" /etc/koha/koha-sites.conf
sleep 1
echo "100"
echo "# Portas configuradas no arquivo koha-sites.conf."
) | yad --progress \
    --title="Configurando portas Koha" \
    --text="Configurando as portas INTRAPORT e OPACPORT no arquivo koha-sites.conf..." \
    --percentage=0 --auto-close

yad --info --title="Portas configuradas com sucesso" \
    --text="As portas foram configuradas com sucesso!\n\n$PORT_SET\n• INTRAPORT (Staff): $INTRAPORT\n• OPACPORT (OPAC): $OPACPORT\n\nBackup salvo em: /etc/koha/koha-sites.conf.backup"

# -----------------------------------------------------------------------------
# Passo 9 - Configuração do Apache (mod_cgi, mod_rewrite, headers, proxy_http)
# -----------------------------------------------------------------------------
(
echo "10"
echo "# Habilitando módulo CGI no Apache..."
# sudo a2enmod cgi
sleep 1
echo "40"
echo "# Habilitando módulo mod_rewrite..."
# sudo a2enmod rewrite
sleep 1
echo "60"
echo "# Habilitando módulos headers e proxy_http..."
# sudo a2enmod headers proxy_http
sleep 1
echo "90"
echo "# Reiniciando Apache..."
# sudo systemctl restart apache2
sleep 2
echo "100"
echo "# Configuração do Apache concluída."
) | yad --progress \
    --title="Configurando Apache" \
    --text="Habilitando módulos CGI, rewrite, headers e proxy_http no Apache..." \
    --percentage=0 --auto-close

yad --info --title="Configuração do Apache" \
    --text="A configuração do Apache foi concluída com sucesso.\n\nMódulos habilitados: CGI, rewrite, headers, proxy_http"

# -----------------------------------------------------------------------------
# Passo 10 - Configuração final e criação de instância (opcional)
# -----------------------------------------------------------------------------
yad --question --title="Criar instância do Koha?" \
    --text="Deseja criar uma instância do Koha agora?\n\n(Isso criará um banco de dados e configurará o site)"

if [ $? -eq 0 ]; then
    # Solicita nome da instância
    INSTANCE_NAME=$(yad --entry --title="Nome da Instância" \
        --text="Digite o nome da instância do Koha:" \
        --entry-text="biblioteca")
    
    if [ ! -z "$INSTANCE_NAME" ]; then
        (
        echo "10"
        echo "# Criando instância: $INSTANCE_NAME"
        # sudo koha-create --create-db $INSTANCE_NAME
        sleep 3
        echo "50"
        echo "# Habilitando site no Apache..."
        # sudo a2ensite $INSTANCE_NAME
        sleep 1
        echo "80"
        echo "# Recarregando Apache..."
        # sudo systemctl reload apache2
        sleep 1
        echo "100"
        echo "# Instância criada com sucesso!"
        ) | yad --progress \
             --title="Criando instância do Koha" \
             --text="Criando instância: $INSTANCE_NAME" \
             --percentage=0 --auto-close
        
        # Obter senha do usuário koha_admin
        # KOHA_PASS=$(sudo koha-passwd $INSTANCE_NAME)
        
        yad --info --title="Instância criada" \
            --text="Instância '$INSTANCE_NAME' criada com sucesso!\n\nCopie e salve as informações abaixo para posterior acesso ao banco de dados do KOha\nUsuário: koha_$INSTANCE_NAME\nSenha: [descomente o comando koha-passwd para obter]"
    fi
fi

# -----------------------------------------------------------------------------
# Passo 11 - Definir um módulo do Apache para trabalhos do koha-plack
# -----------------------------------------------------------------------------

# Defina a instância do Koha aqui

(
echo "10"
echo "# Habilitando o plack para a instância '$INSTANCE_NAME'..."
# sudo koha-plack --enable "$INSTANCE_NAME"
sleep 2

echo "50"
echo "# Iniciando o plack para a instância '$INSTANCE_NAME'..."
# sudo koha-plack --start "$INSTANCE_NAME"
sleep 2

echo "80"
echo "# Reiniciando o Apache2 para aplicar alterações..."
# sudo service apache2 restart
sleep 2

echo "100"
echo "# Módulo do Koha-Plack configurado com sucesso para '$INSTANCE_NAME'."
) | yad --progress \
         --title="Configurando Koha-Plack" \
         --text="Configurando módulo Plack do Apache para o Koha..." \
         --percentage=0 --auto-close

# -----------------------------------------------------------------------------
# Passo 12 - Instalar a tradução do Português BR
# -----------------------------------------------------------------------------
(
echo "10"
echo "# Instalando tradução para Português do Brasil (pt-BR)..."
# sudo koha-translate --install pt-BR
sleep 2

echo "100"
echo "# Tradução pt-BR instalada com sucesso."
) | yad --progress \
         --title="Instalando tradução pt-BR" \
         --text="Instalando tradução do Koha para Português do Brasil..." \
         --percentage=0 --auto-close

# -----------------------------------------------------------------------------
# Passo 13 - Configurar módulos e sites
# -----------------------------------------------------------------------------
(
echo "10"
echo "# Desabilitando site padrão do Apache (000-default)..."
# sudo a2dissite 000-default
sleep 2

echo "30"
echo "# Habilitando módulo Deflate do Apache..."
# sudo a2enmod deflate
sleep 2

echo "60"
echo "# Habilitando site do Apache para o Koha: '$INSTANCE_NAME'..."
# sudo a2ensite "$INSTANCE_NAME"
sleep 2

echo "90"
echo "# Reiniciando Apache2 para aplicar alterações..."
# sudo service apache2 restart
sleep 2

echo "100"
echo "# Configuração de módulos e sites concluída para '$INSTANCE_NAME'."
) | yad --progress \
         --title="Configurando Apache para Koha" \
         --text="Configurando módulos e sites do Apache para o Koha..." \
         --percentage=0 --auto-close

# -----------------------------------------------------------------------------------
#  Passo 14 - Configurar o Apache para liberar as portas 8080 e 8888 automaticamente
# -----------------------------------------------------------------------------------
(
echo "10"
echo "# Verificando se as portas já estão configuradas no ports.conf..."
sleep 2

# Verifica e adiciona se necessário
if ! grep -q "Listen $INTRAPORT" /etc/apache2/ports.conf; then
    echo "Listen $INTRAPORT" | sudo tee -a /etc/apache2/ports.conf > /dev/null
fi

if ! grep -q "Listen $OPACPORT" /etc/apache2/ports.conf; then
    echo "Listen $OPACPORT" | sudo tee -a /etc/apache2/ports.conf > /dev/null
fi

echo "80"
echo "# Reiniciando Apache2 para aplicar alterações..."
sudo service apache2 restart
sleep 2

echo "100"
echo "# Configuração concluída. Apache escutando nas portas $INTRAPORT e $OPACPORT."

) | yad --progress \
         --title="Configurando portas do Apache" \
         --text="Configurando o Apache para liberar as portas $INTRAPORT e $OPACPORT automaticamente..." \
         --percentage=0 --auto-close

# ------------------------------------------------------------------------------------
# Passo 15 - Iniciar a instalação do software pelo instalador Web do Koha
# ------------------------------------------------------------------------------------

# Recupera o IP fora do subshell para poder usar no yad
IP_MACHINE=$(hostname -I | awk '{print $1}')

(
echo "10"
echo "# Preparando ambiente e recuperando IP da máquina para acesso em rede..."
sleep 2

echo "50"
echo "# Preparando informações para o acesso ao instalador Web do Koha..."
sleep 2

echo "100"
echo "# Instalação Web pronta para ser iniciada!"
) | yad --progress \
         --title="Instalador Web do Koha" \
         --text="Preparando o ambiente para exibir as informações de acesso..." \
         --percentage=0 --auto-close

# Após a barra de progresso, exibe informações finais
yad --info \
    --title="Instalação Web do Koha" \
    --text="<b>Instalação via navegador (Web Installer do Koha)</b>\n - Agora inicie a INSTALAÇÃO do Koha via instalador Web:\n<a href='http://localhost:$INTRAPORT'>http://localhost:$INTRAPORT</a>\n- Acesso via rede (outra máquina na mesma rede):\n<a href='http://$IP_MACHINE:$INTRAPORT'>http://$IP_MACHINE:$INTRAPORT</a>\n<b>Credenciais iniciais:</b>\nUsername: Koha_$INSTANCE_NAME\nPassword: $KOHA_PASS\n<b>Importante:</b>\nSiga o passo a passo do instalador Web para concluir a configuração do Koha. \nApós a instalação, você poderá acessar o OPAC (catálogo público) em:\n<a href='http://localhost:$OPACPORT'>http://localhost:$OPACPORT</a>\nClique em Ok para concluir a instalção pelo instalador Web"

# -----------------------------------------------------------------------------
# Mensagem final
# -----------------------------------------------------------------------------
yad --info --title="Instalação Concluída" \
    --text="Instalação do Koha concluída!\n\nPróximos passos:\n1. Descomente os comandos no script para execução real\n2. Execute o script com privilégios sudo\n3. Configure sua biblioteca através da interface web\n\nObrigado por usar o instalador Koha!"

echo "-----------------------------------------------"
echo "Instalador Koha concluído."
echo "LEMBRE-SE: Descomente os comandos para execução real!"
echo "-----------------------------------------------"

# -----------------------------------------------------------------------------
# Script de limpeza (opcional)
# -----------------------------------------------------------------------------
cleanup() {
    echo "Limpando arquivos temporários..."
    # Adicione aqui comandos de limpeza se necessário
}

# Configurar trap para limpeza em caso de interrupção
trap cleanup EXIT

exit 0