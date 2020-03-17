package hu.ait.cryptokeychain.data

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import java.io.Serializable

@Entity(tableName = "account")
data class Account(
    @PrimaryKey(autoGenerate = true) var itemId : Long?,
    @ColumnInfo(name = "account_name") var account_name: String,
    @ColumnInfo(name = "username") var username: String,
    @ColumnInfo(name = "encrypted_password") var encrypted_password: String,
    @ColumnInfo(name = "iv") var iv: String


    ) : Serializable