import Scout
import HeightMap
import GameplayKit

let grid = world.allPossibleCoordinates
let rowSize = world.coordinates(inColumns: [0]).count
let columnSize = world.coordinates(inRows: [0]).count

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
