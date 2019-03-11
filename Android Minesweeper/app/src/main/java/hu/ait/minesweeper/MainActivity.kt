package hu.ait.minesweeper

import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import hu.ait.minesweeper.model.MineSweeperModel
import kotlinx.android.synthetic.main.activity_main.*

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        MineSweeperModel.initBoard()

        restartBtn.setOnClickListener() {
            MineSweeperView.resetGame()
        }
    }

    fun setResultText(input : String) {
        resultView.text = input
    }

    fun setMinesRemainingText(input : String) {
        minesRemaining.text = input
    }

    fun getToggleState() : Boolean {
        return toggleButton.isChecked
    }

    fun resetToggleState() {
        toggleButton.isChecked = false
    }
}
