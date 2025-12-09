/**
 * AWS Lambda Function - Contact Form Handler
 * Processa formulário de contato e envia email via AWS SES
 */

const AWS = require('aws-sdk');
const ses = new AWS.SES({ region: process.env.AWS_REGION || 'us-east-1' });

// Configurações
const FROM_EMAIL = process.env.FROM_EMAIL || 'informacoes@jsmc.com.br';
const TO_EMAIL = process.env.TO_EMAIL || 'informacoes@jsmc.com.br';
const BCC_EMAIL = process.env.BCC_EMAIL || ''; // Email opcional para cópia

// Mapeamento de assuntos
const SUBJECT_MAP = {
    'consultoria': 'Consultoria em Energia',
    'iot': 'Projetos IoT',
    'grid': 'Grid Modernization',
    'regulatory': 'Assuntos Regulatórios',
    'pdi': 'Pesquisa & Inovação',
    'other': 'Outro'
};

/**
 * Valida dados do formulário
 */
function validateFormData(data) {
    const errors = [];

    if (!data.name || data.name.trim().length < 2) {
        errors.push('Nome inválido');
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!data.email || !emailRegex.test(data.email)) {
        errors.push('Email inválido');
    }

    if (!data.subject || !SUBJECT_MAP[data.subject]) {
        errors.push('Assunto inválido');
    }

    if (!data.message || data.message.trim().length < 10) {
        errors.push('Mensagem muito curta (mínimo 10 caracteres)');
    }

    return errors;
}

/**
 * Cria HTML do email
 */
function createEmailHTML(data) {
    const subjectText = SUBJECT_MAP[data.subject] || 'Outro';

    return `
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contato - JSMC Soluções</title>
</head>
<body style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f4f4f4;">
    <div style="background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
        <!-- Header -->
        <div style="background: linear-gradient(135deg, #1F2937 0%, #F59E0B 100%); padding: 30px; text-align: center;">
            <h1 style="color: #ffffff; margin: 0; font-size: 24px;">Nova Mensagem - JSMC Soluções</h1>
        </div>

        <!-- Content -->
        <div style="padding: 30px;">
            <p style="font-size: 16px; color: #666; margin-bottom: 20px;">
                Você recebeu uma nova mensagem através do formulário de contato do website.
            </p>

            <table style="width: 100%; border-collapse: collapse; margin-bottom: 20px;">
                <tr style="border-bottom: 1px solid #eee;">
                    <td style="padding: 12px 0; font-weight: bold; color: #1F2937; width: 120px;">Nome:</td>
                    <td style="padding: 12px 0; color: #333;">${escapeHtml(data.name)}</td>
                </tr>
                <tr style="border-bottom: 1px solid #eee;">
                    <td style="padding: 12px 0; font-weight: bold; color: #1F2937;">Email:</td>
                    <td style="padding: 12px 0;">
                        <a href="mailto:${escapeHtml(data.email)}" style="color: #F59E0B; text-decoration: none;">
                            ${escapeHtml(data.email)}
                        </a>
                    </td>
                </tr>
                ${data.company ? `
                <tr style="border-bottom: 1px solid #eee;">
                    <td style="padding: 12px 0; font-weight: bold; color: #1F2937;">Empresa:</td>
                    <td style="padding: 12px 0; color: #333;">${escapeHtml(data.company)}</td>
                </tr>
                ` : ''}
                <tr style="border-bottom: 1px solid #eee;">
                    <td style="padding: 12px 0; font-weight: bold; color: #1F2937;">Assunto:</td>
                    <td style="padding: 12px 0; color: #333;">${subjectText}</td>
                </tr>
            </table>

            <div style="background-color: #f8f9fa; border-left: 4px solid #F59E0B; padding: 15px; margin: 20px 0; border-radius: 4px;">
                <h3 style="margin: 0 0 10px 0; color: #1F2937; font-size: 16px;">Mensagem:</h3>
                <p style="margin: 0; color: #555; white-space: pre-wrap;">${escapeHtml(data.message)}</p>
            </div>

            <!-- Call to Action -->
            <div style="text-align: center; margin-top: 30px;">
                <a href="mailto:${escapeHtml(data.email)}"
                   style="display: inline-block; background: linear-gradient(135deg, #1F2937 0%, #F59E0B 100%); color: #ffffff; padding: 12px 30px; text-decoration: none; border-radius: 5px; font-weight: bold;">
                    Responder Email
                </a>
            </div>
        </div>

        <!-- Footer -->
        <div style="background-color: #f8f9fa; padding: 20px; text-align: center; border-top: 1px solid #eee;">
            <p style="margin: 0; color: #999; font-size: 12px;">
                Esta mensagem foi enviada através do formulário de contato do website<br>
                <a href="https://jsmc.com.br" style="color: #F59E0B; text-decoration: none;">jsmc.com.br</a>
            </p>
            <p style="margin: 10px 0 0 0; color: #999; font-size: 12px;">
                Data: ${new Date().toLocaleString('pt-BR', { timeZone: 'America/Sao_Paulo' })}
            </p>
        </div>
    </div>
</body>
</html>
    `.trim();
}

