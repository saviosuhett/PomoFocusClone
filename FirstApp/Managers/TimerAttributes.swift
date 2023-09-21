//
//  TimerAttributes.swift
//  Pomofocus Clone
//
//  Created by Savio on 02/09/23.
//

import Foundation
import CoreLocation
import WidgetKit
import UserNotifications
import ActivityKit

struct TimerAttributes : ActivityAttributes {
    public typealias TimerStatus = ContentState
    
    public struct ContentState : Codable, Hashable
    {
        var endTime : Date
    }
    
    var timerName : String
    
}
