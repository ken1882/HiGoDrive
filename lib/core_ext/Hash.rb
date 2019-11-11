class Hash
  def to_bool; self.to_a.to_bool; end
  def to_struct
    return OpenStruct.new(self)
  end
end