//
//  Constants.swift
//  Access Path
//
//  Created by Nick Sinagra on 5/15/18.
//  Copyright © 2018 pathVu. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps


/**
 * This struct contains URLs to all the map layers
 */
struct MapLayers {
    static let transitType = "transit"
    static let crowdsourceType = "crowdsource"
    static let curbrampType = "curbramp"
    static let sidewalkType = "sidewalk"
    static let entranceType = "entrance"
    static let indoorType = "indoor"
    
    static let transitLayerURL = URL(string: "https://geoprod.pathvu.com/arcgis/rest/services/pathvu/pathVu_Routing_Map/MapServer/0")

    static let curbRampsLayerURL = URL(string: "https://geoprod.pathvu.com/arcgis/rest/services/pathvu/pathVu_Routing_Map/MapServer/1")

    // new dev Sidewalk URl
    static let sidewalkLayerURL = URL(string:"https://geoprod.pathvu.com/arcgis/rest/services/pathvu/pathVu_Routing_Map/FeatureServer/2")

    //Added new url for crowdSource
    // new dev CrowdSource URl
    static let crowdsourcingLayerURL = URL(string:"https://geoprod.pathvu.com/arcgis/rest/services/pathvu/pathVu_CrowdSource/MapServer/0")

    static let crowedReportUrl = "https://pathvudata.com/accesspathweb/crowdsourcingproc_ios_v2.php" //version v2 new
    
    //static let crowedReportUrl = "https://pathvudata.com/accesspathweb/crowdsourcingproc_ios.php" old version first
}

/**
 * This struct contains URLs to ArcGIS tasks
 */
struct RoutingUrls {
    static let locatorTaskURL = URL(string: "http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer")
    static let routeTaskURL = URL(string:"https://pathvudata.com/api1/api/routing//* removed for security purposes */")
    static let routeURL = URL(string: "https://pathvudata.com/api1/api/routing//* removed for security purposes */")
    
//    static let getRouteQueryURL = URL(string:"http://geodev.pathvu.com:6080/arcgis/rest/services/pathVu/pathVu_Network_AGS_DEV/NAServer/Route/solve?")
//
//
//    //Wheelchair
//    static let wheelChairUrl_WC34 = URL(string:"http://geodev.pathvu.com:6080/arcgis/rest/services/Presets/WC34/NAServer/Route") // WC34 for th>= 3 etc..
//
//    static let wheelChairUrl_WC12 = URL(string:"http://geodev.pathvu.com:6080/arcgis/rest/services/Presets/WC12/NAServer/Route")
//
//    //Walk
//    static let walkUrl_WC34 = URL(string:"http://geodev.pathvu.com:6080/arcgis/rest/services/Presets/Walk34/NAServer/Route") // WC34 for th>= 3 etc..
//
//    static let walkUrl_WC12 = URL(string:"http://geodev.pathvu.com:6080/arcgis/rest/services/Presets/Walk12/NAServer/Route")
}

struct ThumbsUpVoteApi {
    static let thumbsUpURL = URL(string: "https://pathvudata.com/accesspathweb/crowdsourcevote.php")
    static let thumbsTotalVoteURL = URL(string: "https://pathvudata.com/accesspathweb/crowdsourcevotecount.php")
}

struct RouteParameters {
    // pathVu account ID
    let uacctid:Int
    // user type
    let tid:Int
    // tripping hazard parameter
    let thw:Int
    // running slope parameter
    let rsw:Int
    // cross slope parameter
    let csw:Int
    // roughness parameter
    let row:Int
    // starting location
    let from:CLLocationCoordinate2D
    // destination location
    let to:CLLocationCoordinate2D
}

/**
 * This struct contains all the app colors
 */
struct AppColors {
    
