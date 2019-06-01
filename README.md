# ofx

## Description

A multi-tool for working with openFrameworks addons.

## Features

- Installation
  - Build 3rd party libraries via apothecary.
  - Install package-managed dependencies.
  - Install shared data.
  - Install example data.

## Getting Started

### Commands

### Help

To get help:

`./ofx -h`

### To Install

To istall Apothecary and its dependencies:

`./ofx install apothecary`

Some addons (e.g. [ofxDlib](https://github.com/bakercp/ofxDlib/tree/master/shared/data)) have scripts for downloading shared data. These scripts are bash scripts and reside in the `ADDON/shared/data` folder. To run all of the shared data scripts:

`./ofx install shared_data`

Some addon examples (e.g. [ofxDlib](https://github.com/bakercp/ofxDlib/blob/master/example_bridge_of_to_dlib/bin/data/data.txt)) have lists of required data in a `data.txt` file. To download and copy or link that data, run:

`./ofx install example_data`

To do all of the above:

`./ofx bootstrap`

### To Clean

TODO.

## Troubleshooting

TODO.

## Documentation

TODO.

## Build Status

TODO.

## Compatibility

The `stable` branch of this repository is meant to be compatible with the openFrameworks [stable branch](https://github.com/openframeworks/openFrameworks/tree/stable), which corresponds to the latest official openFrameworks release.

The `master` branch of this repository is meant to be compatible with the openFrameworks [master branch](https://github.com/openframeworks/openFrameworks/tree/master).

Some past openFrameworks releases are supported via tagged versions, but only `stable` and `master` branches are actively supported.

## Versioning

This project uses Semantic Versioning, although strict adherence will only come into effect at version 1.0.0.

## Licensing

See [LICENSE.md](LICENSE.md).

## Contributing

Pull Requests are always welcome, so if you make any improvements please feel free to float them back upstream :)

1.  Fork this repository.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

