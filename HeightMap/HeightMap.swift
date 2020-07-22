import GameplayKit

func makeNoiseMap(columns: Int, rows: Int) -> GKNoiseMap {
    let source = GKPerlinNoiseSource()
    source.persistence = 0.2
    
    let noise = GKNoise(source)
    let size = vector2(1.0, 1.0)
    let origin = vector2(0.0, 0.0)
    let sampleCount = vector2(Int32(columns), Int32(rows))
    
    return GKNoiseMap(noise, size: size, origin: origin, sampleCount: sampleCount, seamless: true)
}

public struct HeightMap {
    let rows: Int, columns: Int
    public var grid: GKNoiseMap
    
    public init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        // grid = Array(repeating: defaultHeight, count: rows * columns)
        grid = makeNoiseMap(columns: columns, rows: rows)
    }
    
    
    public func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    subscript(row: Int, column: Int) -> Float {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            let location = vector2(Int32(row), Int32(column))
            return grid.value(at: location)
        }
    }
    
    public func ascent(from pos1: Coordinate, to pos2: Coordinate) -> Int {
        
        assert(indexIsValid(row: pos1.row, column: pos1.column), "Index out of range for pos1")
        assert(indexIsValid(row: pos2.row, column: pos2.column), "Index out of range for pos2")
        let location1 = vector2(Int32(pos1.row), Int32(pos1.column))
        let location2 = vector2(Int32(pos2.row), Int32(pos2.column))
        return Int(10*(grid.value(at: location2) - grid.value(at: location1)))
    }
    
    public func isOnWorldEdge(of side: Direction, at pos: Coordinate) -> Bool {
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
    
    public func isAtSeaLevel(at pos: Coordinate) -> Bool {
        let location = vector2(Int32(pos.row), Int32(pos.column))      
        return grid.value(at: location) < 0
    }
    
    public func height(at pos: Coordinate) -> Float {
      let location = vector2(Int32(pos.row), Int32(pos.column))      
      return grid.value(at: location)
    }
    
}

