module RoleManager
  extend BitsetTranslator
  Table = {
    :passenger  => 0,
    :driver     => 1,
    :admin      => 2,
  }
  Table.each{|k, v| Table[k] = (1 << v)}
end