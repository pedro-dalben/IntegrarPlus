// import Swiper JS
import Swiper from "swiper";
import { Pagination, Autoplay } from "swiper/modules";
// import Swiper styles
import "swiper/css";
import "swiper/css/pagination";

export default function carousel03() {
  const el = document.querySelector(".carouselThree");
  if (!el) return;
  
  new Swiper(".carouselThree", {
    modules: [Pagination, Autoplay],
    autoplay: {
      delay: 5000,
      disableOnInteraction: false,
    },
    pagination: {
      el: ".swiper-pagination",
      clickable: true,
    },
  });
}
