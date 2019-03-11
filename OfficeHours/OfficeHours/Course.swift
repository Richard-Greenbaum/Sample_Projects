//
//  File.swift
//  OfficeHours
//
//  Created by Richard Greenbaum on 9/16/17.
//  Copyright © 2017 Richard Greenbaum. All rights reserved.
//

import Foundation

class Course {
    
    private var _Sunday: [Array<Int>]!
    private var _Monday: [Array<Int>]!
    private var _Tuesday: [Array<Int>]!
    private var _Wednesday: [Array<Int>]!
    private var _Thursday: [Array<Int>]!
    private var _Friday: [Array<Int>]!
    private var _Saturday: [Array<Int>]!
    
    var Sunday: [Array<Int>] {
        return _Sunday
    }
    
    var Monday: [Array<Int>]{
        return _Monday
    }
    
    var Tuesday: [Array<Int>]{
        return _Tuesday
    }
    
    var Wedneaday: [Array<Int>]{
        return _Wednesday
    }
    
    var Thursday: [Array<Int>] {
        return _Thursday
    }
    
    var Friday: [Array<Int>] {
        return _Friday
    }
    
    var Saturday: [Array<Int>] {
        return _Saturday
    }
    
    init(hours: [Array<Array<Int>>]) {
        _Sunday = hours[0]
        _Monday = hours[1]
        _Tuesday = hours[2]
        _Wednesday = hours[3]
        _Thursday = hours[4]
        _Friday = hours[5]
        _Saturday = hours[6]
        
    }
    
    
}
