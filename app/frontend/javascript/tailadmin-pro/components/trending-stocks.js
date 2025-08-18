import Swiper from "swiper";
import { Navigation } from "swiper/modules";
import "swiper/css";
import "swiper/css/navigation";

export default function trendingStocks() {
  const el = document.querySelector(".stocksSlider");
  if (!el) return;
  
  new Swiper(".stocksSlider", {
    modules: [Navigation],
    slidesPerView: 1,
    loop: false,
    spaceBetween: 20,
    navigation: {
      nextEl: ".swiper-button-next",
      prevEl: ".swiper-button-prev",
    },
    breakpoints: {
      768: {
        slidesPerView: 2,
      },
      1280: {
        slidesPerView: 2.3,
      },
      1536: {
        slidesPerView: 2.3,
      },
    },
  });
}
