//
//  EmptyResponse.swift
//  SushiWallet
//
//  Created by ym on 2019/04/08.
//  Copyright © 2019 Yuto Mizutani. All rights reserved.
//

import Foundation

struct EmptyResponse: Codable, EntityTranslatable {
    typealias EntityType = Void

    func toEntity() {}
}
