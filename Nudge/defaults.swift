//
//  defaults.swift
//  Nudge
//
//  Created by Erik Gomez on 2/8/21.
//

import Foundation

// This is stupid and there has to be a better way but after 5 hours of pain I've given up
// Codable needs an easy way to set default values

let nudgePreferences = nudgePrefs().loadNudgePrefs()
let nudgeDefaults = UserDefaults.standard
let language = NSLocale.current.languageCode!

// optionalFeatures
let optionalFeaturesProfile = nudgeDefaults.dictionary(forKey: "optionalFeatures")
let asyncronousSoftwareUpdate = optionalFeaturesProfile?["asyncronousSoftwareUpdate"] as? Bool ?? nudgePreferences?.optionalFeatures?.asyncronousSoftwareUpdate ?? true
let attemptToFetchMajorUpgrade = optionalFeaturesProfile?["attemptToFetchMajorUpgrade"] as? Bool ?? nudgePreferences?.optionalFeatures?.attemptToFetchMajorUpgrade ?? false
let enforceMinorUpdates = optionalFeaturesProfile?["enforceMinorUpdates"] as? Bool ?? nudgePreferences?.optionalFeatures?.enforceMinorUpdates ?? true

// osVersionRequirements
let majorUpgradeAppPath = getOSVersionRequirementsProfile()?.majorUpgradeAppPath ?? getOSVersionRequirementsJSON()?.majorUpgradeAppPath ?? ""
let requiredInstallationDate = getOSVersionRequirementsProfile()?.requiredInstallationDate ?? getOSVersionRequirementsJSON()?.requiredInstallationDate ?? Date(timeIntervalSince1970: 0)
let requiredMinimumOSVersion = getOSVersionRequirementsProfile()?.requiredMinimumOSVersion ?? getOSVersionRequirementsJSON()?.requiredMinimumOSVersion ?? "0.0"
let aboutUpdateURL = getUpdateURL() ?? ""

// Function to mutate the profile into our required construct and then compare currentOS against targetedOSVersions
func getOSVersionRequirementsProfile() -> OSVersionRequirement? {
    var requirements = [OSVersionRequirement]()
    if let osRequirements = nudgeDefaults.array(forKey: "osVersionRequirements") as? [[String:AnyObject]] {
        for item in osRequirements {
            requirements.append(OSVersionRequirement(fromDictionary: item))
        }
    }
    if !requirements.isEmpty {
        for (_ , subPreferences) in requirements.enumerated() {
            if subPreferences.targetedOSVersions?.contains(OSVersion(ProcessInfo().operatingSystemVersion).description) == true {
                return subPreferences
            }
        }
    }
    return nil
}

// Function to loop through JSON preferences and then compare currentOS against targetedOSVersions
func getOSVersionRequirementsJSON() -> OSVersionRequirement? {
    if let requirements = nudgePreferences?.osVersionRequirements {
        for (_ , subPreferences) in requirements.enumerated() {
            if subPreferences.targetedOSVersions?.contains(OSVersion(ProcessInfo().operatingSystemVersion).description) == true {
                return subPreferences
            }
        }
    }
    return nil
}

// Function to compare current language against the available updateURLs
func getUpdateURL() -> String? {
    if Utils().demoModeEnabled() {
        return "https://support.apple.com/en-us/HT201541"
    }
    if let updates = getOSVersionRequirementsProfile()?.aboutUpdateURLs ?? getOSVersionRequirementsJSON()?.aboutUpdateURLs {
        for (_, subUpdates) in updates.enumerated() {
            if subUpdates.language == language {
                return subUpdates.aboutUpdateURL ?? ""
            }
        }
    }
    return ""
}

