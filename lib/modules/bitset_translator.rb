module BitsetTranslator
  Table = {}
  def get_bitset(*syms)
    syms.flatten.inject(0){|r, s| r | (self::Table[s] || 0)}
  end

  def match?(bt, *syms)
    bt & get_bitset(syms) > 0
  end

  def all_match?(bt, *syms)
    bt & get_bitset(syms) == bt
  end
end