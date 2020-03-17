package hu.ait.robinfood

import android.content.Intent
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.view.View
import android.widget.Toast
import com.google.android.gms.tasks.Tasks
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.UserProfileChangeRequest
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.android.synthetic.main.activity_login.*


class LoginActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)
    }

    fun registerClick(v: View) {
        if (!isFormValid()) {
            return
        }

        FirebaseAuth.getInstance().createUserWithEmailAndPassword(
            etEmail.text.toString(), etPassword.text.toString()
        ).addOnSuccessListener {
            val user = it.user
            user.updateProfile(
                UserProfileChangeRequest.Builder()
                    .setDisplayName(userNameFromEmail(user.email!!))
                    .build()
            )
            Toast.makeText(this@LoginActivity,
                resources.getString(R.string.register_success), Toast.LENGTH_LONG).show()

            startActivity(Intent(this@LoginActivity, OrgTypeActivity::class.java))
        }.addOnFailureListener{
            Toast.makeText(this@LoginActivity,
                resources.getString(R.string.register_failed, it.message), Toast.LENGTH_LONG).show()
        }
    }

    inner class MyThread : Thread() {
        override fun run() {
            val db = FirebaseFirestore.getInstance()

            val privateDataRef = db.collection("orgs").document(
                FirebaseAuth.getInstance().currentUser!!.uid)

            val document = Tasks.await(privateDataRef.get())

            if (document.exists()) {
                startActivity(Intent(this@LoginActivity, OrgsActivity::class.java))
            } else {
                startActivity(Intent(this@LoginActivity, OrgTypeActivity::class.java))
            }
        }
    }

    fun loginClick(v: View){
        if (!isFormValid()){
            return
        }

        FirebaseAuth.getInstance().signInWithEmailAndPassword(
            etEmail.text.toString(), etPassword.text.toString()
        ).addOnSuccessListener {

            MyThread().start()

            Toast.makeText(this@LoginActivity,
                resources.getString(R.string.login_success), Toast.LENGTH_LONG).show()
        }.addOnFailureListener{
            Toast.makeText(this@LoginActivity,
                resources.getString(R.string.login_failed, it.message), Toast.LENGTH_LONG).show()
        }
    }

    private fun isFormValid(): Boolean {
        return when {
            etEmail.text.isEmpty() -> {
                etEmail.error = resources.getString(R.string.empty_field_error)
                false
            }
            etPassword.text.isEmpty() -> {
                etPassword.error = resources.getString(R.string.empty_field_error)
                false
            }
            else -> true
        }
    }

    private fun userNameFromEmail(email: String) = email.substringBefore("@")

}
