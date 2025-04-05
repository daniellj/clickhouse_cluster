#!/usr/bin/env bash
set -uo pipefail

#do this in a loop because the timing for when the SQL instance is ready is indeterminate
for i in {1..60};
do
    sqlcmd -S localhost -U SA -P "$MSSQL_SA_PASSWORD" -Q "SELECT 1" -C -b -l 1 &> /dev/null
    if [ $? -eq 0 ]
    then
        echo "SQL Server initialization completed"
        break
    else
        echo "SQL Server not ready yet..."
        sleep 1
    fi
done

# Verifica o valor contido no arquivo de controle
if [ ! -f "load_control" ]; then
    echo "❌ Arquivo 'load_control' não encontrado. Abortando."
    exit 1
fi

load_status=$(head -n 1 load_control | tr -d '\r\n')

if [[ "$load_status" == "0" ]]; then
    echo "🚀 Iniciando execução do script instnwnd.sql..."
    if sqlcmd -S localhost -U SA -P "$MSSQL_SA_PASSWORD" -C -i instnwnd.sql; then
        echo "✅ Script executado com sucesso. Atualizando arquivo de controle para 1."
        echo "1" > load_control
    else
        echo "❌ Falha ao executar o script instnwnd.sql. Verifique os logs."
        exit 2
    fi
else
    echo "✅ Script já executado anteriormente. Nenhuma ação necessária."
fi
