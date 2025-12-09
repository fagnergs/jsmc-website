#!/bin/bash

# Script para verificar aprovação do AWS SES Production Access
# Execute este script a cada 6 horas até aprovação

set -e

echo "🔍 Verificando status do AWS SES Production Access..."
echo "Data: $(date)"
echo ""

# Verificar se AWS CLI está configurado
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI não encontrado. Instale com: brew install awscli"
    exit 1
fi

# Verificar status atual
PRODUCTION_ENABLED=$(aws sesv2 get-account --region us-east-1 --query 'ProductionAccessEnabled' --output text 2>/dev/null || echo "ERROR")

if [ "$PRODUCTION_ENABLED" = "ERROR" ]; then
    echo "❌ Erro ao consultar AWS SES. Verifique suas credenciais."
    exit 1
fi

echo "Status: ProductionAccessEnabled = $PRODUCTION_ENABLED"
echo ""

if [ "$PRODUCTION_ENABLED" = "True" ]; then
    echo "🎉🎉🎉 APROVADO! AWS SES está em Production Mode! 🎉🎉🎉"
    echo ""
    echo "📋 Próximos passos:"
    echo "1. Abrir arquivo: TODO-SES-PRODUCTION.md"
    echo "2. Seguir instruções para descomentar Reply-To"
    echo "3. Fazer deploy das mudanças"
    echo "4. Testar formulário"
    echo ""
    echo "Arquivo TODO: $(pwd)/TODO-SES-PRODUCTION.md"

    # Notificar via sistema (macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        osascript -e 'display notification "AWS SES Production Access foi aprovado! ✅" with title "JSMC Website" sound name "Glass"'
    fi

    exit 0
else
    echo "⏳ Ainda em Sandbox Mode. Aguardando aprovação..."
    echo ""
    echo "📊 Informações:"

    # Pegar informações adicionais
    DAILY_SENDING_QUOTA=$(aws sesv2 get-account --region us-east-1 --query 'SendQuota.Max24HourSend' --output text)
    EMAILS_SENT_TODAY=$(aws sesv2 get-account --region us-east-1 --query 'SendQuota.SentLast24Hours' --output text)

    echo "   - Limite diário: $DAILY_SENDING_QUOTA emails"
    echo "   - Enviados hoje: $EMAILS_SENT_TODAY emails"
    echo "   - Status: SANDBOX (só envia para emails verificados)"
    echo ""
    echo "Solicitação enviada em: 09/12/2024"
    echo "Aprovação esperada em: 24-48 horas (até 11/12/2024)"
    echo ""
    echo "💡 Dica: Execute novamente em 6 horas:"
    echo "   ./scripts/check-ses-approval.sh"

    exit 1
fi
