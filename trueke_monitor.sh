#!/bin/zsh

clear
echo "==============================================="
echo "    MONITOR CI-CD - REPOSITORIO TRUEKE         "
echo "==============================================="
echo "Presione CTRL-C para detener la monitorizacion"
echo ""

while true; do
    DATA=$(curl -s -H "Accept: application/vnd.github+json" "https://github.com")
    
    python3 -c "
import json, sys
try:
    res = json.loads('''$DATA''')
    if 'workflow_runs' in res and res['workflow_runs']:
        run = res['workflow_runs']
        print('Pipeline N:', run.get('run_number'))
        print('Estado:', run.get('status'))
        print('Conclusion:', run.get('conclusion'))
        print('URL:', run.get('html_url'))
        print('-----------------------------------------------')
except Exception as e:
    print('Error leyendo datos de la API:', str(e))
"
    sleep 10
done
