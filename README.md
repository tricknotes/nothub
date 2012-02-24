# NotHub

NotHub is a notification client for [GitHub](http://github.com).

Web: http://nothub.org/

## Setup

``` sh
$ git clone git://github.com/tricknotes/nothub.git ./nothub
$ cd nothub

$ git submodule init
$ git submodule update

$ bundle install
```

## Compile

Requirements:

- [CoffeeScript](http://jashkenas.github.com/coffee-script/) (~> 1.2.0)

``` sh
$ rake extension:package:crx
```

## Install

Open `./package/nothub.crx` using Google Chrome.

## For developers

### Install without packaging

``` sh
$ rake libraries:setup
$ rake compile
```

And install to Google Chrome.

### Auto Compile

Supported auto compile, if you use [watchr](https://github.com/mynyml/watchr) and [growlnotify](http://growl.info/extras.php#growlnotify).

* CoffeeScript

``` sh
$ watchr coffee-script.watchr
```

* Haml

``` sh
$ watchr haml.watchr
```

* SCSS

``` sh
$ watchr scss.watchr
```

## License

Licensed under MIT.
