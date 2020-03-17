package hu.ait.robinfood.dialogs

import android.app.AlertDialog
import android.app.Dialog
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.support.v4.app.DialogFragment
import android.view.View
import hu.ait.robinfood.adapter.OrgsAdapter
import hu.ait.robinfood.data.Organization
import kotlinx.android.synthetic.main.dialog_profile_details.view.*
import android.content.ActivityNotFoundException
import android.widget.ImageView
import android.widget.Toast
import com.google.firebase.storage.FirebaseStorage
import hu.ait.robinfood.GlideApp
import hu.ait.robinfood.R
import hu.ait.robinfood.OrgsActivity


class ProfileDetailsDialog : DialogFragment() {

    private lateinit var organization: Organization
    private lateinit var btnWebsite: ImageView
    private lateinit var profileImage: ImageView

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val builder = AlertDialog.Builder(requireContext())

        builder.setTitle(resources.getString(R.string.dialog_profile_details_title))

        val rootView = requireActivity().layoutInflater.inflate(
            R.layout.dialog_profile_details, null
        )

        builder.setView(rootView)

        getOrganization()
        setRootViewFields(rootView)

        builder.setNeutralButton(resources.getString(R.string.dialog_close)) { dialog, which -> dialog.dismiss() }

        return builder.create()
    }

    private fun getOrganization() {
        val arguments = this.arguments

        if (arguments != null && arguments.containsKey(
                OrgsAdapter.KEY_ORG_DETAILS)) {
            organization = arguments.getSerializable(OrgsAdapter.KEY_ORG_DETAILS) as Organization
        }
    }

    private fun setRootViewFields(rootView: View) {
        rootView.profileName.text = organization.orgName
        rootView.profileAddress.text = organization.address
        rootView.profileContact.text = organization.contactName
        rootView.profileShortDescription.text = organization.shortDescription
        rootView.profileLongDescription.text = organization.longDescription
        rootView.profileEmail.text = organization.emailAddress
        rootView.profileWebsite.text = organization.website
        profileImage = rootView.profileImage
        btnWebsite = rootView.btnWebsite

        if (organization.image != "") {
            var imgRef = FirebaseStorage.getInstance().reference.child(organization.image)
            GlideApp.with(this.context!!)
                .load(imgRef).into(profileImage)
        } else {
            profileImage.visibility = View.GONE
        }

        rootView.btnEmail.setOnClickListener {
            emailButtonOnClickIntent()
        }

        initWebsiteButtonIntent()
    }

    private fun emailButtonOnClickIntent() {
        val emailIntent = Intent(Intent.ACTION_SENDTO)
        val email = organization.emailAddress
        emailIntent.data = Uri.parse(resources.getString(R.string.email_uri, email))
        try {
            startActivity(emailIntent)
        } catch (e: ActivityNotFoundException) {
            Toast.makeText(
                context as OrgsActivity, resources.getString(R.string.email_failed_msg), Toast.LENGTH_LONG
            ).show()
        }
    }

    private fun initWebsiteButtonIntent() {
        if (organization.website != "") {
            btnWebsite.setOnClickListener {
                val websiteIntent = Intent(Intent.ACTION_VIEW)
                var website = organization.website
                if (!website.startsWith("https://") && !website.startsWith("http://")) {
                    website = "http://$website"
                }
                websiteIntent.data = Uri.parse(website)
                startActivity(websiteIntent)
            }
        } else {
            btnWebsite.visibility = View.GONE
        }
    }

}