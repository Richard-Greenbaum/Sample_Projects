package hu.ait.robinfood

import android.content.Intent
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import kotlinx.android.synthetic.main.activity_org_type.*

class OrgTypeActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_org_type)

        restaurantBtn.setOnClickListener {
            var intentDetails = Intent()
            intentDetails.setClass(this@OrgTypeActivity, DetailsActivity::class.java)
            intentDetails.putExtra("TYPE", "restaurant")
            startActivity(intentDetails)
        }

        foodPantryBtn.setOnClickListener {
            var intentDetails = Intent()
            intentDetails.setClass(this@OrgTypeActivity, DetailsActivity::class.java)
            intentDetails.putExtra("TYPE", "food pantry")
            startActivity(intentDetails)
        }
    }
}