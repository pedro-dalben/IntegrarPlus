// import Swiper JS
import Swiper from "swiper";
import { Navigation, Pagination, Autoplay } from "swiper/modules";
// import Swiper styles
import "swiper/css";

export default function carousel01() {
  const el = document.querySelector(".carouselOne");
  if (!el) return;
  
  new Swiper(".carouselOne", {
    modules: [Autoplay],
    autoplay: {
      delay: 5000,
      disableOnInteraction: false,
    },
  });
}
