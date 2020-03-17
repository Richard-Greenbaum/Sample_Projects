package hu.ait.cryptokeychain.data

import androidx.room.*


@Dao
interface AccountDAO {
    @Query("SELECT * FROM account")
    fun getAllAccounts(): List<Account>

    @Insert
    fun insertAccount(account: Account) : Long

    @Delete
    fun deleteAccount(account: Account)

    @Update
    fun updateAccount(account: Account)

    @Query("DELETE FROM account")
    fun deleteAll()
}