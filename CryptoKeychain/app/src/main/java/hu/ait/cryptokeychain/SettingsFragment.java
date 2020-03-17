package hu.ait.cryptokeychain;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import hu.ait.cryptokeychain.data.AppDatabase;

public class SettingsFragment extends Fragment {
    private static String TAG = "SettingsFragment";
    private TextView resetApp;
    private View mView;
    private SharedViewModel mViewModel;

    public static SettingsFragment newInstance() {
        return new SettingsFragment();
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
        mView = inflater.inflate(R.layout.settings_fragment, container, false);
        ((MainActivity)getActivity()).setNavigationVisibility(true);

        // Initialize UI elements
        resetApp = mView.findViewById(R.id.reset_app);

        return mView;

    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        resetApp.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                AlertDialog.Builder resetConfirmationDialog = new AlertDialog.Builder(getActivity());
                resetConfirmationDialog.setTitle("Erase All Content and Settings");
                resetConfirmationDialog.setMessage("Are you sure you want to erase all content and settings? This " +
                        "process cannot be undone.");
                resetConfirmationDialog.setPositiveButton("Reset App", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        // Delete the user's master password and their stored account information
                        SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(getActivity());
                        SharedPreferences.Editor editor = sharedPref.edit();
                        editor.putBoolean("HAS_PASSWORD", false);
                        editor.apply();
                        new DeleteAllAccountsAsyncTask().execute();

                        // Take them back to the NewUserActivity
                        Intent intent = new Intent(getActivity(), NewUserActivity.class);
                        startActivity(intent);
                    }
                });
                resetConfirmationDialog.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                    }
                });
                resetConfirmationDialog.show();
            }
        });

    }

    /**
     * AsyncTask to perform database operations. Database cannot be accessed on the
     * main thread as it will lock up the UI.
     */
    private class DeleteAllAccountsAsyncTask extends AsyncTask<Void, Void, Void> {

        @Override
        protected Void doInBackground(Void... account) {
            AppDatabase.Companion.getInstance(getActivity()).AccountDao().deleteAll();
            return null;
        }
    }
}
