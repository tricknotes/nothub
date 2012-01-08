require 'fileutils'
require 'open3'

require 'rubygems'
require 'crxmake'

task :default => 'extension'

task :extension => 'extension:package'
namespace :extension do
  PACKAGE_OPTION = {
    :ex_dir => './',
    :crx_output => './package/extension.crx',
    :zip_output => './package/extension.zip',
    :verbose => true,
    :ignorefile => /(?:\.watchr)|Rakefile|\.git|\.swp/,
    :ignoredir => /(?:\.git|src|package|lib|\.sass-cache)/
  }

  desc 'Setup resources for packagng'
  task :setup => %w(clean libraries:setup compile:all)

  task :package => 'package:zip'
  namespace :package do
    desc 'Package extension as crx'
    task :crx => %(setup) do
      CrxMake.make(PACKAGE_OPTION)
    end

    desc 'Package extension as zip'
    task :zip => %(setup) do
      CrxMake.zip(PACKAGE_OPTION)
    end
  end

  desc 'Clean up packaged archives'
  task :clean do
    packaged = Dir['./*.pem'] + Dir['./package/*']
    packaged.each do |path|
      FileUtils.rm(path)
    end
  end
end

task :compile => 'compile:all'
namespace :compile do
  class CompileError < StandardError; end

  desc 'Compile all files'
  task 'all' => %w(clean coffee haml scss)

  class CoffeeScriptCompileError < CompileError; end

  desc 'Compile CoffeeScript to JavaScript'
  task :coffee do
    stdin, stdout, stderr = Open3.popen3('coffee -o ./dist/js/ -c ./src/js/*.coffee')
    error = stderr.to_a.join
    throw CoffeeScriptCompileError, error unless error.empty?
  end

  class HamlCompileError < CompileError; end

  desc 'Compile haml to html'
  task :haml do
    Dir['./src/*.haml'].each do |haml|
      stdin, stdout, stderr = Open3.popen3("haml --no-escape-attrs #{haml}")
      error = stderr.to_a.join
      throw HamlCompileError, error unless error.empty?
      File.open("./dist/#{File.basename(haml, 'haml')}html", 'w') do |html|
        html << stdout.to_a.join
      end
    end
  end

  class SCSSCompileError < CompileError; end

  desc 'Compile scss to css'
  task :scss do
    Dir['./src/css/*.scss'].each do |scss|
      css = File.basename(scss, 'scss')
      stdin, stdout, stderr = Open3.popen3("sass #{scss} dist/css/#{css}css")
      error = stderr.to_a.join
      throw SCSSCompileError, error unless error.empty?
    end
  end

  desc 'Clean up compiled files'
  task :clean do
    Dir['./dist/{,css,js}/*.{js,html,css}'].each do |path|
      FileUtils.rm(path)
    end
  end
end

namespace :libraries do
  LIBRARIES = %w(
    ./lib/EventEmitter/src/EventEmitter.js
    ./lib/EventEmitter/src/EventEmitter.min.js
    ./lib/socket.io-client/dist/socket.io.js
    ./lib/socket.io-client/dist/socket.io.min.js
    ./lib/underscore/underscore.js
    ./lib/underscore/underscore-min.js
  )

  desc 'Setup related libraries'
  task :setup do
    LIBRARIES.each do |lib|
      FileUtils.cp(lib, './dist/js/lib/')
    end
  end

  desc 'Clean up placed libraries'
  task :clean do
    Dir['./dist/js/lib/*.js'].each do |path|
      FileUtils.rm(path)
    end
  end
end