    //Colors for textboxes
    static let caretColor : UIColor = UIColor(red: 1.00, green: 0.58, blue: 0.00, alpha: 1.0)
    static let darkBlue : UIColor = UIColor(red: 0.16, green: 0.14, blue: 0.25, alpha: 1.0)
    static let successBorder : UIColor = UIColor(red: 0.78, green: 0.86, blue: 0.36, alpha: 1.0)
    static let successBackground : UIColor = UIColor(red: 0.96, green: 0.97, blue: 0.91, alpha: 1.0)
    static let errorBorder : UIColor = UIColor(red: 0.92, green: 0.38, blue: 0.38, alpha: 1.0)
    static let errorBackground : UIColor = UIColor(red: 0.97, green: 0.92, blue: 0.92, alpha: 1.0)
    
    //Colors for checkbox buttons
    static let defaultBorder : UIColor = UIColor(red: 0.78, green: 0.78, blue: 0.80, alpha: 1.0)
    static let selectedBorder : UIColor = UIColor(red: 1.00, green: 0.58, blue: 0.00, alpha: 1.0)
    static let selectedBackground : UIColor = UIColor(red: 1.00, green: 0.97, blue: 0.93, alpha: 1.0)
    
    //Gradient Colors
    static let gradStart : UIColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.0)
    static let gradEnd : UIColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
    static let lightBlue: UIColor = UIColor(red: 0.93, green: 0.97, blue: 0.97, alpha: 1.0)
    static let disabledBackground: UIColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
    static let disabledBorder: UIColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0)
    
    //Shadow Color
    static let shadowColor:UIColor = UIColor(red: 0.16, green: 0.14, blue: 0.25, alpha: 0.2)
    
    //Misc Button Colors
    static let facebook: UIColor = UIColor(red: 0.24, green: 0.35, blue: 0.59, alpha: 1.0)
    static let google: UIColor = UIColor(red: 0.24, green: 0.51, blue: 0.94, alpha: 1.0)
    static let blueButton: UIColor = UIColor(red:0.77, green:0.95, blue:0.95, alpha:1.0)
}


/**
 * This struct contains all Shared Preferences keys
 */
struct PrefKeys {
    static let firstNameKey = "firstName"
    static let lastNameKey = "lastName"
    static let emailKey = "email"
    static let aidKey = "aid"
    static let uidKey = "uid"
    static let passwordKey = "password"
    
    static let thComfortKey = "trippingHazardComfortLevel"
    static let rComfortKey = "roughnessComfortLevel"
    static let rsComfortKey = "runningSlopeComfortLevel"
    static let csComfortKey = "crossSlopeComfortLevel"
    static let crComfortKey = "curbRampsComfortLevel"
    static let wComfortKey = "widthComfortLevel"
    static let soComfortKey = "obstructionsComfortLevel"
    static let iComfortKey = "intersectionsComfortLevel"
    
    //add byb chetu rs, th LImit
    static let thlimitComfortKey = "thlimitComfortLevel"
    static let rolimitComfortKey = "rolimitComfortLevel"
    static let rslimitComfortKey = "rslimitComfortLevel"
    static let cslimitComfortKey = "cslimitComfortLevel"
    
    static let thAlertKey = "trippingHazardAlert"
    static let rAlertKey = "roughnessAlert"
    static let rsAlertKey = "runningSlopeAlert"
    static let csAlertKey = "crossSlopeAlert"
    static let crAlertKey = "curbRampsAlert"
    static let wAlertKey = "widthAlert"
    static let soAlertKey = "obstructionsAlert"
    static let iAlertKey = "intersectionsAlert"
    
    //add by chetu rs, th LImit
    static let thlimitAlertKey = "thlimitAlert"
    static let rolimitAlertKey = "rolimitAlert"
    static let rslimitAlertKey = "rslimitAlert"
    static let cslimitAlertKey = "cslimitAlert"
    static let usernameKey = "username"
    static let usernameSet = "usernameSet"
    static let uTypeKey = "utype"
    static let signedInKey = "signedIn"
    static let guestAccountKey = "guestAccount"
    static let onboardProgKey = "onboardingProgress"
    static let notificationKey = "notificationKey"
    
    static let curbRampsKey = "curbRampsLayer"
    static let transitStopsKey = "transitStopsLayer"
    static let crowdSourceKey = "crowdSourceLayer"
    