// userExperience
let userExperienceProfile = nudgeDefaults.dictionary(forKey: "userExperience")
let allowedDeferrals = userExperienceProfile?["allowedDeferrals"] as? Int ?? nudgePreferences?.userExperience?.allowedDeferrals ?? 1000000
let allowedDeferralsUntilForcedSecondaryQuitButton = userExperienceProfile?["allowedDeferralsUntilForcedSecondaryQuitButton"] as? Int ?? nudgePreferences?.userExperience?.allowedDeferralsUntilForcedSecondaryQuitButton ?? 14
let approachingRefreshCycle = userExperienceProfile?["approachingRefreshCycle"] as? Int ?? nudgePreferences?.userExperience?.approachingRefreshCycle ?? 6000
let approachingWindowTime = userExperienceProfile?["approachingWindowTime"] as? Int ?? nudgePreferences?.userExperience?.approachingWindowTime ?? 72
let elapsedRefreshCycle = userExperienceProfile?["elapsedRefreshCycle"] as? Int ?? nudgePreferences?.userExperience?.elapsedRefreshCycle ?? 300
let imminentRefreshCycle = userExperienceProfile?["imminentRefreshCycle"] as? Int ?? nudgePreferences?.userExperience?.imminentRefeshCycle ?? 600
let imminentWindowTime = userExperienceProfile?["imminentWindowTime"] as? Int ?? nudgePreferences?.userExperience?.imminentWindowTime ?? 24
let initialRefreshCycle = userExperienceProfile?["initialRefreshCycle"] as? Int ?? nudgePreferences?.userExperience?.initialRefreshCycle ?? 18000
let maxRandomDelayInSeconds = userExperienceProfile?["maxRandomDelayInSeconds"] as? Int ?? nudgePreferences?.userExperience?.maxRandomDelayInSeconds ?? 1200
let noTimers = userExperienceProfile?["noTimers"] as? Bool ?? nudgePreferences?.userExperience?.noTimers ?? false
let nudgeRefreshCycle = userExperienceProfile?["nudgeRefreshCycle"] as? Int ?? nudgePreferences?.userExperience?.nudgeRefreshCycle ?? 60
let randomDelay = userExperienceProfile?["randomDelay"] as? Bool ?? nudgePreferences?.userExperience?.randomDelay ?? false

// userInterface
let userInterfaceProfile = nudgeDefaults.dictionary(forKey: "userInterface")
func getuserInterface() -> Element? {
    let updateElements = nudgePreferences?.userInterface?.updateElements
    if updateElements != nil {
        for (_ , subPreferences) in updateElements!.enumerated() {
            if subPreferences.language == language {
                return subPreferences
            }
        }
    }
    return nil
}
let actionButtonText = getuserInterface()?.actionButtonText ?? "Update Device"
func forceScreenShotIconMode() -> Bool {
    if Utils().forceScreenShotIconModeEnabled() {
        return true
    } else {
        return userInterfaceProfile?["forceScreenShotIcon"] as? Bool ?? nudgePreferences?.userInterface?.forceScreenShotIcon ?? false
    }
}
let iconDarkPath = userInterfaceProfile?["iconDarkPath"] as? String ?? nudgePreferences?.userInterface?.iconDarkPath ?? ""
let iconLightPath = userInterfaceProfile?["iconLightPath"] as? String ?? nudgePreferences?.userInterface?.iconLightPath ?? ""
let informationButtonText = getuserInterface()?.informationButtonText ?? "More Info"
let mainContentHeader = getuserInterface()?.mainContentHeader ?? "Your device will restart during this update"
let mainContentNote = getuserInterface()?.mainContentNote ?? "Important Notes"
let mainContentSubHeader = getuserInterface()?.mainContentSubHeader ?? "Updates can take around 30 minutes to complete"
let mainContentText = getuserInterface()?.mainContentText ?? "A fully up-to-date device is required to ensure that IT can accurately protect your device.\n\nIf you do not update your device, you may lose access to some items necessary for your day-to-day tasks.\n\nTo begin the update, simply click on the Update Device button and follow the provided steps."
func getMainHeader() -> String {
    if Utils().demoModeEnabled() {
        return "Your device requires a security update (Demo Mode)"
    } else {
        return getuserInterface()?.mainHeader ?? "Your device requires a security update"
    }
}
let primaryQuitButtonText = getuserInterface()?.primaryQuitButtonText ?? "Later"
let screenShotDarkPath = userInterfaceProfile?["screenShotDarkPath"] as? String ?? nudgePreferences?.userInterface?.screenShotDarkPath ?? ""
let screenShotLightPath = userInterfaceProfile?["screenShotLightPath"] as? String ?? nudgePreferences?.userInterface?.screenShotLightPath ?? ""
let secondaryQuitButtonText = getuserInterface()?.secondaryQuitButtonText ?? "I understand"
func simpleMode() -> Bool {
    if Utils().simpleModeEnabled() {
        return true
    } else {
        return nudgePreferences?.userInterface?.simpleMode ?? false
    }
}
let subHeader = getuserInterface()?.subHeader ?? "A friendly reminder from your local IT team"

