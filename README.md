# fluent-plugin-mixi_community

Fluentd input plugin from Mixi community.

## Installation

Add this line to your application's Gemfile:

    gem 'fluent-plugin-mixi_community'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-mixi_community

## Usage

    # fluent.conf
    <source>
        type mixi_community

        tag mixi

        community_id 12345

        # Regexp for thread title
        thread_title_pattern 雑談|要望
        # Top N threads to watch
        recent_threads_num 4

        # optional, default=true
        # omit output when startup
        silent_startup true

        # Pit ID for Mixi account('email' and 'password' required)
        pit_id mixi

        # Update interval[sec]
        interval_sec 20
    </source>

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Changes

### 0.0.2

* Dependency updated: mixi-community 0.0.3

### 0.0.1

* Initial release.
