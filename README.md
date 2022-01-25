# dit

A command line interface for Reminders on macOS.

dit is not complete, and its structure would have to change substantially to become complete.

* See existing Lists
* Query Reminders in those lists
  - filtering by completion status
  - for due date in open or closed time ranges
  - for completion date in open or closed time ranges  
* Create Reminders
  - in arbitrary lists
  - in a default list
  - with a due date specified as an interval from today
  - with a recurrence specified as an time interval[<sup>‡</sup>](#recurrence)
* Mark reminders as done/undone

## Installing

The `dit` CLI tool is available via a [Homebrew](https://brew.sh) [tap](https://docs.brew.sh/Taps#the-brew-tap-command):

`brew install fcanas/tap/dit`

or

```
brew tap fcanas/tap
brew install dit
```

## Documentation

### `dit`

```
OVERVIEW: Manipulate reminders

USAGE: dit <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  query (default)         Show Reminders.
  create                  Create a new reminder.
  lists                   Display Lists of Reminders
  configure               Configure default settings.
  do                      Mark reminders as done.

  See 'dit help <subcommand>' for detailed help.
```

### `dit query`

```
OVERVIEW: Show Reminders.

Date filters --starting and --ending operate on the due date for
incomplete tasks and the completion date for complete tasks.

USAGE: dit query [--all] [--complete] [--incomplete] [--list <list>] [--starting <starting>] [--ending <ending>]

OPTIONS:
  --all/--complete/--incomplete
                          Show Reminders based on completion status. (default: incomplete)
  -l, --list <list>       The name of the list to query. Default can be set with the
                          configure command. 
  -s, --starting <starting>
                          Beginning of time range to query within, specified relative to
                          today. e.g. 2d specifies to search for Reminders
                          beginning two days from now. 
  -e, --ending <ending>   End of time range to query within, specified relative to today.
                          e.g. 3w specifies to search for Reminders before three
                          weeks from now. 
  --version               Show the version.
  -h, --help              Show help information.
```

### `dit create`

```
OVERVIEW: Create a new reminder.

USAGE: dit create [--list <list>] <title> [--due-in <due-in>] [--repeats <repeats>]

ARGUMENTS:
  <title>                 Title for the new reminder 

OPTIONS:
  -l, --list <list>       The list to create the reminder in 
  -d, --due-in <due-in>   An interval specifying how far from now the reminder is due,
                          specified in minutes, hours, days,
                          weeks, months, and years. These units
                          can be combined in ascending order, e.g. 1y2m17h22s 
  -r, --repeats <repeats> How often the reminder should repeat, in days,
                          weeks, months, and years. These units
                          cannot be comined. e.g. 3w, y, d,
                          24d 
  --version               Show the version.
  -h, --help              Show help information.
```

<a name="recurrence"><sup>‡</sup></a> Recurrence intervals can currently only be made in the form of "Every _N_ ( days | weeks | months | years )"

### `dit lists`

```
OVERVIEW: Display Lists of Reminders

USAGE: dit lists

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.
```

### `dit configure`

```
OVERVIEW: Configure default settings.

USAGE: dit configure [--default-list <default-list>]

OPTIONS:
  -d, --default-list <default-list>
                          Set the default List when creating a reminder 
  --version               Show the version.
  -h, --help              Show help information.
```

### `dit do`

```
OVERVIEW: Mark reminders as done.

Do is an interactive command.The flags and options form a query, and present a numbered
list of items that can be selected for toggling. Date filters --starting and
--ending operate on the due date for incomplete tasks and the completion date for
complete tasks.

USAGE: dit do [--all] [--complete] [--incomplete] [--list <list>] [--starting <starting>] [--ending <ending>]

OPTIONS:
  --all/--complete/--incomplete
                          Show Reminders based on completion status. (default: incomplete)
  -l, --list <list>       The name of the list to query. Default can be set with the
                          configure command. 
  -s, --starting <starting>
                          Beginning of time range to query within, specified relative to
                          today. e.g. 2d specifies to search for Reminders
                          beginning two days from now. 
  -e, --ending <ending>   End of time range to query within, specified relative to today.
                          e.g. 3w specifies to search for Reminders before three
                          weeks from now. 
  --version               Show the version.
  -h, --help              Show help information.
```
