// Script para corrigir os caminhos das imagens no header
document.addEventListener('DOMContentLoaded', function() {
  // Corrigir todas as imagens de usuário
  const userImages = document.querySelectorAll('img[src^="./images/user/"]');
  userImages.forEach(img => {
    const currentSrc = img.getAttribute('src');
    const newSrc = currentSrc.replace('./images/user/', '/assets/images/user/');
    img.setAttribute('src', newSrc);
  });

  // Corrigir imagens de logo
  const logoImages = document.querySelectorAll('img[src^="./images/logo/"]');
  logoImages.forEach(img => {
    const currentSrc = img.getAttribute('src');
    const newSrc = currentSrc.replace('./images/logo/', '/assets/images/logo/');
    img.setAttribute('src', newSrc);
  });

  // Corrigir links do header
  const profileLinks = document.querySelectorAll('a[href="profile.html"]');
  profileLinks.forEach(link => {
    link.href = '/users/edit';
  });

  const chatLinks = document.querySelectorAll('a[href="chat.html"]');
  chatLinks.forEach(link => {
    link.href = '#';
    link.textContent = 'Configurações da conta';
  });

  // Fallback para imagens do logo se o asset pipeline falhar
  const logoFallbacks = document.querySelectorAll('img[src*="logo.svg"]');
  logoFallbacks.forEach(img => {
    img.addEventListener('error', function() {
      // Se a imagem falhar, usar um fallback
      if (this.src.includes('logo-dark.svg')) {
        this.src = '/vendor/tailadmin-pro/images/logo/logo-dark.svg';
      } else if (this.src.includes('logo.svg')) {
        this.src = '/vendor/tailadmin-pro/images/logo/logo.svg';
      } else if (this.src.includes('logo-icon.svg')) {
        this.src = '/vendor/tailadmin-pro/images/logo/logo-icon.svg';
      }
    });
  });
});
