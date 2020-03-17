package hu.ait.robinfood.data

import java.io.Serializable

data class Organization(
                var uid: String = "",
                var orgName: String = "",
                var contactName: String = "",
                var type: String = "",    //either "restaurant" or "food pantry"
                var address: String = "",
                var emailAddress: String = "",
                var shortDescription: String = "",
                var longDescription: String = "",
                var visible: Boolean = true,
                var website : String = "",
                var image : String = "") : Serializable