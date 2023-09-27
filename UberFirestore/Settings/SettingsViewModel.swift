//
//  SettingsViewModel.swift
//  UberFirestore
//
//  Created by Alphan Ogün on 25.09.2023.
//

import Foundation

class SettingsViewModel {
    
    var user: User
    
    var userInfoUpdated = false
    
    func locationText(forType type: LocationType) -> String {
        switch type {
        case .home:
            return user.homeLocation ?? type.subtitle
        case .work:
            return user.workLocation ?? type.subtitle
        }
    }
    
    
    
    init(user: User) {
        self.user = user
    }
}
