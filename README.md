![](https://img.shields.io/badge/Swift-4.1-orange.svg)
[![Travis Build Status](https://travis-ci.org/fsaar/tflapp.svg?branch=master)](https://travis-ci.org/fsaar/tflapp)
[![Bitrise Build Status](https://www.bitrise.io/app/57e558f6294006e4/status.svg?token=DDsEZOktnPuT6q5sZJrbwQ&branch=master)](https://www.bitrise.io/app/57e558f6294006e4)
[![Code Coverage](https://codecov.io/gh/fsaar/tflapp/coverage.svg?branch=master)](https://codecov.io/gh/fsaar/tflapp/branch/master)
[![Code Climate](https://codeclimate.com/github/fsaar/tflapp/badges/gpa.svg)](https://codeclimate.com/github/fsaar/tflapp)
[![codebeat badge](https://codebeat.co/badges/4ab21651-9ae0-423b-a49f-412427a2d2d5)](https://codebeat.co/projects/github-com-fsaar-tflapp-master)

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


