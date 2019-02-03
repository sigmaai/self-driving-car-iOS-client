//
//  SteeringPathMessage.swift
//  Self-Driving Car User Client
//
//  Created by Yongyang Nie on 2/3/19.
//  Copyright © 2019 Yongyang Nie. All rights reserved.
//

import UIKit
import ObjectMapper

public class SteeringPathMessage: RBSMessage {
    
    public var header: HeaderMessage?
    public var angle_value = Float()
    public var path_x = [Float]()
    public var path_y = [Float]()
    
    public override init() {
        super.init()
        header = HeaderMessage()
    }
    
    public required init?(map: Map) {
        super.init(map: map)
    }
    
    override public func mapping(map: Map) {
        header <- map["header"]
        path_x <- map["path_x"]
        path_y <- map["path_y"]
    }
}
