module Rails
  module_function
  def development?; self.env == 'development'; end
  def test?; self.env == 'test'; end
  def production?; self.env == 'production'; end
end