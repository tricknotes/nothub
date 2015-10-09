require 'fileutils'

require 'crxmake'

task :default => 'extension'

task :extension => 'extension:package'
namespace :extension do
  PACKAGE_OPTION = {
    :ex_dir => './',
    :crx_output => './package/nothub.crx',
    :zip_output => './package/nothub.zip',
    :verbose => true,
    :ignorefile => /(?:\.watchr)|Rakefile|Gemfile|\.git|\.swp|\.pem/,
    :ignoredir => /(?:\.git|src|package|submodules|\.sass-cache)/
  }

  desc 'Setup resources for packaging'
  task :setup => %w(clean libraries:setup compile:all)

  task :package => 'package:all'
  namespace :package do
    desc 'Package extension as crx and zip'
    task :all => %w(crx zip)

    desc 'Package extension as crx'
    task :crx => %w(setup) do
      CrxMake.make(PACKAGE_OPTION)
    end

    desc 'Package extension as zip'
    task :zip => %w(setup js:compress) do
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
    require 'sass'
    require 'sass/exec'

    Dir['./src/css/*.scss'].each do |scss|
      css = File.basename(scss, 'scss')
      opts = Sass::Exec::SassScss.new([scss, "dist/css/#{css}css"], :scss)
      opts.parse
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
    ./submodules/EventEmitter/src/EventEmitter.js
    ./submodules/EventEmitter/src/EventEmitter.min.js
    ./submodules/socket.io-client/dist/socket.io.js
    ./submodules/socket.io-client/dist/socket.io.min.js
    ./submodules/underscore/underscore.js
    ./submodules/underscore/underscore-min.js
    ./submodules/jquery/dist/jquery.js
    ./submodules/jquery/dist/jquery.min.js
  )

  WEB_FONTS = %w(
    ./submodules/Chelsea_Market/ChelseaMarket-Regular.ttf
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
