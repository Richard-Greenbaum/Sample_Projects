package hu.ait.robinfood.adapter

import android.content.Context
import android.os.Bundle
import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.storage.FirebaseStorage
import hu.ait.robinfood.GlideApp
import hu.ait.robinfood.OrgsActivity
import hu.ait.robinfood.dialogs.ProfileDetailsDialog
import hu.ait.robinfood.R
import hu.ait.robinfood.data.Organization
import kotlinx.android.synthetic.main.row_org.view.*

class OrgsAdapter(private val context: Context) : RecyclerView.Adapter<OrgsAdapter.ViewHolder>() {

    private var orgsList = mutableListOf<Organization>()
    private var orgKeys = mutableListOf<String>()

    companion object {
        const val KEY_ORG_DETAILS = "KEY_ORG_DETAILS"
    }

    private var lastPosition = -1

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(
            R.layout.row_org, parent, false)

        return ViewHolder(view)
    }

    override fun getItemCount() = orgsList.size

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val (uid, orgName, contactName, type, address, emailAddress, shortDescription,
            longDescription, visible, website, image) = orgsList[holder.adapterPosition]

        setProfileImage(image, holder, type)

        setTextViews(holder, orgName, address, type, shortDescription)

        holder.entireView.setOnClickListener {
            initProfileDetailsDialog(holder, context as OrgsActivity)
        }
    }

    private fun setTextViews(holder: ViewHolder, orgName: String, address: String,
        type: String, shortDescription: String) {

        holder.orgNameTv.text = orgName
        holder.orgAddressTv.text = address

        if (type == context.resources.getString(R.string.restaurant)) {
            holder.shortDescriptionTv2.text =
                context.resources.getString(R.string.row_description_tv, "Available", shortDescription)
        } else {
            holder.shortDescriptionTv2.text =
                context.resources.getString(R.string.row_description_tv, "Accepted", shortDescription)
        }
    }

    private fun setProfileImage(image: String, holder: ViewHolder, type: String) {
        if (image != "") {
            var imgRef = FirebaseStorage.getInstance().reference.child(image)
            GlideApp.with(context as OrgsActivity)
                .load(imgRef).into(holder.imageVw)
        } else if (type == context.resources.getString(R.string.restaurant)) {
            holder.imageVw.setImageResource(R.drawable.ic_r)
        } else {
            holder.imageVw.setImageResource(R.drawable.ic_fp)
        }
    }

    private fun initProfileDetailsDialog(holder : ViewHolder, context : OrgsActivity) {
        val displayProfileDetailsDialog = ProfileDetailsDialog()

        val bundle = Bundle()
        bundle.putSerializable(KEY_ORG_DETAILS, orgsList[holder.adapterPosition])
        displayProfileDetailsDialog.arguments = bundle

        displayProfileDetailsDialog.show(
            context.supportFragmentManager,
            context.resources.getString(R.string.tag_dialog)
        )
    }

    fun addOrg(org: Organization, key: String) {
        orgsList.add(org)
        orgKeys.add(key)
        notifyDataSetChanged()
    }

    private fun removeOrg(index: Int) {
        FirebaseFirestore.getInstance().collection("orgs").document(
            orgKeys[index]
        ).delete()

        orgsList.removeAt(index)
        orgKeys.removeAt(index)
        notifyItemRemoved(index)
    }

    fun removeOrgByKey(key: String) {
        val index = orgKeys.indexOf(key)
        if (index != -1) {
            orgsList.removeAt(index)
            orgKeys.removeAt(index)
            notifyItemRemoved(index)
        }
    }

    class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val entireView = itemView
        val imageVw: ImageView = itemView.imageVw
        val orgNameTv: TextView = itemView.orgNameTv
        val orgAddressTv: TextView = itemView.orgAddressTv
        val shortDescriptionTv2: TextView = itemView.shortDescriptionTv2
    }
}