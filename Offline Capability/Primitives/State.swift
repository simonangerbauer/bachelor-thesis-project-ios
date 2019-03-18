//
//  State.swift
//  Offline Capability
//
//  Created by Simon Angerbauer on 13.03.19.
//  Copyright © 2019 Simon Angerbauer. All rights reserved.
//

import Foundation

enum State: Int {
    case Unchanged = 0
    case Modified = 1
    case Added = 2
    case Deleted = 3
}
