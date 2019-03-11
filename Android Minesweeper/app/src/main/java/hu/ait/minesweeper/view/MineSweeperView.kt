package hu.ait.minesweeper.view

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.util.AttributeSet
import android.view.MotionEvent
import android.view.View
import hu.ait.minesweeper.MainActivity
import hu.ait.minesweeper.model.MineSweeperModel



class MineSweeperView(context: Context?, attrs: AttributeSet?) : View(context, attrs) {

    private val paintBackground = Paint()
    private val paintLine = Paint()
    private val paintText = Paint()

    private var end_game = false



    init {
        paintBackground.color = Color.GRAY
        paintBackground.style = Paint.Style.FILL

        paintLine.color = Color.WHITE
        paintLine.style = Paint.Style.STROKE
        paintLine.strokeWidth = 8f

        paintText.style = Paint.Style.STROKE
        paintText.strokeWidth = 2f
        paintText.textSize = 40f

    }


    override fun onDraw(canvas: Canvas?) {
        canvas?.drawRect(0f, 0f, width.toFloat(), height.toFloat(), paintBackground)

        drawGameBoard(canvas)

        drawNumbersFlagsMines(canvas, end_game)

    }

    private fun drawGameBoard(canvas: Canvas?) {
        // border
        canvas?.drawRect(0f, 0f, width.toFloat(), height.toFloat(), paintLine)

        drawHorizontalLines(canvas)

        drawVerticalLines(canvas)

    }

    private fun drawVerticalLines(canvas: Canvas?) {
        canvas?.drawLine(
            (width / 5).toFloat(), 0f, (width / 5).toFloat(), height.toFloat(),
            paintLine
        )
        canvas?.drawLine(
            (2 * width / 5).toFloat(), 0f, (2 * width / 5).toFloat(), height.toFloat(),
            paintLine
        )
        canvas?.drawLine(
            (3 * width / 5).toFloat(), 0f, (3 * width / 5).toFloat(), height.toFloat(),
            paintLine
        )
        canvas?.drawLine(
            (4 * width / 5).toFloat(), 0f, (4 * width / 5).toFloat(), height.toFloat(),
            paintLine
        )
        canvas?.drawLine(
            (5 * width / 5).toFloat(), 0f, (5 * width / 5).toFloat(), height.toFloat(),
            paintLine
        )
    }

    private fun drawHorizontalLines(canvas: Canvas?) {
        canvas?.drawLine(
            0f, (height / 5).toFloat(), width.toFloat(), (height / 5).toFloat(),
            paintLine
        )
        canvas?.drawLine(
            0f, (2 * height / 5).toFloat(), width.toFloat(),
            (2 * height / 5).toFloat(), paintLine
        )
        canvas?.drawLine(
            0f, (3 * height / 5).toFloat(), width.toFloat(),
            (3 * height / 5).toFloat(), paintLine
        )
        canvas?.drawLine(
            0f, (4 * height / 5).toFloat(), width.toFloat(),
            (4 * height / 5).toFloat(), paintLine
        )
        canvas?.drawLine(
            0f, (5 * height / 5).toFloat(), width.toFloat(),
            (5 * height / 5).toFloat(), paintLine
        )
    }


    private fun drawNumbersFlagsMines(canvas: Canvas?, end_game : Boolean) {
        for (i in 0..4) {
            for (j in 0..4) {
                if (MineSweeperModel.isExplored(i, j)) {
                    drawNumbers(i, j, canvas)
                } else if (MineSweeperModel.isFlagged(i, j) && !end_game) {
                    drawFlags(i, j, canvas)
                }
                if (end_game && MineSweeperModel.isMine(i, j)) {
                    drawMines(i, j, canvas)
                }
            }

        }
    }

    private fun drawMines(i: Int, j: Int, canvas: Canvas?) {
        val centerX = (i * width / 5 + width / 15).toFloat()
        val centerY = ((j + .75) * height / 5).toFloat()
        paintText.color = Color.BLACK
        var text = ""
        when (MineSweeperModel.isFlagged(i, j)) {
            true -> text = "F"
            false -> text = "X"
        }

        canvas?.drawText(text, centerX, centerY, paintText)
    }

    private fun drawFlags(i: Int, j: Int, canvas: Canvas?) {
        val centerX = (i * width / 5 + width / 15).toFloat()
        val centerY = ((j + .75) * height / 5).toFloat()
        paintText.color = Color.BLACK
        canvas?.drawText("F", centerX, centerY, paintText)
    }

    private fun drawNumbers(i: Int, j: Int, canvas: Canvas?) {
        val centerX = (i * width / 5 + width / 15).toFloat()
        val centerY = ((j + .75) * height / 5).toFloat()
        var mines_adjacent = MineSweeperModel.getMinesAdjacent(i, j)
        var text = mines_adjacent.toString()

        setColor(mines_adjacent)

        canvas?.drawText(text, centerX, centerY, paintText)
    }

    private fun setColor(mines_adjacent: Int) {
        when (mines_adjacent) {
            0 -> paintText.color = Color.WHITE
            1 -> paintText.color = Color.BLUE
            2 -> paintText.color = Color.GREEN
            else -> paintText.color = Color.RED
        }
    }


    override fun onTouchEvent(event: MotionEvent?): Boolean {
        if (event?.action == MotionEvent.ACTION_DOWN && !end_game) {
            val tX = event.x.toInt() / (width / 5)
            val tY = event.y.toInt() / (height / 5)

            if (tX < 5 && tY < 5 && !MineSweeperModel.isExplored(tX, tY)
                && !MineSweeperModel.isFlagged(tX, tY))  {
                if ((context as MainActivity).getToggleState()) {
                    touchFlag(tX, tY)
                } else {
                    touchExplore(tX, tY)
                }
                if (MineSweeperModel.isBoardFull()) {
                    (context as MainActivity).setResultText(context.getString(hu.ait.minesweeper.R.string.winTest))
                }
                invalidate()
            }
        }
        return true
    }

    private fun touchExplore(tX: Int, tY: Int) {
        if (MineSweeperModel.isMine(tX, tY)) {
            (context as MainActivity).setResultText(context.getString(hu.ait.minesweeper.R.string.steppedOnMineText))
            end_game = true
        } else {
            MineSweeperModel.exploreBlock(tX, tY)
        }
    }

    private fun touchFlag(tX : Int, tY : Int) {
        if (MineSweeperModel.isMine(tX, tY)) {
            MineSweeperModel.flagBlock(tX, tY)
            var new_mines_remaining = MineSweeperModel.getMinesRemaining() - 1
            (context as MainActivity).setMinesRemainingText(
                context.getString(hu.ait.minesweeper.R.string.minesRemainingText) + " $new_mines_remaining")
            MineSweeperModel.setMinesRemaining(new_mines_remaining)
            if (new_mines_remaining == 0) {
                (context as MainActivity).setResultText(context.getString(hu.ait.minesweeper.R.string.winText))
                end_game = true
            }
        } else {
            (context as MainActivity).setResultText(
                context.getString(hu.ait.minesweeper.R.string.flaggedIncorrectBlockText))
            end_game = true
        }
    }

    fun resetGame() {
        end_game = false
        MineSweeperModel.initBoard()
        MineSweeperModel.setMinesRemaining(4)
        (context as MainActivity).resetToggleState()
        (context as MainActivity).setResultText("")
        (context as MainActivity).setMinesRemainingText(
            context.getString(hu.ait.minesweeper.R.string.minesRemainingText) + " 4")
        invalidate()
    }

}