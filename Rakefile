require 'fileutils'

require 'bundler/setup'
require 'extensionator'

task :default => 'extension'

task :extension => 'extension:package'
namespace :extension do
  PACKAGE_OPTION = {
    inject_key: false,
    exclude:
      Regexp.union(
        *%w(Rakefile Gemfile Gemfile.lock package.json yarn.lock docker-compose.yml Dockerfile .swp),
        *%w(.git src package .sass-cache node_modules) #.map {|dir| Regexp.escape(dir) }
      )
  }

  desc 'Setup resources for packaging'
  task :setup => %w(clean libraries:setup compile:all)

  desc 'Package extension as zip'
  task :package => %w(setup js:compress) do
    Extensionator.zip('.', 'package/nothub.zip', PACKAGE_OPTION)
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

  desc 'Compile CoffeeScript to JavaScript'
  task :coffee do
    require 'coffee-script'

    Dir['./src/js/*.coffee'].each do |coffee|
      dist = CoffeeScript.compile(File.read(coffee))
      File.write("./dist/js/#{File.basename(coffee, 'coffee')}js", dist)
    end
  end

  desc 'Compile haml to html'
  task :haml do
    require 'haml'
    require 'haml/exec'

    Dir['./src/*.haml'].each do |haml|
      $stdout = StringIO.new
      opts = Haml::Exec::Haml.new(['--no-escape-attrs', haml])
      opts.parse
      File.write("./dist/#{File.basename(haml, 'haml')}html", $stdout.string)
      $stdout = STDOUT
    end
  end

  desc 'Compile scss to css'
  task :scss do
    require 'sassc'

    Dir['./src/css/*.scss'].each do |scss|
      css = File.basename(scss, 'scss')
      dist = SassC::Engine.new(File.read(scss), style: :compressed).render
      File.write("dist/css/#{css}css", dist)
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
  JS_LIBRARIES = %w(
    ./node_modules/wolfy87-eventemitter/EventEmitter.js
    ./node_modules/wolfy87-eventemitter/EventEmitter.min.js
    ./node_modules/socket.io-client/dist/socket.io.js
    ./node_modules/socket.io-client/dist/socket.io.min.js
    ./node_modules/jquery/dist/jquery.js
    ./node_modules/jquery/dist/jquery.min.js
  )

  WEB_FONTS = %w(
    ./vendor/fonts/ChelseaMarket-Regular.ttf
  )

  desc 'Setup related libraries'
  task :setup do
    JS_LIBRARIES.each do |lib|
      FileUtils.cp(lib, './dist/js/lib/')
    end
    WEB_FONTS.each do |lib|
      FileUtils.cp(lib, './dist/css/')
    end
  end

  desc 'Clean up placed libraries'
  task :clean do
    Dir['./dist/js/lib/*.js'].each do |path|
      FileUtils.rm(path)
    end
    Dir['./dist/css/*.ttf'].each do |path|
      FileUtils.rm(path)
    end
  end
end

namespace :js do
  desc 'Compress JavaScripts'
  task :compress do
    require 'uglifier'

    Dir['./dist/js/*.js'].each do |path|
      source = File.read(path)
      File.open(path, 'w') do |f|
        f << Uglifier.compile(source)
      end
    end
  end
end