    static let soundKey = "sound"
    static let iMUAlert = "IMU Alert"
    static let receiveAlertsIMU = "Would you like to receive alerts for IMU?"
    static let IMU = "IMU"
    
    static let settingsTypeKey = "settingsType"
    static let googleSignUpKey = "googleSignUp"
    static let usernameSetKey = "usernameSet"
    static let sessionImuVaue = "sessionImuVaue"
    static let gSignupKey = "gSignUpSuccess"
    static let IMUSettingsType = "IMUSettingsType"
    static let nextWeatherUpdate = "nextWeatherUpdate"
    static let lastWeatherTemp = "lastWeatherTemp"
    static let lastWeatherIcon = "lastWeatherIcon"
    static let lastWeatherConditions = "lastWeatherConditions:"
    
    static let thComfortKeyValue = "trippingHazardComfortLevelValue"
    static let rComfortKeyValue = "roughnessComfortLevelValue"
    static let rsComfortKeyValue = "runningSlopeComfortLevelValue"
    static let csComfortKeyValue = "crossSlopeComfortLevelValue"
    static let crComfortKeyValue = "curbRampsComfortLevelValue"
    static let wComfortKeyValue = "widthComfortLevelValue"
    static let soComfortKeyValue = "obstructionsComfortLevelValue"
    static let iComfortKeyValue = "intersectionsComfortLevelValue"
    
    //add byb chetu rs, th LImit
    static let thlimitComfortKeyValue = "thlimitComfortLevelValue"
    static let rolimitComfortKeyValue = "rolimitComfortLevelValue"
    static let rslimitComfortKeyValue = "rslimitComfortLevelValue"
    static let cslimitComfortKeyValue = "cslimitComfortLevelValue"
    
    static let comfortKeys = [thComfortKeyValue, rComfortKeyValue, rsComfortKeyValue, csComfortKeyValue, crComfortKeyValue, wComfortKeyValue, soComfortKeyValue, iComfortKeyValue,thlimitComfortKeyValue,rolimitComfortKeyValue,rslimitComfortKeyValue,cslimitComfortKeyValue ,PrefKeys.uTypeKey]
    
    
    
    /*  CREATED by Chetu
     // add New Alert limit and Restriction wit key Value
     */
    static let thAlertKeyValue = "trippingHazardAlertValue"
    static let rAlertKeyValue = "roughnessAlertValue"
    static let rsAlertKeyValue = "runningSlopeAlertValue"
    static let csAlertKeyValue = "crossSlopeAlertValue"
    static let crAlertKeyValue = "curbRampsAlertValue"
    static let wAlertKeyValue = "widthAlertValue"
    static let soAlertKeyValue = "obstructionsAlertValue"
    static let iAlertKeyValue = "intersectionsAlertValue"
    
    static let favoritePlaceAlertKey = "trippingFavoritePlace"
    
    //add by chetu rs, th LImit
    static let thlimitAlertKeyValue = "thlimitAlertValue"
    static let rolimitAlertKeyValue = "rolimitAlertValue"
    static let rslimitAlertKeyValue = "rslimitAlertValue"
    static let cslimitAlertKeyValue = "cslimitAlertValue"
    
    
    static let alertKeys = [thAlertKeyValue, rAlertKeyValue, rsAlertKeyValue, csAlertKeyValue, crAlertKeyValue, wAlertKeyValue, soAlertKeyValue, iAlertKeyValue,thlimitAlertKeyValue,rolimitAlertKeyValue,rslimitAlertKeyValue,cslimitAlertKeyValue,PrefKeys.uTypeKey]
    
    static let placeString = "PlaceName"
    static let stAddres = "StAddr"
    
}


/**
 Changed By chetu
 *  This struct contains Direction sign (N,W,E,S)
 */

struct DirectionSymbol{
    static let northDirection = "N"
    static let westDirection = "W"
    static let eastDirection = "E"
    static let southDirection = "S"
}


/**
 *  Changed By chetu
 *  Localization strings
 */
struct AlertConstant {
    
