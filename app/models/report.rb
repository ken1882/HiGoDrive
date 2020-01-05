class Report
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :task

  field :comment, type: String
  field :author_id, type: BSON::ObjectId

  validates :comment, presence: true
  validates :author_id, presence: true
  
  def json_info
    {
      author_id: self.author_id.to_s,
      comment: self.comment,
      created_at: self.created_at,
    }
  end
end
