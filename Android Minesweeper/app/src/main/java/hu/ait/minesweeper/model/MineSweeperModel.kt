package hu.ait.minesweeper.model


object MineSweeperModel {


    class Block {
        var is_mine: Boolean = false
        var is_flagged: Boolean = false
        var is_explored: Boolean = false
        var mines_adjacent : Int = 0
    }

    private var model = arrayOf(
        arrayOf(Block(), Block(), Block(), Block(), Block()),
        arrayOf(Block(), Block(), Block(), Block(), Block()),
        arrayOf(Block(), Block(), Block(), Block(), Block()),
        arrayOf(Block(), Block(), Block(), Block(), Block()),
        arrayOf(Block(), Block(), Block(), Block(), Block())
    )

    private var mines_remaining = 4

    fun initBoard() {
        clearModel()
        initMines()
        initMinesAdjacentValues()
    }

    private fun initMinesAdjacentValues() {
        for (i in 0..4) {
            for (j in 0..4) {
                model[i][j].mines_adjacent = numMinesAdjacent(i, j)
            }
        }
    }

    private fun initMines() {
        var my_list = (0..24).shuffled()
        for (i in 0..3) {
            var num = my_list[i]
            model[num % 5][num / 5].is_mine = true
        }
    }

    private fun clearModel() {
        for (i in 0..4) {
            for (j in 0..4) {
                model[i][j] = Block()
            }
        }
    }

    private fun numMinesAdjacent(x : Int, y : Int) : Int {
        var total = 0
        for (i in -1..1) {
            for (j in -1..1) {
                var x_new = x + i
                var y_new = y + j
                if (x_new > -1 && x_new < 5 && y_new > -1 && y_new < 5) {
                    if (model[x_new][y_new].is_mine) {
                        total += 1
                    }
                }
            }
        }
        return total
    }

    fun exploreBlock(x : Int, y : Int) {
        if (!model[x][y].is_flagged && !model[x][y].is_explored) {
            model[x][y].is_explored = true

            if (numMinesAdjacent(x, y) == 0) {
                for (i in -1..1) {
                    for (j in -1..1) {
                        var x_new = x + i
                        var y_new = y + j
                        if (x_new > -1 && x_new < 5 && y_new > -1 && y_new < 5) {
                            exploreBlock(x_new, y_new)
                        }
                    }
                }
            }
        }
    }

    fun flagBlock(x : Int, y : Int) {
        if (!model[x][y].is_explored) {
            model[x][y].is_flagged = true
        }
    }

    fun isBoardFull() : Boolean {
        for (i in 0..4) {
            for (j in 0..4) {
                if (!model[i][j].is_explored && !model[i][j].is_flagged) {
                    return false
                }
            }
        }
        return true
    }


    fun isExplored(x : Int, y : Int) : Boolean {
        return model[x][y].is_explored
    }

    fun isFlagged(x : Int, y : Int) : Boolean {
        return model[x][y].is_flagged
    }

    fun isMine(x : Int, y : Int) : Boolean {
        return model[x][y].is_mine
    }

    fun getMinesAdjacent(x : Int, y : Int) : Int {
        return model[x][y].mines_adjacent
    }

    fun getMinesRemaining() : Int {
        return mines_remaining
    }

    fun setMinesRemaining(n : Int) {
        mines_remaining = n
    }



}