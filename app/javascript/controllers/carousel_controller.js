import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['container'];

  connect() {
    console.log('🎠 Carousel Controller conectado!');
    this.container = this.element.querySelector('.flex.space-x-8');

    console.log('📦 Container encontrado:', this.container);
    console.log('📦 Element:', this.element);

    if (!this.container) {
      console.error('❌ Carousel: Container não encontrado');
      return;
    }

    this.currentIndex = 0;
    this.itemWidth = 320;
    this.gap = 32;
    this.visibleItems = this.getVisibleItems();

    console.log('✅ Carousel inicializado:', {
      currentIndex: this.currentIndex,
      itemWidth: this.itemWidth,
      gap: this.gap,
      visibleItems: this.visibleItems,
      totalItems: this.container.children.length,
    });

    window.addEventListener('resize', () => {
      this.visibleItems = this.getVisibleItems();
      this.scrollToIndex();
    });
  }

  getVisibleItems() {
    if (!this.container) return 1;

    const containerWidth =
      this.element.querySelector('.overflow-hidden')?.offsetWidth || this.element.offsetWidth;
    const itemsPerView = Math.floor(containerWidth / (this.itemWidth + this.gap));
    console.log('👁️ Itens visíveis calculados:', itemsPerView, 'Container width:', containerWidth);
    return Math.max(1, itemsPerView);
  }

  next() {
    console.log('➡️ NEXT CLICADO!');

    if (!this.container) {
      console.error('❌ Container não existe no next()');
      return;
    }

    const totalItems = this.container.children.length;
    const maxIndex = Math.max(0, totalItems - this.visibleItems);

    console.log('📊 Status antes de next:', {
      currentIndex: this.currentIndex,
      totalItems: totalItems,
      visibleItems: this.visibleItems,
      maxIndex: maxIndex,
    });

    if (this.currentIndex < maxIndex) {
      this.currentIndex++;
      console.log('✅ Movendo para index:', this.currentIndex);
      this.scrollToIndex();
    } else {
      console.log('⚠️ Já está no último item');
    }
  }

  previous() {
    console.log('⬅️ PREVIOUS CLICADO!');

    if (!this.container) {
      console.error('❌ Container não existe no previous()');
      return;
    }

    console.log('📊 Status antes de previous:', {
      currentIndex: this.currentIndex,
    });

    if (this.currentIndex > 0) {
      this.currentIndex--;
      console.log('✅ Movendo para index:', this.currentIndex);
      this.scrollToIndex();
    } else {
      console.log('⚠️ Já está no primeiro item');
    }
  }

  scrollToIndex() {
    if (!this.container) return;

    const scrollAmount = this.currentIndex * (this.itemWidth + this.gap);
    console.log('🎯 Aplicando transform:', `translateX(-${scrollAmount}px)`);
    this.container.style.transform = `translateX(-${scrollAmount}px)`;
    console.log('✅ Transform aplicado! Valor final:', this.container.style.transform);
  }

  disconnect() {
    console.log('👋 Carousel desconectado');
    window.removeEventListener('resize', this.handleResize);
  }
}
