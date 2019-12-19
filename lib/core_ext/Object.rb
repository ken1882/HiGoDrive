class Object
  def public_instance_variables
    instance_variables.select{|sym| !sym.to_s.start_with?('@_')}
  end
end