//
//  HelpingDelegates.swift
//  PERS
//
//  Created by Buzzware Tech on 16/06/2021.
//

import Foundation

protocol PassDataDelegate {
    func passCurrentLocation(data:LocationModel)
}

protocol FriendRequestsDelegate {
    func updateFriendRequestData(data:[FriendRequestModel])
}
