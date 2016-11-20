
# London Bus Stops

An iOS app based on TfL's unified API to show current bus stops around your current location instigated by my passion for Swift.

## Installation

The project is made available under the MIT license. You need Xcode 8 since the app is based on Swift 3. To use it, you have to setup a TfL account and create an API key and identifier. There are two ways of getting key and identifier into the app. The straightforward one is just to paste them into TFLRequestmanager. The alternate approach is to create an .env file in the project's root directory and add them in the following format:

    TFLApplicationID="XXXXXXX"
    TFLApplicationKey="XXXXXXXXX"

I added a build step to the project which looks for the .env file and copies the keys out of this file into TFLRequestManager.

You can change the app in any way you like but mind that the use of TfL's unified API is subject to their terms & conditions.

##URLs

TfL account setup: https://api-portal.tfl.gov.uk/login

TfL API Documentation: https://api.tfl.gov.uk/


