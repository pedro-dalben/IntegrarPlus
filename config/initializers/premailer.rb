Premailer::Rails.config.merge!(
  preserve_styles: true,
  remove_ids: false,
  remove_comments: true,
  remove_scripts: true,
  css_to_attributes: true,
  css_to_attributes_ignore: ['display'],
  with_html_string: true,
  adapter: :nokogiri
)
