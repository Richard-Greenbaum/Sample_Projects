package hu.ait.cryptokeychain

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.preference.PreferenceManager
import androidx.appcompat.app.AppCompatActivity
import android.view.animation.Animation
import android.view.animation.AnimationUtils
import kotlinx.android.synthetic.main.splash_screen.*

class SplashActivity : AppCompatActivity() {
    private var mDelayHandler: Handler? = null
    private val SPLASH_DELAY: Long = 3000 //3 seconds

    internal val mRunnable: Runnable = Runnable {
        if (!isFinishing) {

            var sharedPref = PreferenceManager.getDefaultSharedPreferences(this)
            if (sharedPref.getBoolean("HAS_PASSWORD", false)) {
                val intent = Intent(applicationContext, LogInActivity::class.java)
                startActivity(intent)
            } else {
                val intent = Intent(applicationContext, NewUserActivity::class.java)
                startActivity(intent)
            }

            finish()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.splash_screen)

        lockImg.setImageResource(R.drawable.lockimg)

        //Initialize the Handler
        mDelayHandler = Handler()

        //Navigate with delay
        mDelayHandler!!.postDelayed(mRunnable, SPLASH_DELAY)

        var animation = AnimationUtils.loadAnimation(this@SplashActivity, R.anim.animation)
        animation.setAnimationListener(object : Animation.AnimationListener{
            override fun onAnimationRepeat(animation: Animation?) {
            }

            override fun onAnimationEnd(animation: Animation?) {
            }

            override fun onAnimationStart(animation: Animation?) {
            }
        })

//        welcomeTv.startAnimation(animation)
        lockImg.startAnimation(animation)


    }

    public override fun onDestroy() {

        if (mDelayHandler != null) {
            mDelayHandler!!.removeCallbacks(mRunnable)
        }

        super.onDestroy()
    }

}