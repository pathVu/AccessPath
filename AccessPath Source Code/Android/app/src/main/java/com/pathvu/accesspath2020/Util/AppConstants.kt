package com.pathvu.accesspath2020.Util

object AppConstants {
    //ServiceURL
    var EMAIL_SIGN_UP_URL = "https://pathvudata.com/accesspathweb/newuser.php"
    var GET_UID_URL = "https://pathvudata.com/accesspathweb/onboardid.php"
    var GET_USERNAME_URL = "https://pathvudata.com/accesspathweb/getusername.php"
    var SET_USERNAME_URL = "https://pathvudata.com/accesspathweb/updateusername.php"
    var INSERT_SETTINGS_URL =
        "https://pathvudata.com/accesspathweb/insertsettings.php"
    var FACEBOOK_SIGN_UP_URL = "https://pathvudata.com/accesspathweb/newfbuser.php"
    var GOOGLE_SIGN_UP_URL = "https://pathvudata.com/accesspathweb/newgoogleuser.php"
    var GUEST_SIGN_UP_URL = "https://pathvudata.com/accesspathweb/newguestuser.php"
    var GET_WEATHER_URL = "https://api.openweathermap.org/data/2.5/weather?lat="
    var LONGITUDE = "&lon="
    var APP_ID = "&appid=86297b6d659bc424d98c8805fbc540fd"
    var FACEBOOK_SIGN_IN_URL =
        "https://pathvudata.com/accesspathweb/signinfbuser.php"
    var GOOGLE_SIGN_IN_URL =
        "https://pathvudata.com/accesspathweb/signingoogleuser.php"
    var EMAIL_SIGN_IN_URL = "https://pathvudata.com/accesspathweb/login_v2.php"
    var FORGOT_PWD_URL = "https://pathvudata.com/accesspathweb/forgotpassword_v2.php"
    var NEW_FAVORITE_URL = "https://pathvudata.com/accesspathweb/newfavorite_v2.php"
    var CHECK_ACTIVATION_URL =
        "https://pathvudata.com/accesspathweb/checkactivation.php"
    var SUBMIT_REPORT_URL =
        "https://pathvudata.com/accesspathweb/crowdsourcinproc_v2.php"
    var GET_FAVORITES_URL =
        "https://pathvudata.com/accesspathweb/getfavorites_v2.php"
    var NEW_RECENT_URL = "https://pathvudata.com/api1/api/users/addrecent"
    var GET_RECENTS_URL = "https://pathvudata.com/accesspathweb/getrecents.php"
    var REMOVE_FAVORITE_URL =
        "https://pathvudata.com/accesspathweb/removefavorite.php"
    var UPDATE_FAVORITE_URL =
        "https://pathvudata.com/accesspathweb/updatefavorite.php"
    var UPDATE_HAZARD_CONFIRMATION =
        "https://pathvudata.com/accesspathweb/crowdsourcevote.php"
    var GET_HAZARD_CONFIRMATION =
        "https://pathvudata.com/accesspathweb/crowdsourcevotecount.php"
    var SOURCE_ADDRESS = "SourceAddress"
    var DESTINATION_ADDRESS = " DestinationAddress"
    var PATH_TYPE = "PathType"
    var DESTINATION_PREVIEW = "DestinationPreview"
    var SET_NEW_PATH = "SetNewPath"
    //Directions
    var NORTH = "N"
    var WEST = "W"
    var EAST = "E"
    var SOUTH = "S"
    var NORTHEAST = "NE"
    var NORTHWEST = "NW"
    var SOUTHWEST = "SW"
    var SOUTHEAST = "SE"
    var SUCCESS = "Success"
    var HAZARD_LAYER = "crowdsourced"
    var TRANSIT_STOP_LAYER = "Transit"
    var CURB_RAMPS_LAYER = "Curb Ramp"
    var PATH_LAYER = "Path"
}

object MapLayers {
    var transitType = "transit"
    var curbRampType = "curbRamp"
    var sidewalkType = "sidewalk"
}
