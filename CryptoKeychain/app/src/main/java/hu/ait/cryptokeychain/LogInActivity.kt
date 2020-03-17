package hu.ait.cryptokeychain

import android.content.Intent
import android.os.Bundle
import android.preference.PreferenceManager
import androidx.appcompat.app.AppCompatActivity
import android.util.Log
import android.widget.Toast
import kotlinx.android.synthetic.main.log_in_activity.*
import java.security.SecureRandom
import javax.crypto.SecretKeyFactory
import javax.crypto.spec.PBEKeySpec

class LogInActivity : AppCompatActivity() {

    private var storedPasswordHash = ""


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.log_in_activity)

        var sharedPref = PreferenceManager.getDefaultSharedPreferences(this)
        storedPasswordHash = sharedPref.getString("PASSWORD_HASH", "")

        logInBtn.setOnClickListener {
            var password = passwordEt.text.toString()
            var input_password_hash = hash(password)
            checkPassword(input_password_hash)

        }
    }

    private fun hash(password: String) : String {
        var passwordHash = password
        for (x in 0..5500) {
            Log.d("middleHash", passwordHash)
            passwordHash = passwordHash.hashCode().toString()
        }
        return passwordHash
    }

    private fun createKey(password : String) : ByteArray {
        var sharedPref = PreferenceManager.getDefaultSharedPreferences(this)
        val salt = sharedPref.getString("SALT", "").toByteArray(Charsets.UTF_8)

        val pbKeySpec = PBEKeySpec(password.toCharArray(), salt, 1324, 256) // 1
        val secretKeyFactory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA1") // 2
        val keyBytes = secretKeyFactory.generateSecret(pbKeySpec).encoded // 3
//        val keySpec = SecretKeySpec(keyBytes, "AES")

        return keyBytes

    }

    private fun sendKey(key : ByteArray) {
        var intentDetails = Intent()
        intentDetails.setClass(this@LogInActivity,
            MainActivity::class.java)

        intentDetails.putExtra("passwordKey", key)

        startActivity(intentDetails)
    }

    private fun checkPassword(inputPasswordHash : String) {
        if (inputPasswordHash == storedPasswordHash) {
            var key_bytes = createKey(passwordEt.text.toString())
            sendKey(key_bytes)
        } else {
            runOnUiThread {
                Toast.makeText(
                    this, "You have entered an incorrect password",
                    Toast.LENGTH_LONG
                ).show()
            }
        }
    }

}
