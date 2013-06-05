# Diffident

[![Gem Version](https://badge.fury.io/rb/diffident.png)](http://badge.fury.io/rb/diffident)
[![Build Status](https://travis-ci.org/my-codeworks/diffident.png?branch=master)](https://travis-ci.org/my-codeworks/diffident)
[![Code Climate](https://codeclimate.com/github/my-codeworks/diffident.png)](https://codeclimate.com/github/my-codeworks/diffident)

> Based on the [differ](http://github.com/pvande/differ) gem by Pieter Vande Bruggen

Diffident is a flexible, pure-Ruby diff library, suitable for use in both command line scripts and web applications.  The flexibility comes from the fact that diffs can be built at completely arbitrary levels of granularity (some common ones are built-in), and can be output in a variety of formats.

It also gives you raw access to the diff structure, should you need it, so you can build whatever you need that needs a diff.

## Internals

Diffident uses the Ruby StringScan class to walk through the input and collect differances. It records additions, subtractions, changes and can merge two diffs that might additionally contain conflicts.

## Installation

### Bundler

Add this to your `Gemfile`

```ruby
gem 'diffident'
```

and run bundle to install

```bash
bundle install
```

### Manual

Install it via `gem`

```bash
sudo gem install diffident
```

and require it in your project

```ruby
require 'diffident'
```

## How do I use this thing?

There are a number of ways to use Diffident, depending on your situation and needs. Lets examplify:

```ruby
@original = "Epic lolcat fail!"
@current  = "Epic wolfman fail!"
```

There are a number of built-in diff_by_* methods to choose from for standard use:

```ruby
Diffident.diff_by_line(@current, @original)
# => {"Epic lolcat fail!" >> "Epic wolfman fail!"}

Diffident.diff_by_word(@current, @original)
# => Epic {"lolcat" >> "wolfman"} fail!

Diffident.diff_by_char(@current, @original)
# => Epic {+"wo"}l{-"olcat "}f{+"m"}a{+"n fa"}il!
```

### Ok, but that doesn't quite cover my case, I have to split by "whatever".

No problem, you can call diff directly and supply your own boundary string:

```ruby
Diffident.diff(@current, @original) # Implicitly by line by default
# => {"Epic lolcat fail!" >> "Epic wolfman fail!"}

Diffident.diff(@current, @original, 'i')
# => Epi{"c lolcat fa" >> "c wolfman fa"}il
```

### Yeah, thats nice. But a simple string might not always cut it...

Well, you can supply a regex instead of your string if you have to:

```ruby
Diffident.diff(@original, @current, /[a-z]i/)
# => E{"c wolfman f" >> "c lolcat f"}l!
```

Include a capture group if you want to keep the delimiter:

```ruby
Diffident.diff(@original, @current, /([a-z]i)/)
# => Epi{"c wolfman f" >> "c lolcat f"}ail!
```

### Ok, ok, but I don't like having to write "Diffident" everywhere.

If you would like something a little more inline you can `require 'diffident/string'` to get some added inline string magic:

```ruby
@current.diff(@original) # Implicitly by line by default
# => {"Epic lolcat fail!" >> "Epic wolfman fail!"}
```

Or a lot more inline:

```ruby
@current - @original # Implicitly by line by default
# => {"Epic lolcat fail!" >> "Epic wolfman fail!"}

Diffident.delimiter = ' ' # Custom string
@current - @original
# => Epic {"lolcat" >> "wolfman"} fail!

Diffident.delimiter = /[a-z]i/ # Custom regex without capture group
@original - @current
# => E{"c wolfman f" >> "c lolcat f"}l!

Diffident.delimiter = /([a-z]i)/ # Custom regex with capture group
@original - @current
# => Epi{"c wolfman f" >> "c lolcat f"}ail!
```

So we've pretty much got you covered.

## What about output formatting?

Need a diffidentent output format?  We've got a few of those too:

```ruby
Diffident.format = :ascii  # Default
Diffident.format = :color
Diffident.format = :html

Diffident.format = MyCustomFormatModule
```

The formatter must respond to the call method that takes an instant of the Change class as an argument and returns a string.

### But I don't want to change the system-wide default for only a single diff output!

Yeah, we either:

```ruby
diff = @current - @original
diff.format_as(:color)
```

Or with your own formatter:

```ruby
diff = @current - @original
diff.format_as(->(c){c.to_s})
```

## Copyright

> Know always right from wrong, and let others see your good works. - Pieter Vande Bruggen

The MIT License (MIT)

Copyright (c) 2013 my codeworks.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
