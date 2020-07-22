import Scout
import HeightMap

let grid = world.allPossibleCoordinates
let rowSize = world.coordinates(inColumns: [0]).count
let columnSize = world.coordinates(inRows: [0]).count

func makeRandomValley(grid: [Coordinate], heights: HeightMap) {
    for eachPosition in grid {
        let height = heights.height(at: eachPosition)
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
makeRandomValley(grid: grid,heights: hmap)

var buddy = Scout(char: Character(name: .byte), at: Coordinate(column: 0, row: 0), facing: .north, knowing:hmap)

buddy.materialize()

while true {
    buddy.jumpAlongTheRightSide()
}
