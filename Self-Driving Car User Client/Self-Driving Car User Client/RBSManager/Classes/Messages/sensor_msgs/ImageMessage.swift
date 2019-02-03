//
//  TwistMessage.swift
//  ObjectMapper
//
//  Created by Wes Goodhoofd on 2018-01-10.
//

import UIKit
import ObjectMapper

public class ImageMessage: RBSMessage {
    
    public var header: HeaderMessage?
    public var height = Int()
    public var width = Int()
    public var encoding = String()
    public var is_bigendian = Int8()
    public var step = Int32()
    public var data = [UInt8]()
    
    public override init() {
        super.init()
        header = HeaderMessage()
    }
    
    public required init?(map: Map) {
        super.init(map: map)
    }
    
    override public func mapping(map: Map) {
        height <- map["height"]
        width <- map["width"]
        encoding <- map["encoding"]
        is_bigendian <- map["is_bigendian"]
        step <- map["step"]
        data <- map["data"]
    }
}
