# midi-jruby

Realtime MIDI IO with JRuby using the javax.sound.midi API.

In the interest of allowing people on other platforms to utilize your code, you should consider using [unimidi](http://github.com/arirusso/unimidi).  Unimidi is a platform independent wrapper that implements midi-jruby and has a similar API.  

## Features

* Simplified API
* Input and output on multiple devices concurrently
* Generalized handling of different MIDI Message types (including SysEx)
* Timestamped input events

## Install

If you're using Bundler, add this line to your application's Gemfile:

`gem "midi-jruby"`

Otherwise

`gem install midi-jruby`
	
## Examples

* [Input](http://github.com/arirusso/midi-jruby/blob/master/examples/input.rb)
* [Output](http://github.com/arirusso/midi-jruby/blob/master/examples/output.rb)

## Issues

There is [an issue](http://stackoverflow.com/questions/8148898/java-midi-in-mac-osx-broken) that causes javax.sound.midi not to be able to send SysEx messages in some versions of OSX.

## Documentation

* [rdoc](http://rdoc.info/gems/midi-jruby)

## Author 

[Ari Russo](http://github.com/arirusso) <ari.russo at gmail.com>
		
## License

Apache 2.0, See the file LICENSE

Copyright (c) 2011-2014 Ari Russo