module RoleManager
  RoleTable = {
    :admin      => 0,
    :passenger  => 1,
    :driver     => 2,
  }

  RoleTable.each{|k, v| RoleTable[k] = (1 << v)}

  module_function
  def get_role_bitset(*args)
    args.flatten!
    bitset = 0
    args.each do |role|
      bitset |= RoleTable[role]
    end
    return bitset
  end

  def match?(bt, sym)
    bt & get_role_bitset(sym) > 0
  end

end