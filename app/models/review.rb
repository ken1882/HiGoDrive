class Review
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :user

  field :score, type: Integer
  field :comment, type: String

  validates :score, numericality: { only_integer: true }
  
end
