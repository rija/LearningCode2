import GameplayKit


let grid = world.allPossibleCoordinates
let rowSize = world.coordinates(inColumns: [0]).count
let columnSize = world.coordinates(inRows: [0]).count


enum Horizon {
    case forward, left, right
}

func makeNoiseMap(columns: Int, rows: Int) -> GKNoiseMap {
    let source = GKPerlinNoiseSource()
    source.persistence = 0.2

    let noise = GKNoise(source)
    let size = vector2(1.0, 1.0)
    let origin = vector2(0.0, 0.0)
    let sampleCount = vector2(Int32(columns), Int32(rows))

    return GKNoiseMap(noise, size: size, origin: origin, sampleCount: sampleCount, seamless: true)
}

struct HeightMap {
    let rows: Int, columns: Int
    var grid: GKNoiseMap
    
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        // grid = Array(repeating: defaultHeight, count: rows * columns)
        grid = makeNoiseMap(columns: columns, rows: rows)
    }
    
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    subscript(row: Int, column: Int) -> Float {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            let location = vector2(Int32(row), Int32(column))
            return grid.value(at: location)
        }
    }
     
    func ascent(from pos1: Coordinate, to pos2: Coordinate) -> Int {
    
        assert(indexIsValid(row: pos1.row, column: pos1.column), "Index out of range for pos1")
        assert(indexIsValid(row: pos2.row, column: pos2.column), "Index out of range for pos2")
        let location1 = vector2(Int32(pos1.row), Int32(pos1.column))
        let location2 = vector2(Int32(pos2.row), Int32(pos2.column))
        return Int(10*(grid.value(at: location2) - grid.value(at: location1)))
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
        let location = vector2(Int32(pos.row), Int32(pos.column))      
        return grid.value(at: location) < 0
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


func makeRandomValley(grid: [Coordinate], heights: GKNoiseMap) {
  for eachPosition in grid {
    let location = vector2(Int32(eachPosition.row), Int32(eachPosition.column))
    let height = heights.value(at: location)
    if height < 0 {
        world.removeAllBlocks(at: eachPosition)
        world.place(Water(), at: eachPosition)
    }
    else {
      for eachLevel in 0 ... Int32(height*10) {
        world.place(Block(), at: eachPosition)
      }
    }
  }
}

// makeValley(grid: grid,heights: hmap)
var hmap = HeightMap(rows: rowSize, columns: columnSize)
makeRandomValley(grid: grid,heights: hmap.grid)

var buddy = Scout(char: Character(name: .byte), at: Coordinate(column: 0, row: 0), facing: .north, knowing:hmap)


buddy.materialize()

while true {
    buddy.jumpAlongTheRightSide()
}
