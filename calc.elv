#!/usr/local/bin/elvish
use math
use str
use re

# Catppuccin Mocha colors
var colors = [
  &mauve="#cba6f7"
  &red="#f38ba8"
  &text="#cdd6f4"
  &surface0="#313244"
]

fn parse_pixels {|input|
  var match = (re:find '(\d+)' $input)
  if (== (count $match) 0) {
    put 0
  } else {
    put (num $match[groups][1][text])
  }
}

fn parse_size {|input|
  var match = (re:find '(\d+\.?\d*)([a-zA-Z"]*)\s*$' $input)
  if (== (count $match) 0) {
    put 0
  } else {
    var value = (num $match[groups][1][text])
    var unit = $match[groups][2][text]
    if (or (eq $unit "") (eq $unit '"')) {
      put $value
    } elif (eq $unit 'cm') {
      put (/ $value 2.54)
    } elif (eq $unit 'mm') {
      put (/ $value 25.4)
    } else {
      put $value
    }
  }
}

fn calculate_dpi {|width height diagonal|
  var diagonal_pixels = (math:sqrt (+ (* $width $width) (* $height $height)))
  var dpi = (/ $diagonal_pixels $diagonal)
  math:round (/ (math:round (* $dpi 100)) 100)
}

fn main {
  gum style "DPI Calculator"

  var width = (gum input --prompt "Enter screen width in pixels: " --placeholder "e.g. 1920 or 1920px" --prompt.foreground $colors[mauve] --placeholder.foreground $colors[surface0] --cursor.foreground $colors[mauve])
  var height = (gum input --prompt "Enter screen height in pixels: " --placeholder "e.g. 1080 or 1080px" --prompt.foreground $colors[mauve] --placeholder.foreground $colors[surface0] --cursor.foreground $colors[mauve])
  var diagonal = (gum input --prompt "Enter screen diagonal size: " --placeholder "e.g. 24, 24\", 60.96cm, 609.6mm" --prompt.foreground $colors[mauve] --placeholder.foreground $colors[surface0] --cursor.foreground $colors[mauve])

  if (or (eq $width "") (eq $height "") (eq $diagonal "")) {
    gum style --foreground $colors[red] "Error: All fields must be filled."
    exit 1
  }

  var width_px = (parse_pixels $width)
  var height_px = (parse_pixels $height)
  var diagonal_in = (parse_size $diagonal)

  var dpi = (calculate_dpi $width_px $height_px $diagonal_in)

  gum style --foreground $colors[mauve] --bold "Calculated DPI: "$dpi

  if ?(gum confirm --prompt.foreground $colors[mauve] --selected.foreground $colors[mauve] "Calculate another?") {
    main
  }
}

main

exit 0
