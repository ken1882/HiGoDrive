class String
  def printable?
    (self =~ /[^[:print:]]/).nil? && self.lstrip.length > 0
  end
end
