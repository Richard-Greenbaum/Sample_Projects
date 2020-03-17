package hu.ait.robinfood

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.view.View
import android.widget.Toast
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.DocumentReference
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.storage.FirebaseStorage
import hu.ait.robinfood.GlideApp
import hu.ait.robinfood.data.Organization
import kotlinx.android.synthetic.main.activity_edit_profile.*
import kotlinx.android.synthetic.main.activity_edit_profile.addressEt
import kotlinx.android.synthetic.main.activity_edit_profile.btnUploadPhoto
import kotlinx.android.synthetic.main.activity_edit_profile.contactNameEt
import kotlinx.android.synthetic.main.activity_edit_profile.finishedBtn
import kotlinx.android.synthetic.main.activity_edit_profile.headerTv
import kotlinx.android.synthetic.main.activity_edit_profile.longDescriptionEt
import kotlinx.android.synthetic.main.activity_edit_profile.orgNameEt
import kotlinx.android.synthetic.main.activity_edit_profile.orgPhoto
import kotlinx.android.synthetic.main.activity_edit_profile.shortDescriptionEt
import kotlinx.android.synthetic.main.activity_edit_profile.shortDescriptionTv
import kotlinx.android.synthetic.main.activity_edit_profile.visibleCb
import kotlinx.android.synthetic.main.activity_edit_profile.websiteEt

class EditProfileActivity : AppCompatActivity() {

    companion object {
        const val REQUEST_CODE_EDIT = 123
    }

    private var imageField = ""
    private var updateImage = false
    private var userOrg = Organization()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_edit_profile)

        val organization = getOrganization()

        displayCurrentDetails(organization)
    }

    private fun getOrganization() : DocumentReference {
        lateinit var uID : String

        if (intent?.extras!!.containsKey("uID")) {
            uID = intent.getStringExtra("uID")
        } else {
            uID = FirebaseAuth.getInstance().currentUser!!.uid
        }

        return FirebaseFirestore.getInstance().collection("orgs").document(uID)
    }

    private fun displayCurrentDetails(organization : DocumentReference) {

        organization.get().addOnSuccessListener {document ->
                if (document.exists()) {
                    userOrg = document.toObject(Organization::class.java)!!
                    setTextViewFields()
                    loadCurrentProfileImage()
                }
        }

        btnUploadPhoto.setOnClickListener {
            initUploadNewImage()
        }

        btnDeletePhoto.setOnClickListener {
            deleteImage()
        }

        finishedBtn.setOnClickListener {
            checkValidDetails(organization)
        }
    }

    private fun setTextViewFields() {
        headerTv.text = resources.getString(R.string.edit_details_activity_header)
        orgNameEt.setText(userOrg.orgName)
        contactNameEt.setText(userOrg.contactName)
        addressEt.setText(userOrg.address)
        websiteEt.setText(userOrg.website)
        shortDescriptionEt.setText(userOrg.shortDescription)
        longDescriptionEt.setText(userOrg.longDescription)
        addressEt.hint = resources.getString(R.string.details_activity_address, userOrg.type)
        orgNameEt.hint = resources.getString(R.string.details_activity_name, userOrg.type)
        visibleCb.isChecked = userOrg.visible

        if (userOrg.type == "restaurant") {
            shortDescriptionTv.text = resources.getString(
                R.string.details_activity_sd_text,
                "your restaurant is able to donate"
            )
        }
        if (userOrg.type == "food pantry") {
            shortDescriptionTv.text = resources.getString(
                R.string.details_activity_sd_text,
                "your food pantry is willing to accept"
            )
        }
    }

    private fun loadCurrentProfileImage() {
        if (userOrg.image != "") {
            val imgView = orgPhoto
            val imgRef = FirebaseStorage.getInstance().reference.child(userOrg.image)
            GlideApp.with(applicationContext)
                .load(imgRef).into(imgView)
            btnDeletePhoto.visibility = View.VISIBLE
        }
    }

    private fun initUploadNewImage() {
        val uploadPhotoIntent = Intent(Intent.ACTION_PICK)
        uploadPhotoIntent.type = "image/*"
        val mimeTypes = arrayListOf<String>("image/jpeg", "image/png")
        uploadPhotoIntent.putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes)
        startActivityForResult(uploadPhotoIntent,
            REQUEST_CODE_EDIT
        )
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (resultCode == Activity.RESULT_OK) {
            when (requestCode) {
                REQUEST_CODE_EDIT -> {
                    val imageData = data?.data!!
                    imageField = imageData.lastPathSegment!!
                    orgPhoto.setImageURI(imageData)

                    val storageRef = FirebaseStorage.getInstance().reference
                    val imageRef = storageRef.child(imageField)
                    val uploadTask = imageRef.putFile(imageData)

                    uploadTask.addOnSuccessListener {
                        updateImage = true
                    }.addOnFailureListener {
                        Toast.makeText(this@EditProfileActivity,
                            resources.getString(R.string.upload_failed), Toast.LENGTH_LONG).show()
                    }
                }
            }
        }
    }

    private fun deleteImage() {
        val storageRef = FirebaseStorage.getInstance().reference
        val deleteRef = storageRef.child(userOrg.image)
        val deleteTask = deleteRef.delete()

        deleteTask
            .addOnSuccessListener {
                updateImage = true
                orgPhoto.setImageDrawable(null)
                btnDeletePhoto.visibility = View.GONE
            }.addOnFailureListener {
                Toast.makeText(this@EditProfileActivity,
                    resources.getString(R.string.delete_failed), Toast.LENGTH_LONG).show()
            }

        imageField = ""
    }

    private fun checkValidDetails(organization: DocumentReference) {
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
            updateOrgDetails(organization, updateImage)
            var intentFinishUpdating = Intent(this@EditProfileActivity, OrgsActivity::class.java)
            startActivity(intentFinishUpdating)
        }
    }

    private fun updateOrgDetails(organization : DocumentReference, updateImage : Boolean) {
        if (updateImage) {
            organization.update("image", imageField)
        }

        organization.update(
            "orgName", orgNameEt.text.toString(),
            "contactName", contactNameEt.text.toString(),
            "address", addressEt.text.toString(),
            "website", websiteEt.text.toString(),
            "shortDescription", shortDescriptionEt.text.toString(),
            "longDescription", longDescriptionEt.text.toString(),
            "visible", visibleCb.isChecked
            ).addOnSuccessListener {
            Toast.makeText(
                this@EditProfileActivity,
                resources.getString(R.string.profile_update_success), Toast.LENGTH_LONG
            ).show()

            finish()
        }.addOnFailureListener {
            Toast.makeText(
                this@EditProfileActivity,
                "Error: ${it.message}", Toast.LENGTH_LONG
            ).show()
        }
    }

}