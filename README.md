[![Build Status](https://travis-ci.org/fsaar/tflapp.svg?branch=develop)](https://travis-ci.org/fsaar/tflapp)
[![Code Coverage](https://codecov.io/gh/fsaar/tflapp/coverage.svg?branch=feature/swift4)](https://codecov.io/gh/fsaar/tflapp/branch/feature%2Fswift4)

# London Bus Stops

An iOS app based on [TfL's unified API](https://api.tfl.gov.uk/) to show current bus stops around your current location instigated by my passion for Swift.

## Installation

The project is made available under the MIT license. You need Xcode 9 since the app is based on Swift 4. To use it, you have to [setup a TfL account](https://api-portal.tfl.gov.uk/login) and create an API key and identifier. There are two ways of getting key and identifier into the app. The straightforward one is just to paste them into TFLRequestmanager. The alternate approach is to create an .env file in the project's root directory and add them in the following format:

    TFLApplicationID="XXXXXXX"
    TFLApplicationKey="XXXXXXXXX"

I added a build step to the project which looks for the .env file and copies the keys out of this file into TFLRequestManager.

You can change the app in any way you like but mind that the use of TfL's unified API is subject to their [terms & conditions](https://tfl.gov.uk/corporate/terms-and-conditions/transport-data-service).

## Acknowledgement

API: TfL unified API

Icon Design: Pedro Santana (zoidfactory@gmail.com) 


