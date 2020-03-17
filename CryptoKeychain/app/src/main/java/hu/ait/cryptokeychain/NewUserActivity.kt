package hu.ait.cryptokeychain

import android.content.Intent
import android.os.Bundle
import android.preference.PreferenceManager
import androidx.appcompat.app.AppCompatActivity
import android.util.Log
import android.widget.Toast
import kotlinx.android.synthetic.main.new_user_activity.*
import java.security.SecureRandom
import javax.crypto.SecretKeyFactory
import javax.crypto.spec.PBEKeySpec

class NewUserActivity : AppCompatActivity() {


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.new_user_activity)

        doneBtn.setOnClickListener{
            if (passwordEt1.text.toString() == passwordEt2.text.toString()) {
                if (passwordEt1.text.toString().length > 7){
                    passwordCreated(passwordEt1.text.toString())
                } else {
                    Toast.makeText(this, "The password must be at least 8 characters long",
                        Toast.LENGTH_LONG).show()
                }
            } else {
                Toast.makeText(this, "The two passwords must match",
                    Toast.LENGTH_LONG).show()
            }


        }

        generatePasswordBtn.setOnClickListener {
            val password = generatePassword()
            passwordEt1.setText(password)
            passwordEt2.setText(password)
        }
    }

    fun generatePassword() : String {
        var lower = arrayOf("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
        val upper = arrayOf("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")
        val num = arrayOf("0","1","2","3","4","5","6","7","8","9")

        val final = lower + upper + num

        var password = ""
        for (i in 0..10) {
            Log.d("num", i.toString())

            var index = (0..final.size-1).random()
            password += final.get(index)
        }
        return password
    }

    fun passwordCreated(password : String) {
        var password_hash = hash(password)
        storeHash(password_hash)

        var key_bytes = createKey(password)
        sendKey(key_bytes)

    }

    private fun createKey(password : String) : ByteArray {
        val random = SecureRandom()
        val salt = ByteArray(256)
        random.nextBytes(salt)
        storeSalt(salt)

        val pbKeySpec = PBEKeySpec(password.toCharArray(), salt, 1324, 256) // 1
        val secretKeyFactory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA1") // 2
        val keyBytes = secretKeyFactory.generateSecret(pbKeySpec).encoded // 3
//        val keySpec = SecretKeySpec(keyBytes, "AES")

        return keyBytes

    }

    private fun sendKey(key : ByteArray) {
        var intentDetails = Intent()
        intentDetails.setClass(this@NewUserActivity,
            MainActivity::class.java)

        intentDetails.putExtra("passwordKey", key)

        startActivity(intentDetails)
    }

    private fun storeHash(passwordHash : String) {
        var sharedPref = PreferenceManager.getDefaultSharedPreferences(this)
        var editor = sharedPref.edit()
        editor.putBoolean("HAS_PASSWORD", true)
        editor.putString("PASSWORD_HASH", passwordHash)
        editor.apply()
    }

    private fun storeSalt(salt : ByteArray) {
        val charset = Charsets.UTF_8
        var sharedPref = PreferenceManager.getDefaultSharedPreferences(this)
        var editor = sharedPref.edit()
        editor.putString("SALT", salt.toString(charset))
        editor.apply()
    }



    private fun hash(password: String) : String {
        var passwordHash = password
        for (x in 0..5500) {
            Log.d("middleHash", passwordHash)
            passwordHash = passwordHash.hashCode().toString()
        }
        return passwordHash
    }





}


