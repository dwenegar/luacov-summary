# luacov-summary

A LuaCov reporter printing a simple summary.

## Installation

```shell
luarocks install dwenegar/luarocks-summary
```

## Usage

Add the following to your `.luacov` file.

```lua
reporter = summary
```

## Configuration

The reporter can be configured by adding the following table to your `.luacov`
file, and customizing it to your liking.

```lua
summary = {
  user_color = false, -- if `true` the summary will be printed using colors
  threshold = {
    low = 0.25,       -- upper limit of what it's considered low coverage
    fair = 0.65,      -- upper limit of what it's considered fair coverage
    good = 0.80       -- upper limit of what it's considered good coverage
  }
}
```
