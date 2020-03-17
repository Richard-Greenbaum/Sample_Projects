package hu.ait.cryptokeychain;

import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Base64;
import android.util.Log;
import android.view.*;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProviders;
import hu.ait.cryptokeychain.data.Account;
import hu.ait.cryptokeychain.data.AppDatabase;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.lang.reflect.Array;
import java.nio.charset.Charset;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.ArrayList;

import static android.content.ContentValues.TAG;

public class PasswordInfoFragment extends Fragment {
    private static String TAG = "PasswordInfoFragment";
    private View mView;
    private SharedViewModel mViewModel;
    private Account currentAccount;
    private String accountName, username;
    private byte[] encryptedPassword, iv;
    private TextView mAccountName, mUsername, mPassword;
    private EditText mEditAccountName, mEditUsername, mEditPassword;
    private String mNewAccountName, mNewUsername, mNewEncryptedPassword, mNewIV;
    private Button mDecrypt, mEncrypt;
    private SecretKeySpec passwordKey;

    public static PasswordInfoFragment newInstance() {
        return new PasswordInfoFragment();
    }

    /**
     * This initializes the UI variables once the fragment starts up, and returns the view
     * to its parent.
     *
     * @param inflater
     * @param container
     * @param savedInstanceState
     * @return
     */
    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        // Get the view from fragment XML
        mView = inflater.inflate(R.layout.password_info_fragment, container, false);
        ((MainActivity)getActivity()).setNavigationVisibility(false);

        currentAccount = (Account)getArguments().getSerializable("displayAccountInformation");

        // Initialize UI elements
        mAccountName = mView.findViewById(R.id.display_website);
        mUsername = mView.findViewById(R.id.display_username);
        mPassword = mView.findViewById(R.id.display_password);
        mDecrypt = mView.findViewById(R.id.decrypt_password);
        mEncrypt = mView.findViewById(R.id.encrypt_password);
        mEditAccountName = mView.findViewById(R.id.edit_website);
        mEditUsername = mView.findViewById(R.id.edit_username);
        mEditPassword = mView.findViewById(R.id.edit_password);

        setHasOptionsMenu(true);

        return mView;

    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        inflater.inflate(R.menu.edit_account, menu);
        super.onCreateOptionsMenu(menu, inflater);

        final MenuItem mEdit = menu.findItem(R.id.action_edit);
        final MenuItem mDone = menu.findItem(R.id.action_edit_done);
        final MenuItem mCancel = menu.findItem(R.id.action_edit_cancel);

