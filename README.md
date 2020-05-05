# NotHub
NotHub is a notification client for [GitHub](http://github.com).

Web: http://nothub.org/

## Setup
``` sh
$ git clone git://github.com/tricknotes/nothub.git ./nothub
$ cd nothub
$ docker-compose build app
$ docker-compose run --rm bundle install
$ docker-compose run --rm yarn install
```

## Compile
Requirements:

* [CoffeeScript](http://jashkenas.github.com/coffee-script/) (>= 1.4.0)

``` sh
$ docker-compose up app
```

## Install
Launch nothub directory from chrome://extensions/ .

## For developers
### Install without packaging
``` sh
$ docker-compose run --rm rake libraries:setup
$ docker-compose run --rm rake compile
```

And install to Google Chrome.

## License
(The MIT License)

Copyright (c) 2012-2013 Ryunosuke SATO &lt;tricknotes.rs@gmail.com&gt;

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
