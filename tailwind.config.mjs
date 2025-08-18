/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './app/views/**/*.{erb,html}',
    './app/components/**/*.{erb,html,rb}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/frontend/**/*.{js,css}'
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require('@tailwindcss/forms'),
  ],
}
