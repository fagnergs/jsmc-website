/**
 * Configuração do Website JSMC Soluções
 *
 * INSTRUÇÕES:
 * 1. Após fazer deploy do CloudFormation, copie o API_ENDPOINT dos outputs
 * 2. Substitua o valor abaixo pela URL real
 * 3. Faça commit e deploy novamente
 */

window.JSMC_CONFIG = {
    // API Gateway endpoint para formulário de contato
    API_ENDPOINT: 'https://77iwfd87a3.execute-api.us-east-1.amazonaws.com/prod/contact',

    // Outras configurações podem ser adicionadas aqui
    ENVIRONMENT: 'production',
    VERSION: '11.0.0'
};
