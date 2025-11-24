#!/bin/bash

#JFX085

ALVO="LIXEIRA"
PASSES_SHRED=5 

if [ ! -d "$ALVO" ]; then
    echo "FALHA: $ALVO não encontrado."
    exit 1
fi

if ! command -v openssl &> /dev/null || ! command -v shred &> /dev/null; then
    echo "FALHA: Dependências (openssl ou shred) não instaladas."
    exit 1
fi

echo "DESTRUIÇÃO DUPLA DE DADOS - INÍCIO"
echo "ALVO: $ALVO"
read -p "Confirma IRREVERSIBILIDADE TOTAL [s/N]: " conf

if [[ "$conf" != "s" && "$conf" != "S" ]]; then
    echo "Cancelado."
    exit 0
fi

CHAVE=$(openssl rand -hex 32)
IV=$(openssl rand -hex 16) 

find "$ALVO" -type f | while read -r file; do
    echo "-> Processando: $file"
    
    shred -n $PASSES_SHRED -z -u "$file" 2>/dev/null 

    TEMP_N="${file}.n"
    head -c 1M /dev/urandom > "$TEMP_N"

    TEMP_E="${file}.e"
    openssl enc -aes-256-cbc -in "$TEMP_N" -out "$TEMP_E" \
        -pass pass:"$CHAVE" -iv "$IV" -e -pbkdf2 -nosalt 2>/dev/null
    
    rm -f "$TEMP_N"

    NOME_FINAL=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)
    
    mv "$TEMP_E" "$(dirname "$file")/${NOME_FINAL}.jfx085"
    
    echo "   Ofuscado: $(dirname "$file")/${NOME_FINAL}.jfx085"
done

find "$ALVO" -type d | sort -r | while read -r folder; do
    if [ "$folder" == "$ALVO" ]; then
        continue
    fi
    
    NOVO_NOME=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)
    
    mv "$folder" "$(dirname "$folder")/$NOVO_NOME"
    echo "Pasta Renomeada: $folder -> $(dirname "$folder")/$NOVO_NOME"
done

echo "PROCESSO FINALIZADO."
