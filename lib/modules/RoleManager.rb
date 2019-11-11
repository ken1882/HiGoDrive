module RoleManager
  RoleTable = {
    :admin      => 0,
    :standard   => 1,
    :sponsor    => 2,
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

end