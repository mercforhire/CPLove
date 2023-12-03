//
//  AppSettingsManager.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-28.
//

import Foundation

enum Environments: String {
    case production
    case development
    
    func hostUrl() -> String {
        switch self {
        case .production:
            return "https://cplovedating.com/cp-love/"
        case .development:
            return "http://23.22.223.16:9098/cp-love/"
        }
    }
    
    func s3RootURL() -> String {
        switch self {
        case .production:
            return "https://cplove-app-prod.s3.amazonaws.com/"
        case .development:
            return "https://cplove-app-test.s3.amazonaws.com/"
        }
        
    }
    
    func bucketName() -> String {
        switch self {
        case .production:
            return "cplove-app-prod"
        case .development:
            return "cplove-app-test"
        }
        
    }
    
    func s3Key() -> String {
        switch self {
        case .production:
            return "AKIAWCR5T7PCEZO4DHGW"
        case .development:
            return "AKIAWCR5T7PCEZO4DHGW"
        }
    }
    
    func accessKey() -> String {
        switch self {
        case .production:
            return "OaL1pOiBmpplFJ3eomRAgCyD4//HMuGGjmZfw/aS"
        case .development:
            return "OaL1pOiBmpplFJ3eomRAgCyD4//HMuGGjmZfw/aS"
        }
    }
}

class AppSettingsManager {
    static let shared = AppSettingsManager()
    
    private let AppSettingsKey: String = "AppSettings"
    private let EnvironmentKey: String = "Environment"
    private let GetStartedViewedKey: String = "GetStartedViewed"
    private let LastUsedEmailKey: String = "LastUsedEmail"
    private let DeviceToken: String = "DeviceToken"
    private let LastSetActiveTime: String = "LastSetActiveTime"
    private let LastShownVIPDialogTime: String = "LastShownVIPDialogTime"
    private let MatchedWithUsers: String = "MatchedWithUsers"
    private let DatersFilterParamsKey: String = "DatersFilterParams"
    private let CupidsFilterParamsKey: String = "CupidsFilterParams"
    
    private let defaults = UserDefaults.standard
    private var settings: [String: Any] = [:]
    
    init() {
        loadSettingsFromPersistence()
    }
    
    private func loadSettingsFromPersistence() {
        //load previous Settings
        settings = defaults.dictionary(forKey: AppSettingsKey) ?? [:]
    }
    
    private func saveSettings() {
        defaults.set(settings, forKey: AppSettingsKey)
        defaults.synchronize()
    }
    
    func getEnvironment() -> Environments {
        return Environments(rawValue: (settings[EnvironmentKey] as? String) ?? "") ?? .production
    }
    
    func setEnvironment(environments: Environments) {
        settings[EnvironmentKey] = environments.rawValue
        saveSettings()
    }
    
    func isGetStartedViewed() -> Bool {
        return settings[GetStartedViewedKey] != nil
    }
    
    func setGetStartedViewed(viewed: Bool) {
        if viewed {
            settings[GetStartedViewedKey] = true
        } else {
            settings[GetStartedViewedKey] = nil
        }
        saveSettings()
    }
    
    func getLastUsedEmail() -> String? {
        return settings[LastUsedEmailKey] as? String
    }
    
    func setLastUsedEmail(email: String?) {
        settings[LastUsedEmailKey] = email
        saveSettings()
    }
    
    func getDeviceToken() -> String? {
        return settings[DeviceToken] as? String
    }
    
    func setDeviceToken(token: String?) {
        settings[DeviceToken] = token
        saveSettings()
    }
    
    func getLastSetActiveTime() -> Date? {
        return settings[LastSetActiveTime] as? Date
    }
    
    func setLastSetActiveTime(date: Date) {
        settings[LastSetActiveTime] = date
        saveSettings()
    }
    
    func getLastShownVIPDialogTime() -> Date? {
        return settings[LastShownVIPDialogTime] as? Date
    }
    
    func setLastShownVIPDialogTime(date: Date) {
        settings[LastShownVIPDialogTime] = date
        saveSettings()
    }
    
    func getMatchedWithUsers() -> [String] {
        return settings[MatchedWithUsers] as? [String] ?? []
    }
    
    func addMatchedWithUsers(userId: String) {
        var userIds: [String] = (settings[MatchedWithUsers] as? [String]) ?? []
        userIds.append(userId)
        settings[MatchedWithUsers] = userIds
        saveSettings()
    }
    
    func getDatersFilterParams() -> UserQueryParams? {
        if let data = settings[DatersFilterParamsKey] as? Data {
            return UserQueryParams.decodeFromData(data: data)
        }
        return nil
    }
    
    func setDatersFilterParams(params: UserQueryParams) {
        if let data = params.encodeToData() {
            settings[DatersFilterParamsKey] = data
            saveSettings()
        }
    }
    
    func getCupidsFilterParams() -> UserQueryParams? {
        if let data = settings[CupidsFilterParamsKey] as? Data {
            return UserQueryParams.decodeFromData(data: data)
        }
        return nil
    }
    
    func setCupidsFilterParams(params: UserQueryParams) {
        if let data = params.encodeToData() {
            settings[CupidsFilterParamsKey] = data
            saveSettings()
        }
    }
    
    func resetSettings() {
        // don't forget the environment settings
        let current = getEnvironment()
        settings = [:]
        settings[EnvironmentKey] = current.rawValue
        defaults.set(settings, forKey: AppSettingsKey)
        defaults.synchronize()
    }
}
