class String
  UnicodeInvisibleCharacters = [
    "\u200b\u200c\u200d\u200e\u200f\uffef"
  ]
  def printable?
    self.tr(UnicodeInvisibleCharacters, '').match(/[[:graph:]]/)
  end

  def to_bool
    length != 0
  end
end
