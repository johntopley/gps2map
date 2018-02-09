# GPS2Map
Creates a Google Map from an input file containing GPS co-ordinates ([GPX](https://en.wikipedia.org/wiki/GPS_Exchange_Format), [KML](https://en.wikipedia.org/wiki/Keyhole_Markup_Language) or [TCX](https://en.wikipedia.org/wiki/Training_Center_XML) format).

## Installation
```
$ gem install gps2map
```

## Prerequisites
A [Google Maps JavaScript API key](https://developers.google.com/maps/documentation/javascript/get-api-key) is required and must be specified in an environment variable named `GOOGLE_MAPS_API_KEY`.

## Usage
```
gps2map generate <input.gpx|.kml|.tcx> <output.html>
```

## Licence
The gem is available as open source under the terms of the [MIT Licence](https://opensource.org/licenses/MIT).

## Copyright
Copyright (C) 2018 John Topley.