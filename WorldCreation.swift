//  Ingredients:
//  - 2 ridges
//  - 1 river
//  - 1 bridge

let grid = world.allPossibleCoordinates
let rowSize = world.coordinates(inColumns: [0]).count
let columnSize = world.coordinates(inRows: [0]).count



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
    
    func isNorthEdge(at pos: Coordinate) -> Bool {
        assert(indexIsValid(row: pos.row, column: pos.column), "Index out of range for pos")
        
        return pos.row == (rows - 1 )
    } 
    
    func isSouthEdge(at pos: Coordinate) -> Bool {
        assert(indexIsValid(row: pos.row, column: pos.column), "Index out of range for pos")
        
        return pos.row == 0
    } 
    
    func isWestEdge(at pos: Coordinate) -> Bool {
        assert(indexIsValid(row: pos.row, column: pos.column), "Index out of range for pos")
        
        return pos.column == 0
    }
    
    func isEastEdge(at pos: Coordinate) -> Bool {
        assert(indexIsValid(row: pos.row, column: pos.column), "Index out of range for pos")
        
        return pos.column == (columns - 1)
    }        
    
    func isFloor(at pos: Coordinate) -> Bool {
        return grid[pos.row*rows+pos.column] == grid.min()
    }
}

struct Scout {
    var ask: Character
    var position: Coordinate
    var orientation: Direction
    
    init(char: Character, at origin: Coordinate, facing: Direction) {
        self.ask = char
        self.position = origin
        self.orientation = facing
    }
    
    func materialize() {
        world.place(self.ask, facing: self.orientation, at: self.position)
    }
    
    mutating func leap() {
        self.position = Coordinate(column:self.position.column, row: self.position.row+1)
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
}



func makeValley(grid: [Coordinate], heights: HeightMap) {
    
    for pos in grid {
        if heights.isFloor(at: pos) {
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

var buddy = Scout(char: Character(name: .byte), at: Coordinate(column: 0, row: 0), facing: .north)


// unit tests
buddy.materialize()
assert(buddy.position.row == 0 && buddy.position.column == 0, "buddy at 0,0")
assert(buddy.orientation == .north, "buddy facing north")

buddy.leap()
assert(buddy.position.row == 1 && buddy.position.column == 0, "buddy jump forward northbound")

buddy.turnRight()
assert(buddy.orientation == .east, "buddy turn right eastward")
