last_load_cnt = 0
last_err = nil

require_libs = proc do |files|
  n = files.size
  if n > 0 && n == last_load_cnt
    puts SPLIT_LINE
    puts "Error while loading libs, last error:"
    raise last_err
  end
  last_load_cnt = files.size
  queued_files = []
  files.each do |f|
    print "Requre #{f}..."
    begin
      require f
    rescue NameError, NoMethodError => err
      puts "possible dependency missing, queued"
      last_err = err
      queued_files << f
      next
    end
    puts "OK"
  end
  if queued_files.size > 0
    puts SPLIT_LINE, "Loading queued files"
    require_libs.call(queued_files)
  end
end

require_libs.call(Dir[File.join(Rails.root, "lib", "**", "*.rb")])
require_libs  = nil
last_load_cnt = nil
last_err      = nil