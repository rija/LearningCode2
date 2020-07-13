//  Ingredients:
//  - 2 ridges
//  - 1 river
//  - 1 bridge

let grid = world.allPossibleCoordinates
let rowSize = world.coordinates(inColumns: [0]).count
assert(rowSize == 12,"Row size is 12")

// heights array for the valley and river
var heightmap: [Int] = []
heightmap +=  [5,4,3,2,1,0,0,1,2,3,4,4]
heightmap +=  [5,4,3,2,1,0,0,1,2,3,4,5]
heightmap +=  [6,5,4,3,2,1,0,0,1,2,3,6]
heightmap +=  [5,4,3,2,1,1,2,0,0,3,4,7]
heightmap +=  [5,4,3,2,1,1,0,0,3,4,7,7]
heightmap +=  [6,4,3,2,1,0,0,1,2,3,4,7]
heightmap +=  [7,4,3,2,1,0,0,1,2,3,4,7]
heightmap +=  [8,4,3,2,1,1,0,0,2,3,4,7]
heightmap +=  [7,4,3,2,1,1,1,0,0,3,4,7]
heightmap +=  [6,4,3,2,1,0,0,0,0,0,4,6]
heightmap +=  [6,4,3,2,1,0,0,0,0,0,3,5]
heightmap +=  [5,4,3,2,1,0,0,0,1,2,3,4]

func makeValley() {
    
    for eachCoordinate in grid {
        if heightmap[eachCoordinate.row*rowSize+eachCoordinate.column] == 0 {
            world.removeAllBlocks(at: eachCoordinate)
            world.place(Water(), at: eachCoordinate)
        }
        else {
            for eachLevel in 0 ... heightmap[eachCoordinate.row*rowSize+eachCoordinate.column] {
                world.place(Block(), at: eachCoordinate)
            } 
        }
    }
    
}

makeValley()
