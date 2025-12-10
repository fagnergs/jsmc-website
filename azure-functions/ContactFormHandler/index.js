/**
 * Azure Function - Contact Form Handler
 * Processa formulário de contato e envia email via SendGrid
 */

const sgMail = require('@sendgrid/mail');

// Configurações
const FROM_EMAIL = process.env.FROM_EMAIL || 'informacoes@jsmc.com.br';
const TO_EMAIL = process.env.TO_EMAIL || 'informacoes@jsmc.com.br';
const BCC_EMAIL = process.env.BCC_EMAIL || '';
const SENDGRID_API_KEY = process.env.SENDGRID_API_KEY;

// Inicializar SendGrid
if (SENDGRID_API_KEY) {
    sgMail.setApiKey(SENDGRID_API_KEY);
}

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
        <div style="background: linear-gradient(135deg, #00A3D9 0%, #FF8C42 100%); padding: 30px; text-align: center;">
            <h1 style="color: #ffffff; margin: 0; font-size: 24px;">Nova Mensagem - JSMC Soluções</h1>
        </div>
        <div style="padding: 30px;">
            <p style="font-size: 16px; color: #666; margin-bottom: 20px;">
                Você recebeu uma nova mensagem através do formulário de contato do website.
            </p>
            <table style="width: 100%; border-collapse: collapse; margin-bottom: 20px;">
                <tr style="border-bottom: 1px solid #eee;">
                    <td style="padding: 12px 0; font-weight: bold; color: #2C3E50; width: 120px;">Nome:</td>
                    <td style="padding: 12px 0; color: #333;">${escapeHtml(data.name)}</td>
                </tr>
                <tr style="border-bottom: 1px solid #eee;">
                    <td style="padding: 12px 0; font-weight: bold; color: #2C3E50;">Email:</td>
                    <td style="padding: 12px 0;">
                        <a href="mailto:${escapeHtml(data.email)}" style="color: #00A3D9; text-decoration: none;">
                            ${escapeHtml(data.email)}
                        </a>
                    </td>
                </tr>
                ${data.company ? `
                <tr style="border-bottom: 1px solid #eee;">
                    <td style="padding: 12px 0; font-weight: bold; color: #2C3E50;">Empresa:</td>
                    <td style="padding: 12px 0; color: #333;">${escapeHtml(data.company)}</td>
                </tr>
                ` : ''}
                <tr style="border-bottom: 1px solid #eee;">
                    <td style="padding: 12px 0; font-weight: bold; color: #2C3E50;">Assunto:</td>
                    <td style="padding: 12px 0; color: #333;">${subjectText}</td>
                </tr>
            </table>
            <div style="background-color: #f8f9fa; border-left: 4px solid #FF8C42; padding: 15px; margin: 20px 0; border-radius: 4px;">
                <h3 style="margin: 0 0 10px 0; color: #2C3E50; font-size: 16px;">Mensagem:</h3>
                <p style="margin: 0; color: #555; white-space: pre-wrap;">${escapeHtml(data.message)}</p>
            </div>
            <div style="text-align: center; margin-top: 30px;">
                <a href="mailto:${escapeHtml(data.email)}"
                   style="display: inline-block; background: linear-gradient(135deg, #00A3D9 0%, #FF8C42 100%); color: #ffffff; padding: 12px 30px; text-decoration: none; border-radius: 5px; font-weight: bold;">
                    Responder Email
                </a>
            </div>
        </div>
        <div style="background-color: #f8f9fa; padding: 20px; text-align: center; border-top: 1px solid #eee;">
            <p style="margin: 0; color: #999; font-size: 12px;">
                Esta mensagem foi enviada através do formulário de contato do website<br>
                <a href="https://jsmc.com.br" style="color: #00A3D9; text-decoration: none;">jsmc.com.br</a>
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
 * Envia email via SendGrid
 */
async function sendEmail(data) {
    if (!SENDGRID_API_KEY) {
        throw new Error('SENDGRID_API_KEY não configurada');
    }

    const subjectText = SUBJECT_MAP[data.subject] || 'Outro';

    const msg = {
        to: TO_EMAIL,
        from: FROM_EMAIL,
        subject: `[Website] ${subjectText} - ${data.name}`,
        text: createEmailText(data),
        html: createEmailHTML(data),
        replyTo: data.email
    };

    if (BCC_EMAIL) {
        msg.bcc = BCC_EMAIL;
    }

    return await sgMail.send(msg);
}

/**
 * Azure Function Handler (HTTP Trigger)
 */
module.exports = async function (context, req) {
    context.log('Contact Form Handler triggered');

    context.res = {
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': process.env.CORS_ORIGINS || 'https://jsmc.com.br',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Methods': 'POST, OPTIONS'
        }
    };

    if (req.method === 'OPTIONS') {
        context.res.status = 200;
        context.res.body = { message: 'OK' };
        return;
    }

    if (req.method !== 'POST') {
        context.res.status = 405;
        context.res.body = { error: 'Método não permitido' };
        return;
    }

    try {
        const data = req.body;

        const errors = validateFormData(data);
        if (errors.length > 0) {
            context.res.status = 400;
            context.res.body = {
                error: 'Dados inválidos',
                details: errors
            };
            return;
        }

        await sendEmail(data);

        context.log('Email enviado com sucesso para:', TO_EMAIL);

        context.res.status = 200;
        context.res.body = {
            success: true,
            message: 'Mensagem enviada com sucesso!'
        };

    } catch (error) {
        context.log.error('Erro ao processar requisição:', error);

        context.res.status = 500;
        context.res.body = {
            error: 'Erro ao enviar mensagem',
            message: 'Por favor, tente novamente mais tarde.'
        };
    }
};