    static let notRouteAvailable =  NSLocalizedString("Route Not Available", comment: "")
    static let notRouteDisplay =    NSLocalizedString("A route is not available for the specified destination.", comment: "")
    static let okString =           NSLocalizedString("ok", comment: "")
    static let approachingHazard =  NSLocalizedString("Approaching hazard", comment: "")
    
    
    static let pleaseEnterCorrectEmailAdd =  NSLocalizedString("Please enter a correct email address", comment: "")
    static let usernameCharacterTwoMoreChar =    NSLocalizedString("Usernames must be 2 or more characters", comment: "")
    static let looksGood =           NSLocalizedString("Looks Good!", comment: "")
    static let usernameAlreadyExist =  NSLocalizedString("Username already exists", comment: "")
    static let userNameChangedSuccesfully =  NSLocalizedString("Username Changed Successfully!", comment: "")
    
    
    static let successfullyUpdated =  NSLocalizedString("Successfully updated!", comment: "")
    static let searchLocationAddress =    NSLocalizedString("Search A Location Or Address", comment: "")
    
    
    static let disAgreeTerm =    NSLocalizedString("Disagree with the terms and close pathVu?", comment: "")
    static let confirm =           NSLocalizedString("Confirm", comment: "")
    static let yes =  NSLocalizedString("Yes", comment: "")
    static let no =    NSLocalizedString("No", comment: "")
    static let cancel =           NSLocalizedString("Cancel", comment: "")
    static let failed =  NSLocalizedString("Failed", comment: "")
    static let signOutKey =           NSLocalizedString("Sign Out", comment: "")
    static let sureSignOut =  NSLocalizedString("Are you sure you want to sign out of pathVu?", comment: "")
    
    
    static let unableToConnectPathServer =    NSLocalizedString("Unable to connect to pathVu servers", comment: "")
    static let weatherUnavailable =           NSLocalizedString("Weather Unavailable", comment: "")
    static let noInternetConnection =  NSLocalizedString("No Internet Connection", comment: "")
    static let offlineConnectInternet =    NSLocalizedString("You are offline, please connect to the internet and try again.", comment: "")
    
    
    static let reportingNotAvailable =    NSLocalizedString("Reporting Not Available", comment: "")
    static let guestAccountNotPermitted = NSLocalizedString("Guest accounts are not permitted to report obstructions.Please sign up with a non-guest account.", comment: "")
    static let accountAlreadyExists =    NSLocalizedString("Account Already Exists", comment: "")
}

/**
 * User Type Keys
 */
struct UserTypeKeys {
    static let blindKey = "blindImpairedkey"
    static let sightedWalkingKey = "sightedandWalking"
    static let whellChairKey = "wheelChairkey"
    static let caneWalkUserKey = "canewalkUserkey"
}



/**
 * Alert String structure
 */
struct AlertSettingString {
    static let thKey =  "th"
    static let thAlertKey = "thalert"
    static let rKey = "r"
    static let rAlertKey = "ralert"
    static let rsKey = "rs"
    static let rsAlertKey = "rsalert"
    static let csKey =  "cs"
    static let csAlertKey = "csalert"
    static let crKey = "cr"
    static let crAlertKey = "cralert"
    static let wKey = "w"
    static let WAlertKey = "walert"
    static let soKey = "so"
    static let soAlertKey = "soalert"
    static let iKey = "i"
    static let iAlertKey = "ialert"
    static let uTypeKey = "utype"
}


//let correctEmailAddress = "Please enter a correct email address"
//let userNameToMoreCharString = "Usernames must be 2 or more characters"
//let lookGoodString = "Looks Good!"
//let userNameExistString = "Username already exists"
//let userNameChangeString = "Username Changed Successfully!"
let pathString = "Set Path To"
let newName = "Please enter a new name"
let successString = "Successfully updated!"
let searchPlaceholderString = "Search A Location Or Address"
let favouriteString = "Please enter the favourite address name?"
let locationAddress = "Please enter the location address"
let passwordMustContainMoreCharacter = "Passwords must contain 6 or more characters"
let accountAlreadyExist = "Account Already Exists"

