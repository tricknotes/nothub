require 'fileutils'
require 'open3'

require 'rubygems'
require 'crxmake'

class CompileError < StandardError
end
class CoffeeScriptCompileError < CompileError
end
class HamlCompileError < CompileError
end
class SCSSCompileError < CompileError
end

def pre_package
  # - compile coffee
  stdin, stdout, stderr = Open3.popen3('coffee -o ./dist/js/ -c ./src/js/*.coffee')
  error = stderr.to_a.join
  throw CoffeeScriptCompileError, error unless error.empty?

  # - compile haml
  Dir['./src/*.haml'].each do |haml|
    stdin, stdout, stderr = Open3.popen3("haml --no-escape-attrs #{haml}")
    error = stderr.to_a.join
    throw HamlCompileError, error unless error.empty?
    File.open("./dist/#{File.basename(haml, 'haml')}html", 'w') do |html|
      html << stdout.to_a.join
    end
  end
  # - compile scss
  Dir['./src/css/*.scss'].each do |scss|
    css = File.basename(scss, 'scss')
    stdin, stdout, stderr = Open3.popen3("sass #{scss} dist/css/#{css}css")
  end

  # setup libraries
  libs = %w(
    ./lib/EventEmitter/src/EventEmitter.js
    ./lib/EventEmitter/src/EventEmitter.min.js
    ./lib/socket.io-client/dist/socket.io.js
    ./lib/socket.io-client/dist/socket.io.min.js
    ./lib/underscore/underscore.js
    ./lib/underscore/underscore-min.js
  )
  libs.each do |lib|
    FileUtils.cp(lib, './dist/js/lib/')
  end
end

pre_package

CrxMake.make(
  :ex_dir => './',
  :crx_output => './package/',
  :verbose => true,
  :ignorefile => /\.(?:rb|watchr)/,
  :ignoredir => /(?:\.git|src|package|lib)/
)
