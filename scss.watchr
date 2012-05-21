require 'open3'

watch('src/css/((.*)\.scss)') do |md|
  stdin, stdout, stderr = Open3.popen3("sass #{md[0]} dist/css/#{md[2]}.css")

  error_message = nil
  unless stderr.eof?
    error_message = stderr.to_a.join
  end

  system "growlnotify", "-t", md[0], "-m", error_message.nil? ? 'Compiled successfully': error_message
end