let destinationVoiceText = "Enter your Destination"
let beginVoiceText = "Where does your path begin"
let enterfavoritePlace = "Enter a favorite place"
let editFavorite = "Edit button"

let navigateString = "Navigating to"
let feetString = "feet"
let maneuverString = "Maneuvers"

let Mute = "Mute"
let Unmute = "UnMute"
let Repeat = "Repeat"
let Map = "Map"
let lastStep = "Last Step"
let list = "List"
let step = "Steps"

let stepOptions = ["0 steps", "1 step", "2+ steps"]

let getFavoritesURLString = "https://pathvudata.com/api1/api/users/favorites?/* removed for security purposes */"
let addFavoriteURLString = "https://pathvudata.com/api1/api/users/addfavorite?/* removed for security purposes */"
let getRecentsURLString = "https://pathvudata.com/api1/api/users/recents?/* removed for security purposes */"
let addRecentURLString = "https://pathvudata.com/api1/api/users/addrecent?/* removed for security purposes */"

/**
 * Created by Chetu
 * Valid Email Format String
 */
struct ValidEmailFormattor {
    static let validFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    static let selfMatchString = "SELF MATCHES %@"
    static let dateFormat = "MMddyyyyHHmmss"
    static let yearDateFormattor = "yyyy-mm-dd hh:mm:ss"
}


/**
 * Created by Chetu
 * Axis Keys String
 */
struct AxisKeys {
    static let uAcctid = "uacctid"
    static let uSession = "usession"
    static let uTime = "utime"
    static let latKey = "lat"
    static let lonKey = "lon"
    static let accXaxis = "accxaxis"
    static let accYaxis = "accyaxis"
    static let accZaxis = "acczaxis"
    
    static let gyoXaxis = "gyoaxis"
    static let gyoYaxis = "gyoyaxis"
    static let gyoZaxis = "gyozaxis"
    static let magXaxis = "magxaxis"
    static let magYaxis = "magyaxis"
    static let magZaxis = "magzaxis"
}



/**
 * Created by Chetu
 * Axis Keys String
 */
struct ArcGISLicenceKey {
    static let licenceKey = "runtimelite,1000,rud4860087466,none,5H80TK8EL9GP6XCFK121"
    static let accessPathiOSSupport = "Access Path iOS Support"
    static let nickSinagraEmail = "nick.sinagra@pathvu.com"
}

//Change by IQ
//Key for GooglePlaces and GoogleMaps API
let GoogleAPILicenseKey = "/* removed for security purposes */"

//MainSettingsAlertSetting Strings
//Th string
let trippingHazardString = "Tripping Hazard Alert"
let wouldYouLikeReceiveStringTH = "Would you like to receive alerts about tripping hazards in your path?"
let trippingHazardButton = "Tripping Hazards"

let alert = "Alert"
let wouldYouLikeReceiveStringRough = "Would you like to receive alerts about roughness in your path?"
let roughnessButton = "Roughness"

let runningSlopeString = "Running Slope Alert"
let wouldYouLikeReceiveStringSlop = "Would you like to receive alerts about running slope in your path?"
let runningSlopButton = "Running Slope"

let crossSlopAlertString = "Cross Slope Alert"
let wouldYouLikeReceiveStringCross = "Would you like to receive alerts about cross slope in your path?"
let crossSlopButton =  "Cross Slope"

let curbRampAlertString = "Curb Ramps Alert"
let wouldYouLikeReceiveStringCurbRamp =  "Would you like to receive alerts about curb ramps in your path?"
let curbRampButton = "Curb Ramps"

let widthAlertString = "Width Alert"
let wouldYouLikeReceiveStringWidth = "Would you like to receive alerts about width in your path?"
let widthButton = "Width"

let obstructiobAlertString = "Obstructions Alert"
let wouldYouLikeReceiveStringObstruction = "Would you like to receive alerts about obstructions in your path?"
let obstructionButton = "Obstructions"

let instructionAlertString = "Intersections Alert"
let wouldYouLikeReceiveStringInstruction = "Would you like to receive alerts about intersections in your path?"
let instructiionButton =  "Intersections"

