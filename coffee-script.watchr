require "open3"

watch('(.*)\.coffee') do |md|
  stdin, stdout, stderr = Open3.popen3("coffee -o dist/js/ -c #{md[0]}")

  error_message = ''
  unless stderr.eof?
    error_message << stderr.to_a.join
  end

  system "growlnotify", "-t", md[0], "-m", error_message.empty? ? 'Compiled successfully': error_message
end
