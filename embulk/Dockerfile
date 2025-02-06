# Dockerfile para Embulk
FROM openjdk:8-alpine

WORKDIR /root

# Instalar dependências
RUN apk update && apk add --no-cache curl bash libc6-compat gettext

ENV EMBULK_VERSION 0.11.5

# Baixar e instalar o Embulk
RUN wget -O /usr/local/bin/embulk "https://github.com/embulk/embulk/releases/download/v0.11.5/embulk-0.11.5.jar" \
    && chmod +x /usr/local/bin/embulk

# Copiar scripts e configuração
COPY entrypoint.sh /root/
RUN chmod +x /root/entrypoint.sh

ENTRYPOINT ["/root/entrypoint.sh"]