let turnOn = "Turn On Alerts for"
let turnOff = "Turn Off Alerts for"
let settingTypeString = "settingsType"
let submitButtonString = "Submitting..."
let succString = "Success"

//Comfort level key Strings
let thComfortLevelString = "Tripping Hazard Comfort"
let comfortLevelStringTH = "Select the level that best matches your comfort navigating tripping hazards"

let roughnessComfortString = "Roughness Comfort"
let roughnessLevelStringRS = "Select the level that best matches your comfort with sidewalk roughness"

let runSlopComfortLevelString = "Running Slope Comfort"
let comfortLevelStringRSlop = "Select the level that best matches your comfort with running slope"

let crossComfortLevelString = "Cross Slope Comfort"
let comfortLevelStringCrossSlop = "Select the level that best matches your comfort with cross slope"

let curbRampComfortLevelString = "Curb Ramps Comfort"
let comfortLevelStringCR = "Select the level that best matches your comfort with curb ramps"

let wComfort = "Width Comfort"
let comfortLevelStringWC = "Select the level that best matches your comfort with sidewalk width"

let obstructionComfortLevelString = "Obstructions Comfort"
let comfortLevelStringObstruction = "Select the level that best matches your comfort with obstructions"

let instructionComfortLevelString =  "Intersections Comfort"
let comfortLevelStringInstruction = "Select the level that best matches your comfort with intersections"

let defaultZoomLevel:Float = 18.0

//Button title text
let setContinueAlert = "Set and Continue to Set Alerts"
let titleContinue = "Continue"
let nowString = "now"

//Maneuver image string names
let currentLocationImg = "current_location_marker.png"
let head_straightImg = "head_straight.png"
let turn_rightImg = "turn_right.png"
let turn_leftImg = "turn_left.png"
let thumbs_upImg = "thumbs_up.png"
let map_iconImg = "map-icon.png"
let list_iconImg = "list-icon.png"
let location_marker = "location-marker"
let sound_on_icon = "sound-on-icon"
let sound_off_icon = "sound-off-icon"
let report_icon = "report-icon"
let entrance_icon = "entrance-icon.png"
let indoor_icon = "indoor-accessibility-icon.png"

//for attributes limit string
let thlimitName = "THLimit"
let rolimitName = "ROLimit"
let rslimitName = "RSLimit"
let cslimitName = "CSLimit"
let PAICostName =  "PAI_Cost"

let thwString = "THw"
let rswString = "RSw"
let cswString = "CSw"
let rowString = "ROw"


let transitStoplayerString = "transitStopsLayer"
let curbRamplayerString = "curbRampsLayer"
let crowdSourceString = "crowdSourceLayer"
let sidewalkStringKey = "sidewalkLayer"

//pathVu maplayer type data
let indoorArray = ["Male/Female", "Family", "ADA Accessible", "Locked Door"]
let entranceArray = ["Ramp", "0 Steps", "1 Step", "2+ steps"]

/**
 * sidewalk type layer structure
 */
struct TrippingHazradsType {
    static let trippingHazard = "Tripping Hazard\n"
    static let noSidewalk = "No Sidewalk\n"
    static let noCurbRamp = "No Curb Ramp\n"
    static let construction = "Construction\n"
    static let othersType = "Other\n"
    static let entranceType = "Entrance\n"
    static let indoorType = "Indoor Accessibility\n"
}


/**
 * Curb ramp text to use for the curb ramps
 */
struct CurbRampType {
    static let Poor = "Poor" //1
    static let Moderate = "Moderate" //2
    static let Good = "Good" //3
}


/**
 *  Text read if voice over is on 
 */
struct ReadTextVoice {
    static let textBoxClear = "text box clear"
    static let edit = "edit"
    static let currentLocationRead = "Use current location as starting point" //3
    static let reCenter = "recenter"
}



/**
 * FavoriteAlert String structure
 */
