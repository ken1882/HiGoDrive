class User
  include Mongoid::Document
  include Mongoid::Timestamps
  field :id, type: Integer
  field :name, type: String

  def self.validate(params)
    return false if (params[:id] && params[:id].to_i <= 0 rescue true)
    return true
  end
end
