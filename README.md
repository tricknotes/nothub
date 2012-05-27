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

* [CoffeeScript](http://jashkenas.github.com/coffee-script/) (=> 1.2.0)

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
(The MIT License)

Copyright (c) 2012 Ryunosuke SATO &lt;tricknotes.rs@gmail.com&gt;

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
