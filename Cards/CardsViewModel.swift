//
//  CardsViewModel.swift
//  Cards
//
//  Created by Joshua Fisher on 1/4/18.
//  Copyright © 2018 Joshua Fisher. All rights reserved.
//

import UIKit

enum CardModel: Equatable {
    case plain(uid: UUID, palette: [UIColor])

    static func ==(_ lhs: CardModel, _ rhs: CardModel) -> Bool {
        switch (lhs, rhs) {
        case (.plain(let a, _), .plain(let b, _)):
            return a == b
        }
    }
}

struct CardsViewModel {
    var stop = Drawer.Stop.expanded
    // index is only valid when cardModels.count > 0
    var index = Int(0)
    var cardModels: [CardModel] = []
}
