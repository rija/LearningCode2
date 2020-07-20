//  Ingredients:
//  - 2 ridges
//  - 1 river
//  - 1 bridge

let grid = world.allPossibleCoordinates
let rowSize = world.coordinates(inColumns: [0]).count
let columnSize = world.coordinates(inRows: [0]).count


enum Horizon {
    case forward, left, right
}

struct HeightMap {
    let rows: Int, columns: Int
    var grid: [Int]
    let defaultHeight = 0
    
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        grid = Array(repeating: defaultHeight, count: rows * columns)
    }
    
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    subscript(row: Int, column: Int) -> Int {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
    
    var floor: Int {
        grid.min() ?? defaultHeight
    }
    
    var peak: Int {
        grid.max() ?? defaultHeight
    }
    
    func ascent(from pos1: Coordinate, to pos2: Coordinate) -> Int {
    
        assert(indexIsValid(row: pos1.row, column: pos1.column), "Index out of range for pos1")
        assert(indexIsValid(row: pos2.row, column: pos2.column), "Index out of range for pos2")
        
        return grid[pos2.row*rows+pos2.column] - grid[pos1.row*rows+pos1.column]
    }
                
    func isOnWorldEdge(of side: Direction, at pos: Coordinate) -> Bool {
        switch side {
            case .north:
                assert(indexIsValid(row: pos.row, column: pos.column), "Index out of range for pos( \(pos.column), \(pos.row) ) and direction '.north'")           
                return pos.row == (rows - 1 )
            case .east:
            assert(indexIsValid(row: pos.row, column: pos.column), "Index out of range for pos( \(pos.column), \(pos.row) ) and direction '.east'")
                return pos.column == (columns - 1)
            case .south:
                assert(indexIsValid(row: pos.row, column: pos.column), "Index out of range for pos( \(pos.column), \(pos.row) ) and direction '.south'")            
                return pos.row == 0
            case .west:
            assert(indexIsValid(row: pos.row, column: pos.column), "Index out of range for pos( \(pos.column), \(pos.row) ) and direction '.west'")
                return pos.column == 0
            
        }
    } 
    
    
    
    func isAtSeaLevel(at pos: Coordinate) -> Bool {
        return grid[pos.row*rows+pos.column] == grid.min()
    }
}

struct Scout {
    var ask: Character
    var position: Coordinate
    var orientation: Direction
    var heights: HeightMap
    
    init(char: Character, at origin: Coordinate, facing: Direction, knowing: HeightMap) {
        self.ask = char
        self.position = origin
        self.orientation = facing
        self.heights = knowing
    }
    
    func materialize() {
        world.place(self.ask, facing: self.orientation, at: self.position)
    }
    
