export default {
  content: [
    './app/views/**/*.{erb,html}',
    './app/components/**/*.{erb,html,rb}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/frontend/**/*.{js,css}',
    './app/frontend/styles/tailadmin-pro.css',
    './app/assets/stylesheets/**/*.css'
  ],
  theme: {
    extend: {
      colors: {
        error: {
          300: '#FDA29B',
          400: '#F97066',
          500: '#F04438',
          600: '#D92D20',
          700: '#B42318',
        }
      }
    }
  }
}
