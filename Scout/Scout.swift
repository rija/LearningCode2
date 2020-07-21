import HeightMap

public struct Scout {
    var ask: Character
    var position: Coordinate
    var orientation: Direction
    var heights: HeightMap
    
    public init(char: Character, at origin: Coordinate, facing: Direction, knowing: HeightMap) {
        self.ask = char
        self.position = origin
        self.orientation = facing
        self.heights = knowing
    }
    
    public func materialize() {
        world.place(self.ask, facing: self.orientation, at: self.position)
    }
    
    public func aim(step: Int, facing: Direction) -> Coordinate {
        switch facing {
        case .north:
            return Coordinate(column: self.position.column, row: self.position.row + step)
        case .east:
            return Coordinate(column: self.position.column + step, row: self.position.row)
        case .south:
            return Coordinate(column: self.position.column, row: self.position.row - step)
        case .west:
            return Coordinate(column: self.position.column - step, row: self.position.row)                                
        }
    }
    
    public func gaze(at view: Horizon) -> Direction {
        switch self.orientation {
        case .north:
            if view == .left {
                return .west
            }
            else if view == .right {
                return .east
            }
            else {
                return .north
            }
        case .east:
            if view == .left {
                return .north
            }
            else if view == .right {
                return .south
            }
            else {
                return .east
            }
        case .south:
            
            if view == .left {
                return .east
            }
            else if view == .right {
                return .west
            }
            else {
                return .south
            }
        case .west:
            if view == .left {
                return .south
            }
            else if view == .right {
                return .north
            }
            else {
                return .west
            }                                
        }
    }
    
    public mutating func leap() {
        self.position = aim(step:1, facing: orientation)
        assert(heights.indexIsValid(row: position.row, column: position.column), "Leap(): Index out of range for pos( \(position.column), \(position.row) )")
        self.ask.jump()
    }
    
    public mutating func turnRight() {
        switch self.orientation {
        case .north:
            self.orientation = .east
        case .east:
            self.orientation = .south
        case .south:
            self.orientation = .west
        case .west:
            self.orientation = .north
        }
        self.ask.turnRight()
    }
    
    mutating func turnLeft() {
        switch self.orientation {
        case .north:
            self.orientation = .west
        case .east:
            self.orientation = .north
        case .south:
            self.orientation = .east
        case .west:
            self.orientation = .south
        }
        self.ask.turnLeft()
    }
    
    public func isReallyBlocked(looking theView: Horizon) -> Bool {
        let oneLevel = 1
        let gazingDirection = gaze(at: theView)
        if heights.isOnWorldEdge(of: gazingDirection, at: self.position) {
            return true
        }
        else if heights.isAtSeaLevel(at: aim(step:1,facing: gazingDirection)) {
            return true
        }
        else if abs(heights.ascent(from: self.position, to: aim(step:1,facing: gazingDirection) )) > oneLevel {
            return true
        }
        return false        
    }
    
    public mutating func jumpAlongTheRightSide() {
        if isReallyBlocked(looking: .forward) && isReallyBlocked(looking: .right) {
            turnLeft()
        }
        else if isReallyBlocked(looking: .right) {
            leap()
        }
        else {
            turnRight()
            leap()
        }
    }
} // end struct Scout