struct FavoriteAlertType {
    static let favoriteAlertDescrpition = "Would you like to receive alerts as you pass your Favorite locations?"
    static let favoriteAlertON = "Turn on alerts for Favorites"
    static let favoriteAlertOff = "Turn off alerts for Favorites"
    static let favorite_placeApproaching = "Approaching favorite place"
    static let closeAlert = "close"
    
    static let hazart_placeApproaching = "Approaching hazard"
    static let favorite_identifier = "Favorite Place"
    static let hazard_identifier = "Hazard place"
    
}


/*
 * Favorites Place Address Coordinate list
 */
struct FavoriteCoordinateListModel {
    var favName : String?
    var favAddress: String?
    var favoritePlaceLattitude : Double?
    var favoritePlacelongitude : Double?
    var favPlacesStatus : Bool?
    var favPlaceIndex : Int?
}




/**
 * Screen Name structure
 */
struct ScreenNameStruct {
    static let termOfAgreementString = "TermsOfAgreement"
    static let fullTermOfAgreementString = "FullTermsOfAgreement"
    static let createNewAccountString = "CreateNewAccount"
    static let nameAndEmailSignupString = "NameAndEmailSignUp"
    static let userNameString = "UsernameScreen"
    static let comforSettingMainString = "ComfortSettingsMain"
    static let obstructionListString = "ObstructionList"
    static let runInBackgroundString = "RunInBackground"
    static let logInMainString = "LogInMain"
}


/**
 * Storyboard identifier constant
 */
struct StoryboardIdentifier {
    static let onboardingObstructionList = "unwindToOnboardingObstructionList"
    static let onboardingUserNameScreen = "UsernameScreen"
    static let gettingStarted1Storyboard = "GettingStarted1"
    static let getStarted1 = "GetStarted1"
    static let mapLayerIdentifier = "MapLayers"
    static let onboardingComfortSettingIdentifier = "OnboardingComfortSetting"
    static let navigationHomeIdentifier = "NavigationHome"
    static let mainIdentifier = "Main"
    static let onboardingComfortSetMainIdentifier = "ComfortSettingsMain"
    static let loginMainIdentifier = "LogInMain"
    static let createNewAccount = "CreateNewAccount"
    static let popUpIdentifier = "PopupVC"
    static let curbRampPopUpIdentifier = "CurbRampPopupVC"
    static let transitionPopUpIdentifier = "TransitPopUpAlert"
    static let sidewalkPopUpIdentifier = "SidewalkPopAlert"
    static let hazardPopUpIdentifier = "CustomHazardPopUpVC"
    static let unwindSegueToVC1 = "unwindSegueToVC1"
    static let customCellIdentifier = "customcell"
    static let tempDestninationPreviewIdentifer = "TempDestinationPreviewMap"
    static let unwindSegueToObsList = "unwindSegueToObsList"
    static let TemporaryNavigation = "TemporaryNavigation"
    static let FavoritePlaceEdit = "FavoritePlaceEdit"
    static let FavoritePlaceInfo = "FavoritePlaceInfo"
    static let CustomCell = "CustomCell"
    static let ConfirmationScreen = "ConfirmationScreen"
    static let SubmissionScreen = "SubmissionScreen"
    static let SelectTypeScreen = "SelectTypeScreen"
    static let unwindToObstructionList = "unwindToObstructionList"
    static let MainComfortLevelPage = "MainComfortLevelPage"
    static let unwindToMainSettings = "unwindToMainSettings"
    static let ObstructionList = "ObstructionList"
    static let NearbyPlacesTableVC = "NearbyPlacesVC"
    static let EntranceInfoScreen = "EntranceInfoScreen"
    static let IndoorInfoScreen = "IndoorInfoScreen"
    static let IndoorPopupIdentifier = "IndoorPopupVC"
    static let EntrancePopupIdentifier = "EntrancePopupVC"
}




/**
 * UserGestNumber String
 */
struct UserGestNumber {
    static let gestNumber = "3846491724"
    static let userNotFound = "li003 User not found"
    static let accountNotFound = "fp001 User not found" //forgot password
    static let incorrectPassword = "li004 Incorrect password"
    static let accountDontExist = "Account does not exist"
    static let sentResetMessage = "Your reset password link is sent to your email id"
    static let sentMessage = "sent"
    static let incorrectPWD = "Incorrect password"
    static let noStatus = "no"
}


