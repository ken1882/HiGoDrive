module EquipmentManager
  extend BitsetTranslator
  Table = {
    :hemlet    => 0,
    :raincoat  => 1
  }
  Table.each{|k, v| Table[k] = (1 << v)}
end