// Other important defaults
let acceptableApps = [
    "com.apple.loginwindow",
    "com.apple.systempreferences"
]

// UMAD
// optionalFeatures - UMAD
// TODO: Profile support - not needed for now
let alwaysShowManualEnerllment = nudgePreferences?.optionalFeatures?.umadFeatures?.alwaysShowManulEnrollment ?? false
let depScreenShotPath = nudgePreferences?.optionalFeatures?.umadFeatures?.depScreenShotPath ?? ""
let disableManualEnrollmentForDEP = nudgePreferences?.optionalFeatures?.umadFeatures?.disableManualEnrollmentForDEP ?? false
let enforceMDMInstallation = nudgePreferences?.optionalFeatures?.umadFeatures?.enforceMDMInstallation ?? false
let manulEnrollmentPath = nudgePreferences?.optionalFeatures?.umadFeatures?.manualEnrollmentPath ?? "https://apple.com"
let mdmInformationButtonPath = nudgePreferences?.optionalFeatures?.umadFeatures?.mdmInformationButtonPath ??  "https://github.com/macadmins/umad"
let mdmProfileIdentifier = nudgePreferences?.optionalFeatures?.umadFeatures?.mdmProfileIdentifier ?? "com.example.mdm.profile"
let mdmRequiredInstallationDate = nudgePreferences?.optionalFeatures?.umadFeatures?.mdmRequiredInstallationDate ?? Date(timeIntervalSince1970: 0)
let uamdmScreenShotPath = nudgePreferences?.optionalFeatures?.umadFeatures?.uamdmScreenShotPath ?? ""

// userInterface - UMAD
// TODO: Profile support - not needed for now
func getMDMUserInterface() -> Element? {
    let updateElements = nudgePreferences?.userInterface?.umadElements
    if updateElements != nil {
        for (_ , subPreferences) in updateElements!.enumerated() {
            if subPreferences.language == language {
                return subPreferences
            }
        }
    }
    return nil
}
let mdmActionButtonManualText = getMDMUserInterface()?.actionButtonManualText ?? "Manually Enroll"
let mdmActionButtonText = getMDMUserInterface()?.actionButtonText ?? ""
let mdmActionButtonUAMDMText = getMDMUserInterface()?.actionButtonUAMDMText ?? "Open System Preferences"
let mdmInformationButtonText = getMDMUserInterface()?.informationButtonText ?? "More Info"
let mdmMainContentHeader = getMDMUserInterface()?.mainContentHeader ?? "This process does not require a restart"
let mdmMainContentNote = getMDMUserInterface()?.mainContentNote ?? "Important Notes"
let mdmMainContentText = getMDMUserInterface()?.mainContentText ?? "Enrollment into MDM is required to ensure that IT can protect your computer with basic security necessities like encryption and threat detection.\n\nIf you do not enroll into MDM you may lose access to some items necessary for your day-to-day tasks.\n\nTo enroll, just look for the below notification, and click Details. Once prompted, log in with your username and password."
let mdmMainContentUAMDMText = getMDMUserInterface()?.mainContentUAMDMText ?? "Thank you for enrolling your device into MDM. We sincerely appreciate you doing this in a timely manner.\n\nUnfortunately, your device has been detected as only partially enrolled into our system.\n\nPlease go to System Preferences -> Profiles, click on the Device Enrollment profile and click on the approve button."
let mdmMainHeader = getMDMUserInterface()?.mainHeader ?? "Your device requires management"
let mdmPrimaryQuitButtonText = getMDMUserInterface()?.primaryQuitButtonText ?? "Later"
let mdmSecondaryQuitButtonText = getMDMUserInterface()?.secondaryQuitButtonText ?? "I understand"
let mdmSubHeader = getMDMUserInterface()?.subHeader ?? "A friendly reminder from your local IT team"