/**
 Changed By chetu
 * This struct contains Direction text for manuever Direction (N,W,E,S)
 */
struct menueverDirectionText{
    static let northDirection = "north"
    static let westDirection = "west"
    static let eastDirection = "east"
    static let southDirection = "south"
    static let northEastDirection = "north-east"
    static let northWestDirection = "north-west"
    static let southWestDirection = "south-west"
    static let southEastDirection = "south-east"
    static let leftdirection = "Turn left"
    static let rightDirection = "Turn right"
    static let slightLeft = "Slight left"
    static let slightRight = "Slight right"
    static let continueDirection = "Continue"
    static let uturnDirection = "U-turn"
    static let towardsDirection = "towards"
    static let finishDirection = "Finish"
    static let startDirection = "Start"
}

/**
 * Changed by Chetu
 * User Type default comfort setting when user select for user all type.
 */
struct defaultSettingsValue {
    
    //Selected Blind Visually impaired
    static let blindTrippingHazard = 1
    static let blindRoughness = 3
    static let blindRunningSlope = 3
    static let blindCrossSlope = 4
    static let blindWidth = 4
    
    //Selected Sighted and Walking
    static let sightedTrippingHazard = 4
    static let sightedRoughness = 4
    static let sightedRunningSlope = 3
    static let sightedCrossSlope = 4
    static let sightedWidth = 4
    
    //Selected Wheelchair/Scooter User
    static let wheelchairTrippingHazard = 1
    static let wheelchairRoughness = 2
    static let wheelchairRunningSlope = 2
    static let wheelchairCrossSlope = 2
    static let wheelchairWidth = 1
    
    //Selected Cane/walkerUser
    static let walkerUserTrippingHazard = 2
    static let walkerUserRoughness = 3
    static let walkerUserRunningSlope = 1
    static let walkerUserCrossSlope = 3
    static let walkerUserWidth = 3
}




/**
 * Changed by Chetu
 * User Type with limit values
 */
struct userTypeSettingValue{
    
    static let blindUserValue = 1
    static let blindthlimitValue = 12
    static let blindrolimitValue = 1000
    static let blindrslimitValue = 12
    static let blindcslimitValue = 16
    
    
    static let sightUserValue = 2
    static let  sightthlimitValue = 12
    static let  sightrolimitValue = 1000
    static let  sightrslimitValue = 12
    static let  sightcslimitValue = 16
    
    
    static let wheelChairUserValue = 3
    static let wheelChairthlimitValue = 5
    static let wheelChairrolimitValue = 400
    static let wheelChairrslimitValue = 8
    static let wheelChaircslimitValue = 5
    
    static let caneUserValues = 4
    static let canethlimitValue = 6
    static let canerolimitValue = 400
    static let canerslimitValue = 4
    static let canecslimitValue = 4
}

// URL strings for pathVu API
struct APIURL{
    // 
    static let newimudataUrl = "https://pathvudata.com/accesspathweb/newimudata.php"
    static let hazardReportURL = "https://pathvudata.com/api1/api/locations/hazards/add?/* removed for security purposes */"
    static let entranceReportURL = "https://pathvudata.com/api1/api/locations/entrances/add/* removed for security purposes */"
    static let getEntranceURL = "https://pathvudata.com/api1/api/locations/entrances//* removed for security purposes */"
    static let indoorReportURL = "https://pathvudata.com/api1/api/locations/indoor/add/* removed for security purposes */"
    static let getIndoorURL = "https://pathvudata.com/api1/api/locations/indoor//* removed for security purposes */"
    
    static let setTypeURL = "https://pathvudata.com/api1/api/users/settype/* removed for security purposes */"
    static let changeUsernameURL = "https://pathvudata.com/api1/api/users/updateusername/* removed for security purposes */"
}

struct GoogleURLs {
    static let nearBySearchURLString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
}
