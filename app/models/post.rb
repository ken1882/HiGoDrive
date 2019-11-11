class Post
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :content, type: String
  field :author_id, type: Integer

  validates_numericality_of :author_id, :only_integer => true, :greater_than => 0
  validates_presence_of :title
end
