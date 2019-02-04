//
//  Float32MultiArray.swift
//  Self-Driving Car User Client
//
//  Created by Yongyang Nie on 2/3/19.
//  Copyright © 2019 Yongyang Nie. All rights reserved.
//

import UIKit
import ObjectMapper

public class Float32MultiArrayMessage: RBSMessage {
    
    public var layout: MultiArrayLayoutMessage?
    public var data = [Float32]()
    
    public override init() {
        super.init()
        layout = MultiArrayLayoutMessage()
    }
    
    public required init?(map: Map) {
        super.init(map: map)
    }
    
    override public func mapping(map: Map) {
        layout <- map["layout"]
        data <- map["data"]
    }
}

