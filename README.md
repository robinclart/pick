# Pick

Pick is an opionated CLI options parser.

## Usage

```ruby
require "pick"

command = Pick.resolve(ARGV, {
  defaults: {
    "--debug" => false,
  },
  aliases: {
    "-d" => "--debug",
  }
})

command.args => []
command.opts => {}
```

## Options, Flags and ENV

- Option (example: `--force`)
- Option with argument (example: `--force=no`)
- Reversible option (example: `--no-force`)
- Flag (example: `-f`)
- Flag with argument (example: `-fno`)
- ENV (example: `FORCE=1`)

## Types

- string
- integer (example: 1)
- float (example: 1.0)
- list (ex: [1 500ms 4MB 2017-01-15 robinclart/pick ssh://github.com/robinclart/pick.git yes now])
- milliseconds (example: 1ms)
- seconds (example: 1s)
- minutes (example: 1m)
- hours (example: 1h)
- days (example: 1d)
- bytes (example: 1B)
- kilobytes (example: 1kB)
- megabytes (example: 1MB)
- gigabytes (example: 1GB)
- terabytes (example: 1TB)
- petabytes (example: 1PB)
- date (example: 2017-01-15)
- time (example: 2017-01-15T12:00:00Z)
- path (example: robinclart/pick)
- uri (example: ssh://github.com/robinclart/pick.git)
- boolean (yes, no)
- keyword (now, today, yesterday, tomorrow)
