class Organogram < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  has_many :organogram_members, dependent: :destroy

  validates :name, presence: true, length: { maximum: 150 }
  validates :data, presence: true
  validates :created_by, presence: true

  before_validation :set_defaults, on: :create

  scope :published, -> { where.not(published_at: nil) }
  scope :unpublished, -> { where(published_at: nil) }
  scope :ordered, -> { order(:name) }

  def published?
    published_at.present?
  end

  def publish!
    update!(published_at: Time.current)
  end

  def unpublish!
    update!(published_at: nil)
  end

  def nodes_count
    data.dig('nodes')&.length || 0
  end

  def validate_data_structure
    return if data.blank?

    errors.add(:data, 'deve conter a estrutura nodes') unless data.key?('nodes')
    errors.add(:data, 'nodes deve ser um array') unless data['nodes'].is_a?(Array)

    if data.key?('links')
      errors.add(:data, 'links deve ser um array') unless data['links'].is_a?(Array)
    end
  end

  def ensure_valid_hierarchy
    return if data.blank? || data['nodes'].blank?

    nodes = data['nodes']
    root_nodes = nodes.select { |node| node['parent'].nil? || node['parent'].blank? }

    if root_nodes.empty?
      errors.add(:data, 'deve ter pelo menos um nó raiz')
    elsif root_nodes.length > 1
      errors.add(:data, 'deve ter apenas um nó raiz')
    end

    check_for_cycles(nodes)
  end

  def from_csv_data(csv_data)
    nodes = []
    csv_data.each do |row|
      node = {
        id: row['id'] || SecureRandom.uuid,
        text: row['name'] || '',
        title: row['role_title'] || '',
        parent: row['pid'] || nil
      }

      node[:data] = {
        department: row['department'],
        email: row['email'],
        phone: row['phone']
      }.compact

      nodes << node
    end

    self.data = { nodes: nodes, links: [] }
  end

  def to_export_data
    {
      name: name,
      nodes: data.dig('nodes') || [],
      links: data.dig('links') || [],
      settings: settings || {},
      published_at: published_at
    }
  end

  private

  def set_defaults
    self.data ||= { nodes: [], links: [] }
    self.settings ||= {}
  end

  def check_for_cycles(nodes)
    return if nodes.blank?

    visited = Set.new
    rec_stack = Set.new

    nodes.each do |node|
      next if visited.include?(node['id'])

      if has_cycle?(node, nodes, visited, rec_stack)
        errors.add(:data, 'contém ciclos na hierarquia')
        break
      end
    end
  end

  def has_cycle?(node, all_nodes, visited, rec_stack)
    node_id = node['id']
    return false if visited.include?(node_id)

    visited.add(node_id)
    rec_stack.add(node_id)

    children = all_nodes.select { |n| n['parent'] == node_id }
    children.each do |child|
      child_id = child['id']

      if !visited.include?(child_id) && has_cycle?(child, all_nodes, visited, rec_stack)
        return true
      elsif rec_stack.include?(child_id)
        return true
      end
    end

    rec_stack.delete(node_id)
    false
  end
end
