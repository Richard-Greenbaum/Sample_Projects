package hu.ait.robinfood

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.widget.Toast
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import hu.ait.robinfood.data.Organization
import kotlinx.android.synthetic.main.activity_details.*
import android.util.Log
import com.google.firebase.storage.FirebaseStorage


class DetailsActivity : AppCompatActivity() {

    private lateinit var type : String
    private var imageField = ""

    companion object {
        const val REQUEST_CODE = 987
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_details)

        initTextViewFields()

        btnUploadPhoto.setOnClickListener {
            initUploadImage()
        }

        finishedBtn.setOnClickListener {
            checkValidDetails()
        }
    }

    private fun initTextViewFields() {
        if (intent?.extras!!.containsKey("TYPE")) {
            type = intent.getStringExtra("TYPE")

            headerTv.text = resources.getString(R.string.details_activity_header, type)
            orgNameEt.hint = resources.getString(R.string.details_activity_name, type)
            addressEt.hint = resources.getString(R.string.details_activity_address, type)

            if (type == "restaurant") {
                shortDescriptionTv.text = resources.getString(
                    R.string.details_activity_sd_text,
                    "your restaurant is able to donate"
                )
            }
            if (type == "food pantry") {
                shortDescriptionTv.text = resources.getString(
                    R.string.details_activity_sd_text,
                    "your food pantry is willing to accept"
                )
            }
        }
    }

    private fun initUploadImage() {
        val uploadPhotoIntent = Intent(Intent.ACTION_PICK)
        uploadPhotoIntent.type = "image/*"
        val mimeTypes = arrayListOf<String>("image/jpeg", "image/png")
        uploadPhotoIntent.putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes)
        startActivityForResult(uploadPhotoIntent, REQUEST_CODE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (resultCode == Activity.RESULT_OK) {
            when (requestCode) {
                REQUEST_CODE -> {
                    var imageData = data?.data!!
                    imageField = imageData.lastPathSegment!!
                    orgPhoto.setImageURI(imageData)

                    val storageRef = FirebaseStorage.getInstance().reference
                    val imageRef = storageRef.child(imageField)
                    val uploadTask = imageRef.putFile(imageData)

                    uploadTask.addOnSuccessListener {
                        Log.d("IMAGE_UPLOAD", "success")
                    }.addOnFailureListener {
                        Log.d("IMAGE_UPLOAD", "fail")
                    }
                }
            }
        }
    }

    private fun checkValidDetails() {
        var ok = true
        if (orgNameEt.text.isEmpty()) {
            orgNameEt.error = resources.getString(R.string.empty_field_error)
            ok = false
        }
        if (contactNameEt.text.isEmpty()) {
            contactNameEt.error = resources.getString(R.string.empty_field_error)
            ok = false
        }
        if (addressEt.text.isEmpty()) {
            addressEt.error = resources.getString(R.string.empty_field_error)
            ok = false
        }
        if (shortDescriptionEt.text.isEmpty()) {
            shortDescriptionEt.error = resources.getString(R.string.empty_field_error)
            ok = false
        }

        if (ok) {
            val org = createOrg()
            addOrgToDatabase(org)
            var intentDetails = Intent()
            intentDetails.setClass(this@DetailsActivity, OrgsActivity::class.java)
            startActivity(intentDetails)
        }
    }

    private fun createOrg() : Organization {
        val org = Organization(
            FirebaseAuth.getInstance().currentUser!!.uid,
            orgNameEt.text.toString(),
            contactNameEt.text.toString(),
            type,
            addressEt.text.toString(),
            FirebaseAuth.getInstance().currentUser!!.email!!,
            shortDescriptionEt.text.toString(),
            longDescriptionEt.text.toString(),
            visibleCb.isChecked,
            websiteEt.text.toString(),
            imageField
        )
        return org
    }

    private fun addOrgToDatabase(org : Organization) {
        var orgsCollection = FirebaseFirestore.getInstance().collection("orgs")

        orgsCollection.document(FirebaseAuth.getInstance().currentUser!!.uid).set(org)
            .addOnSuccessListener {
                Toast.makeText(
                    this@DetailsActivity,
                    resources.getString(R.string.profile_creation_success), Toast.LENGTH_LONG
                ).show()

                finish()
            }.addOnFailureListener {
                Toast.makeText(
                    this@DetailsActivity,
                    resources.getString(R.string.profile_creation_fail, it.message), Toast.LENGTH_LONG
             ).show()
            }
    }

}