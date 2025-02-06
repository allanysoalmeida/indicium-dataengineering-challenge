#!/bin/sh

# Fonte para inicializar variáveis
if [ -f "/root/.bashrc" ]; then
    source /root/.bashrc
fi

# Validar se o YAML foi fornecido
if [ -z "$1" ]; then
    echo "Erro: é necessário especificar o arquivo de configuração do Embulk (YAML)."
    exit 1
fi

CONFIG_FILE="$1"

# Verificar se o arquivo de configuração existe
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Erro: O arquivo de configuração '$CONFIG_FILE' não foi encontrado."
    exit 1
fi

# Instalar plugins, se especificados na variável de ambiente PLUGINS
if [ -n "$PLUGINS" ]; then
    for plugin in $PLUGINS; do
        echo "[INSTALANDO PLUGIN]: $plugin"
        embulk gem install "$plugin"
    done
fi

# Executar o Embulk com o arquivo de configuração especificado
echo "Executando Embulk com o arquivo de configuração: $CONFIG_FILE"
embulk run "$CONFIG_FILE"