    func aim(step: Int, facing: Direction) -> Coordinate {
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
    
    func gaze(at view: Horizon) -> Direction {
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
    
    mutating func leap() {
        self.position = aim(step:1, facing: orientation)
                assert(heights.indexIsValid(row: position.row, column: position.column), "Leap(): Index out of range for pos( \(position.column), \(position.row) )")
        self.ask.jump()
    }
    
    mutating func turnRight() {
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
    
    func isReallyBlocked(looking theView: Horizon) -> Bool {
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
    
    mutating func jumpAlongTheRightSide() {
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



func makeValley(grid: [Coordinate], heights: HeightMap) {
    
    for pos in grid {
        if heights.isAtSeaLevel(at: pos) {
            world.removeAllBlocks(at: pos)
            world.place(Water(), at: pos)
        }
        else {
            for eachLevel in heights.floor ... heights[pos.row, pos.column] {
                world.place(Block(), at: pos)
            } 
        }
    }
    
}


// designing the map
var hmap = HeightMap(rows: rowSize, columns: columnSize)
hmap.grid =   [5,4,3,2,1,0,0,1,2,3,4,4]
hmap.grid +=  [5,4,3,2,1,0,0,1,2,3,4,5]
hmap.grid +=  [6,5,4,3,2,1,0,0,1,2,3,6]
hmap.grid +=  [5,4,3,2,1,1,2,0,0,3,4,7]
hmap.grid +=  [5,4,3,2,1,1,0,0,3,4,7,7]
hmap.grid +=  [6,4,3,2,1,0,0,1,2,3,4,7]
hmap.grid +=  [7,4,3,2,1,0,0,1,2,3,4,7]
hmap.grid +=  [8,4,3,2,1,1,0,0,2,3,4,7]
hmap.grid +=  [7,4,3,2,1,1,1,0,0,3,4,7]
hmap.grid +=  [6,4,3,2,1,0,0,0,0,0,4,6]
hmap.grid +=  [6,4,3,2,1,0,0,0,0,0,3,5]
hmap.grid +=  [5,4,3,2,1,0,0,0,1,2,3,4]


// initializing world elements

makeValley(grid: grid,heights: hmap)

var buddy = Scout(char: Character(name: .byte), at: Coordinate(column: 0, row: 0), facing: .north, knowing:hmap)


// unit tests
buddy.materialize()
assert(buddy.position.row == 0 && buddy.position.column == 0, "buddy at 0,0")
assert(buddy.orientation == .north, "buddy facing north")

buddy.leap()
assert(buddy.position.row == 1 && buddy.position.column == 0, "buddy jump forward northbound")
assert(!buddy.isReallyBlocked(looking: .right), "buddy is not right blocked")
assert(buddy.isReallyBlocked(looking: .left), "buddy is left blocked")

buddy.turnRight()
assert(buddy.orientation == .east, "buddy turn right eastward")


buddy.turnLeft()
assert(buddy.orientation == .north, "buddy facing north")
buddy.turnLeft()
assert(buddy.orientation == .west, "buddy facing west")
assert(hmap.isOnWorldEdge(of: .west, at: buddy.position), "buddy is at the western edge of the map")
assert(buddy.isReallyBlocked(looking: .forward), "buddy is front blocked")

// testing adapted right-hand rule algorithm

buddy.turnRight()
buddy.leap()
buddy.turnRight()
buddy.leap()
buddy.turnRight()
buddy.leap()
buddy.leap()
assert(buddy.orientation == .south, "buddy is facing south")
assert(buddy.position.column == 1 && buddy.position.row == 0, "expect (\(buddy.position.column),\(buddy.position.row)) to be (1,0)")
assert(buddy.isReallyBlocked(looking: .forward), "buddy is front blocked")
assert(!buddy.isReallyBlocked(looking: .left), "buddy is not blocked on the left")
assert(!buddy.isReallyBlocked(looking: .right), "buddy is not blocked on the right")

buddy.jumpAlongTheRightSide()    
buddy.turnRight()
assert(buddy.position.column == 0 && buddy.position.row == 0, "expect (\(buddy.position.column),\(buddy.position.row)) to be (0,0)")

buddy.turnLeft()
buddy.turnLeft()

while true {
    buddy.jumpAlongTheRightSide()    
}

// assertions after 4 steps
// assert(buddy.position.column == 3, "buddy is on column 3")
// assert(buddy.position.row == 0, "buddy is on row 0")
// assert(buddy.orientation == .east, "buddy is facing east")
// assert(!buddy.isReallyBlocked(looking: .forward), "buddy is not front blocked")
// assert(buddy.isReallyBlocked(looking: .right), "buddy is blocked on the right")

// buddy.jumpAlongTheRightSide()

// assert(buddy.position.column == 4, "buddy is on column 4")
// assert(buddy.position.row == 0, "buddy is on row 0")
// assert(buddy.orientation == .east, "buddy is facing east")
// let gradient = hmap.ascent(from: buddy.position, to: buddy.aim(step:1,facing: .east) )
// assert(  abs(gradient) == 1, "ascent should be 1, not \(gradient)")

// assert(buddy.isReallyBlocked(looking: .forward), "buddy is front blocked")
// assert(buddy.isReallyBlocked(looking: .right), "buddy is blocked on the right")