        mEdit.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                editAccount();
                mEdit.setVisible(false);
                mDone.setVisible(true);
                mCancel.setVisible(true);
                mDecrypt.setVisibility(View.GONE);
                mEncrypt.setVisibility(View.GONE);
                return true;
            }
        });

        mDone.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                saveChanges();
                mEdit.setVisible(true);
                mDone.setVisible(false);
                mCancel.setVisible(false);
                mDecrypt.setVisibility(View.VISIBLE);
                mEncrypt.setVisibility(View.VISIBLE);
                return true;
            }
        });

        mCancel.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                cancelEdit();
                mEdit.setVisible(true);
                mDone.setVisible(false);
                mCancel.setVisible(false);
                mDecrypt.setVisibility(View.VISIBLE);
                mEncrypt.setVisibility(View.VISIBLE);
                return true;
            }
        });
    }

    /**
     * We display the account information by accessing the properties of currentAccount.
     *
     * @param savedInstanceState
     */
    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        mViewModel = ViewModelProviders.of(getActivity()).get(SharedViewModel.class);

        if(currentAccount != null) {

            accountName = currentAccount.getAccount_name();
            username = currentAccount.getUsername();

            encryptedPassword = android.util.Base64.decode(currentAccount.getEncrypted_password(), Base64.DEFAULT);
            iv = android.util.Base64.decode(currentAccount.getIv(), Base64.DEFAULT);

            // Display account information for the account that was tapped on
            mAccountName.setText(accountName);
            mUsername.setText(username);
            mPassword.setText(new String(encryptedPassword));

            // If 'Decrypt Password' button is tapped, display the account's decrypted password
            mDecrypt.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mPassword.setText(decryptPassword(encryptedPassword));

                }
            });

            // If 'Encrypt Password' button is tapped, display the account's encrypted password
            mEncrypt.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mPassword.setText(new String(encryptedPassword));
                }
            });

        }
    }

    private void editAccount() {
        // Hide the TextViews displaying the account information
        mAccountName.setVisibility(View.GONE);
        mUsername.setVisibility(View.GONE);
        mPassword.setVisibility(View.GONE);

        // Display the EditTexts in place of the TextViews allowing the user to change their account details
        mEditAccountName.setVisibility(View.VISIBLE);
        mEditUsername.setVisibility(View.VISIBLE);
        mEditPassword.setVisibility(View.VISIBLE);

        mEditAccountName.setText(currentAccount.getAccount_name());
        mEditUsername.setText(currentAccount.getUsername());
        mEditPassword.setText(decryptPassword(encryptedPassword));
    }

    private void saveChanges() {
        // Retrieve changes made to the account
        mNewAccountName = mEditAccountName.getText().toString();
        mNewUsername = mEditUsername.getText().toString();
        ArrayList<String> temp = encryptPassword(mEditPassword.getText().toString());
        mNewEncryptedPassword = temp.get(0);
        mNewIV = temp.get(1);

        // Hide the EditTexts brought into view after 'Edit Account' action was pressed
        mEditAccountName.setVisibility(View.GONE);
        mEditUsername.setVisibility(View.GONE);
        mEditPassword.setVisibility(View.GONE);

        // Save changes to AppDatabase
        new EditAccountAsyncTask().execute(currentAccount, mNewAccountName, mNewUsername, mNewEncryptedPassword, mNewIV);

        // Display the TextViews in place of the EditTexts, displaying the user's changes to change their account
        // The EditAccountsAsyncTask will update the TextViews with the new account information in the onPostExecute method
        mAccountName.setVisibility(View.VISIBLE);
        mUsername.setVisibility(View.VISIBLE);
        mPassword.setVisibility(View.VISIBLE);
    }

    private void cancelEdit() {
        // Hide the EditTexts brought into view after 'Edit Account' action was pressed
        mEditAccountName.setVisibility(View.GONE);
        mEditUsername.setVisibility(View.GONE);
        mEditPassword.setVisibility(View.GONE);

        // Display the TextViews in place of the EditTexts, displaying the user's original account details
        mAccountName.setVisibility(View.VISIBLE);
        mUsername.setVisibility(View.VISIBLE);
        mPassword.setVisibility(View.VISIBLE);

        mAccountName.setText(accountName);
        mUsername.setText(username);
        mPassword.setText(new String(encryptedPassword));
    }

    private String decryptPassword(byte[] ciphertext) {
        String temp = "";
        Cipher cipher = null;
        try {
            cipher = Cipher.getInstance("AES/CBC/PKCS7Padding");
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        } catch (NoSuchPaddingException e) {
            e.printStackTrace();
        }

        // Retrieve the key derived from the user's master password
        passwordKey = ((MainActivity)getActivity()).passwordKey;

        // Create an IvParameterSpec object from the IV used to encrypt the account information
        iv = android.util.Base64.decode(currentAccount.getIv(), Base64.DEFAULT);
        Log.w(TAG, currentAccount.getIv());
        IvParameterSpec ivSpec = new IvParameterSpec(iv);

        // Create Cipher object, decrypt encrypted password
        try {
            cipher.init(Cipher.DECRYPT_MODE, passwordKey, ivSpec);
            byte[] decrypted = cipher.doFinal(ciphertext);
            temp = new String(decrypted);
            return temp;
        } catch (InvalidAlgorithmParameterException e) {
            e.printStackTrace();
        } catch (InvalidKeyException e) {
            e.printStackTrace();
        } catch (BadPaddingException e) {
            e.printStackTrace();
        } catch (IllegalBlockSizeException e) {
            e.printStackTrace();
        }
        return temp;
    }

    private ArrayList<String> encryptPassword(String password) {
        // Initialize an ArrayList where we will store the encrypted password and the IV used to encrypt the password
        ArrayList<String> passwordAndIV = new ArrayList<>();

        // Retrieve the key derived from the user's master password
        passwordKey = ((MainActivity)getActivity()).passwordKey;

        // Create 16 bytes of random data; package it into an IvParameterSpec object
        SecureRandom ivRandom = new SecureRandom();
        byte[] iv = new byte[16];
        ivRandom.nextBytes(iv);
        IvParameterSpec ivSpec = new IvParameterSpec(iv);

        // Encrypt password using AES-CBC mode and PKCS-7 Padding Scheme
        Cipher cipher = null;
        try {
            cipher = Cipher.getInstance("AES/CBC/PKCS7Padding");
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        } catch (NoSuchPaddingException e) {
            e.printStackTrace();
        }

        try {
            cipher.init(Cipher.ENCRYPT_MODE, passwordKey, ivSpec);
        } catch (InvalidAlgorithmParameterException e) {
            e.printStackTrace();
        } catch (InvalidKeyException e) {
            e.printStackTrace();
        }

        byte[] temp = password.getBytes(Charset.defaultCharset());
        try {
            temp = cipher.doFinal(temp);
        } catch (BadPaddingException e) {
            e.printStackTrace();
        } catch (IllegalBlockSizeException e) {
            e.printStackTrace();
        }

        // Return newly encrypted password and the iv used to encrypt the password
        String encryptedPassword = android.util.Base64.encodeToString(temp, Base64.DEFAULT);
        String ivString = android.util.Base64.encodeToString(iv, Base64.DEFAULT);

        passwordAndIV.add(encryptedPassword);
        passwordAndIV.add(ivString);

        return passwordAndIV;

    }

    /**
     * AsyncTask to perform database operations. Database cannot be accessed on the
     * main thread as it will lock up the UI.
     */
    private class EditAccountAsyncTask extends AsyncTask<Object, Void, ArrayList<String>> {

        @Override
        protected ArrayList<String> doInBackground(Object... params) {
            Account temp = (Account)params[0];
            String mNewAccountName = (String)params[1];
            String mNewUsername = (String)params[2];
            String mNewPassword = (String)params[3];
            String mNewIV = (String)params[4];

            temp.setAccount_name(mNewAccountName);
            temp.setUsername(mNewUsername);
            temp.setEncrypted_password(mNewPassword);
            temp.setIv(mNewIV);

            AppDatabase.Companion.getInstance(getActivity()).AccountDao().updateAccount(temp);

            currentAccount = temp;
            Log.w(TAG, currentAccount.toString());

            return null;
        }

        @Override
        protected void onPostExecute(ArrayList params) {
            accountName = currentAccount.getAccount_name();
            username = currentAccount.getUsername();

            encryptedPassword = android.util.Base64.decode(currentAccount.getEncrypted_password(), Base64.DEFAULT);
            iv = android.util.Base64.decode(currentAccount.getIv(), Base64.DEFAULT);

            // Display updated account information
            mAccountName.setText(accountName);
            mUsername.setText(username);
            mPassword.setText(new String(encryptedPassword));

            // If 'Decrypt Password' button is tapped, display the account's decrypted password
            mDecrypt.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mPassword.setText(decryptPassword(encryptedPassword));

                }
            });

            // If 'Encrypt Password' button is tapped, display the account's encrypted password
            mEncrypt.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mPassword.setText(new String(encryptedPassword));
                }
            });
        }
    }

}