/**
 * Cria versão texto do email
 */
function createEmailText(data) {
    const subjectText = SUBJECT_MAP[data.subject] || 'Outro';

    return `
NOVA MENSAGEM - JSMC Soluções
==============================

Você recebeu uma nova mensagem através do formulário de contato do website.

Nome: ${data.name}
Email: ${data.email}
${data.company ? `Empresa: ${data.company}\n` : ''}Assunto: ${subjectText}

Mensagem:
---------
${data.message}

---
Data: ${new Date().toLocaleString('pt-BR', { timeZone: 'America/Sao_Paulo' })}
Website: https://jsmc.com.br
    `.trim();
}

/**
 * Escape HTML para prevenir XSS
 */
function escapeHtml(text) {
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return text.replace(/[&<>"']/g, m => map[m]);
}

/**
 * Envia email via AWS SES
 */
async function sendEmail(data) {
    const subjectText = SUBJECT_MAP[data.subject] || 'Outro';

    const params = {
        Source: FROM_EMAIL,
        Destination: {
            ToAddresses: [TO_EMAIL]
        },
        Message: {
            Subject: {
                Data: `[Website] ${subjectText} - ${data.name}`,
                Charset: 'UTF-8'
            },
            Body: {
                Html: {
                    Data: createEmailHTML(data),
                    Charset: 'UTF-8'
                },
                Text: {
                    Data: createEmailText(data),
                    Charset: 'UTF-8'
                }
            }
        }
        // ReplyToAddresses temporariamente comentado devido ao Sandbox SES
        // Será reativado após aprovação de Production Access
        // ReplyToAddresses: [data.email]
    };

    // Adicionar BCC se configurado
    if (BCC_EMAIL) {
        params.Destination.BccAddresses = [BCC_EMAIL];
    }

    return ses.sendEmail(params).promise();
}

/**
 * Cria resposta HTTP
 */
function createResponse(statusCode, body) {
    return {
        statusCode,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*', // Ajustar para domínio específico em produção
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Methods': 'POST, OPTIONS'
        },
        body: JSON.stringify(body)
    };
}

/**
 * Handler principal da Lambda
 */
exports.handler = async (event) => {
    console.log('Event:', JSON.stringify(event, null, 2));

    // Lidar com preflight CORS
    if (event.httpMethod === 'OPTIONS') {
        return createResponse(200, { message: 'OK' });
    }

    // Apenas aceitar POST
    if (event.httpMethod !== 'POST') {
        return createResponse(405, { error: 'Método não permitido' });
    }

    try {
        // Parse do body
        const data = JSON.parse(event.body);

        // Validar dados
        const errors = validateFormData(data);
        if (errors.length > 0) {
            return createResponse(400, {
                error: 'Dados inválidos',
                details: errors
            });
        }

        // Enviar email
        await sendEmail(data);

        console.log('Email enviado com sucesso para:', TO_EMAIL);

        return createResponse(200, {
            success: true,
            message: 'Mensagem enviada com sucesso!'
        });

    } catch (error) {
        console.error('Erro ao processar requisição:', error);

        return createResponse(500, {
            error: 'Erro ao enviar mensagem',
            message: 'Por favor, tente novamente mais tarde.'
        });
    }
};
