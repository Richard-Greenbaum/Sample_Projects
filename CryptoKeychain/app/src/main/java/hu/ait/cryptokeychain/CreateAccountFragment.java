package hu.ait.cryptokeychain;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Base64;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.*;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.navigation.Navigation;
import hu.ait.cryptokeychain.data.Account;
import hu.ait.cryptokeychain.data.AppDatabase;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.Charset;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Random;

import static android.content.ContentValues.TAG;

public class CreateAccountFragment extends Fragment {
    private static String TAG = "CreateAccountFragment";
    private View mView;
    private SharedViewModel mViewModel;
    private Button mCancel, mDone, mGenerate;
    private EditText website, username, password;
    private SecretKeySpec passwordKey;

    public static CreateAccountFragment newInstance() {
        return new CreateAccountFragment();
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
        mView = inflater.inflate(R.layout.create_account_fragment, container, false);
        ((MainActivity) getActivity()).setNavigationVisibility(false);

        // Initialize create account UI elements
        mCancel = mView.findViewById(R.id.cancel_acct_create);
        mDone = mView.findViewById(R.id.confirm_acct_create);
        mGenerate = mView.findViewById(R.id.generatePasswordBtn2);
        website = mView.findViewById(R.id.website);
        username = mView.findViewById(R.id.username);
        password = mView.findViewById(R.id.password);

        return mView;
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        mCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // If the user cancels account creation, take them back to the landing page
                Navigation.findNavController(mView).navigate(R.id.AccountsFragment);
            }
        });

        mGenerate.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                AlertDialog.Builder PassGenDialogue = new AlertDialog.Builder(getActivity());

                View rootView = getActivity().getLayoutInflater().inflate(R.layout.password_gen_dialogue, null);

                final CheckBox upperLetterCB, numCB, symbolCB;
                final NumberPicker passwordLengthPicker;

                upperLetterCB = rootView.findViewById(R.id.uppercaseLetterCb);
                numCB = rootView.findViewById(R.id.numbersCb);
                symbolCB = rootView.findViewById(R.id.symbolsCb);
                passwordLengthPicker = rootView.findViewById(R.id.lengthPicker);

                passwordLengthPicker.setMinValue(8);
                passwordLengthPicker.setMaxValue(12);
                passwordLengthPicker.setWrapSelectorWheel(false);

                PassGenDialogue.setTitle("Password Generation");

                PassGenDialogue.setPositiveButton("Generate Password", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        password.setText(generatePassword(upperLetterCB.isChecked(), numCB.isChecked(),
                                symbolCB.isChecked(), passwordLengthPicker));
                    }
                });
                PassGenDialogue.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                    }
                });
                PassGenDialogue.setView(rootView);
                PassGenDialogue.show();
            }
        });

        mDone.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String mAccountName = website.getText().toString();
                String mUsername = username.getText().toString();

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

                byte[] temp = password.getText().toString().getBytes(Charset.defaultCharset());
                try {
                    temp = cipher.doFinal(temp);
                } catch (BadPaddingException e) {
                    e.printStackTrace();
                } catch (IllegalBlockSizeException e) {
                    e.printStackTrace();
                }

                // Store username, account name, encrypted password, and the iv used to encrypt in the app's database
                String encryptedPassword = android.util.Base64.encodeToString(temp, Base64.DEFAULT);
                String ivString = android.util.Base64.encodeToString(iv, Base64.DEFAULT);
                saveToDatabase(mAccountName, mUsername, encryptedPassword, ivString);

                // Let the user know their account has been successfully added
                Toast.makeText(getActivity(), "Account securely stored!", Toast.LENGTH_LONG).show();

                // Take the user back to the AccountsFragment where they will see their updated accounts RecyclerView
                Navigation.findNavController(mView).navigate(R.id.AccountsFragment);
            }
        });

    }

    private String generatePassword(Boolean upperLetterCB, Boolean numberCB, Boolean symbolCB, NumberPicker lengthPicker) {
        ArrayList<String> base = new ArrayList<>(Arrays.asList("a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
                "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"));

        ArrayList<String> upper = new ArrayList<>(Arrays.asList("A","B","C","D","E","F","G", "H","I","J",
                "K","L","M","N","O","P", "Q","R","S","T","U","V","W","X","Y","Z"));

        ArrayList<String> num = new ArrayList<>(Arrays.asList("0","1","2","3","4","5","6","7","8","9"));

        ArrayList<String> symbol = new ArrayList<>(Arrays.asList("`","~",",","<",".",">","/", "?",";",":","\\","|",
                "[","{","]","}","!","@", "#","$","%","^","&","*","(",")","-","_","=","+", "\"", "'"));

        if (upperLetterCB) {
            base.addAll(upper);
        }

        if (numberCB) {
            base.addAll(num);
        }

        if (symbolCB) {
            base.addAll(symbol);
        }

        StringBuilder generatedPassword = new StringBuilder();
        for (int i = 0; i <= lengthPicker.getValue()-1; i++) {
            Random random = new SecureRandom();
            int index = random.nextInt(base.size());
            generatedPassword.append(base.get(index));
        }

        return generatedPassword.toString();
    }

    private void saveToDatabase(String mAccountName, String mUsername, String encryptedPassword, String iv) {
        Account newAccount = new Account(null, mAccountName, mUsername, encryptedPassword, iv);
        new AddAccountAsyncTask().execute(newAccount);
    }

    /**
     * AsyncTask to perform database operations. Database cannot be accessed on the
     * main thread as it will lock up the UI.
     */
    private class AddAccountAsyncTask extends AsyncTask<Account, Void, Void> {

        @Override
        protected Void doInBackground(Account... newAccount) {
            Account temp = newAccount[0];
            AppDatabase.Companion.getInstance(getActivity()).AccountDao().insertAccount(temp);
            return null;
        }
    }

}
