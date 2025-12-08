// ==================== MENU MOBILE ==================== 
document.addEventListener('DOMContentLoaded', function() {
    const menuToggle = document.getElementById('menuToggle');
    const navMenu = document.getElementById('navMenu');

    menuToggle.addEventListener('click', function() {
        navMenu.classList.toggle('active');
    });

    // Fechar menu ao clicar em um link
    const navLinks = document.querySelectorAll('.nav-menu a');
    navLinks.forEach(link => {
        link.addEventListener('click', function() {
            navMenu.classList.remove('active');
        });
    });
});

// ==================== SMOOTH SCROLL BEHAVIOR ==================== 
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// ==================== INTERSECTION OBSERVER PARA ANIMAÇÕES ==================== 
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -100px 0px'
};

const observer = new IntersectionObserver(function(entries) {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.animation = 'fadeInUp 0.6s ease-out forwards';
            observer.unobserve(entry.target);
        }
    });
}, observerOptions);

// Observar elementos animáveis
document.querySelectorAll('.service-category, .differential-card, .client-logo, .highlight-item').forEach(el => {
    el.style.opacity = '0';
    observer.observe(el);
});

// ==================== FORM SUBMISSION ==================== 
document.getElementById('contactForm').addEventListener('submit', async function(e) {
    e.preventDefault();

    const formData = {
        name: document.getElementById('name').value,
        email: document.getElementById('email').value,
        company: document.getElementById('company').value,
        subject: document.getElementById('subject').value,
        message: document.getElementById('message').value
    };

    try {
        // Simular envio - em produção usar endpoint real
        console.log('Formulário enviado:', formData);
        
        // Feedback visual
        const submitBtn = this.querySelector('button[type="submit"]');
        const originalText = submitBtn.textContent;
        submitBtn.textContent = '✓ Mensagem enviada com sucesso!';
        submitBtn.style.background = 'linear-gradient(135deg, #27ae60, #2ecc71)';
        
        // Limpar formulário
        this.reset();
        
        // Restaurar botão após 3 segundos
        setTimeout(() => {
            submitBtn.textContent = originalText;
            submitBtn.style.background = '';
        }, 3000);

    } catch (error) {
        console.error('Erro ao enviar formulário:', error);
        alert('Erro ao enviar mensagem. Por favor, tente novamente.');
    }
});

// ==================== NAVBAR SCROLL EFFECT ==================== 
let lastScrollTop = 0;
const navbar = document.querySelector('.navbar');

window.addEventListener('scroll', function() {
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
    
    if (scrollTop > 100) {
        navbar.style.boxShadow = 'var(--shadow-lg)';
    } else {
        navbar.style.boxShadow = 'var(--shadow-md)';
    }
    
    lastScrollTop = scrollTop <= 0 ? 0 : scrollTop;
});

// ==================== CONTADOR DE NÚMEROS (Para seção de diferenciais) ==================== 
const countElements = document.querySelectorAll('.card-number');
const countSpeed = 50; // Velocidade da animação

const startCounting = (element) => {
    const target = parseInt(element.textContent);
    let current = 0;
    const increment = target / countSpeed;

    const timer = setInterval(() => {
        current += increment;
        if (current >= target) {
            element.textContent = String(target).padStart(2, '0');
            clearInterval(timer);
        } else {
            element.textContent = String(Math.floor(current)).padStart(2, '0');
        }
    }, 30);
};

// Iniciar contagem quando elementos entram na viewport
const countObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            startCounting(entry.target);
            countObserver.unobserve(entry.target);
        }
    });
}, { threshold: 0.5 });

countElements.forEach(el => countObserver.observe(el));

// ==================== BOTÕES COM RIPPLE EFFECT ==================== 
document.querySelectorAll('.btn').forEach(button => {
    button.addEventListener('click', function(e) {
        const ripple = document.createElement('span');
        const rect = this.getBoundingClientRect();
        const size = Math.max(rect.width, rect.height);
        const x = e.clientX - rect.left - size / 2;
        const y = e.clientY - rect.top - size / 2;

        ripple.style.cssText = `
            position: absolute;
            width: ${size}px;
            height: ${size}px;
            background: rgba(255, 255, 255, 0.6);
            border-radius: 50%;
            left: ${x}px;
            top: ${y}px;
            pointer-events: none;
            animation: ripple 0.6s ease-out;
        `;

        if (this.style.position === 'static') {
            this.style.position = 'relative';
            this.style.overflow = 'hidden';
        }

        this.appendChild(ripple);
        
        setTimeout(() => ripple.remove(), 600);
    });
});

// Adicionar animação de ripple ao CSS dinamicamente
const style = document.createElement('style');
style.textContent = `
    @keyframes ripple {
        to {
            transform: scale(4);
            opacity: 0;
        }
    }
`;
document.head.appendChild(style);

// ==================== LAZY LOADING PARA IMAGENS ==================== 
if ('IntersectionObserver' in window) {
    const imageObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                if (img.dataset.src) {
                    img.src = img.dataset.src;
                    img.removeAttribute('data-src');
                }
                imageObserver.unobserve(img);
            }
        });
    });

    document.querySelectorAll('img[data-src]').forEach(img => {
        imageObserver.observe(img);
    });
}

// ==================== ANALYTICS BÁSICO ==================== 
// Rastrear cliques em botões CTA
document.querySelectorAll('.cta-btn, .btn-primary').forEach(btn => {
    btn.addEventListener('click', function() {
        console.log('CTA clicado:', this.textContent);
        // Aqui você poderia enviar para um serviço de analytics
    });
});

// ==================== UTILITÁRIO: VERIFICAR PERFORMANCE ==================== 
window.addEventListener('load', function() {
    const perfData = window.performance.timing;
    const pageLoadTime = perfData.loadEventEnd - perfData.navigationStart;
    console.log('Tempo de carregamento da página:', pageLoadTime, 'ms');
});

// ==================== TRATAMENTO DE ERROS GLOBAL ==================== 
window.addEventListener('error', function(event) {
    console.error('Erro capturado:', event.error);
    // Aqui você poderia enviar para um serviço de error tracking
});

// ==================== SUPORTE A PWA (OPCIONAL) ==================== 
if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('/sw.js').then(registration => {
        console.log('Service Worker registrado com sucesso:', registration);
    }).catch(error => {
        console.log('Erro ao registrar Service Worker:', error);
    });
}

console.log('JSMC Soluções - Website carregado com sucesso! 🚀');
