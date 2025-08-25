# frozen_string_literal: true

# Pagy initializer file
# Customize with your own pagy defaults here

# Default items per page
Pagy::DEFAULT[:items] = 20

# Default size of the page links
Pagy::DEFAULT[:size] = 7

# Default page param name
Pagy::DEFAULT[:page_param] = :page

# Default overflow
Pagy::DEFAULT[:overflow] = :empty

# Default metadata
Pagy::DEFAULT[:metadata] = %i[count page prev next last series]

# Preserve request parameters in pagination links
Pagy::DEFAULT[:params] = ->(params) { params.except(:page) }

# Meilisearch integration
Pagy::DEFAULT[:meilisearch] = {
  limit: 10,
  offset: 0
}
