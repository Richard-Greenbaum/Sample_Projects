package hu.ait.cryptokeychain;

import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.*;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.view.ActionMode;
import androidx.appcompat.widget.SearchView;
import androidx.appcompat.widget.Toolbar;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProviders;
import androidx.navigation.Navigation;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import hu.ait.cryptokeychain.data.Account;
import hu.ait.cryptokeychain.data.AppDatabase;

import java.util.ArrayList;
import java.util.List;

public class AccountsFragment extends Fragment implements AccountsAdapter.ClickListener{
    private static String TAG = "AccountsFragment";
    private View mView;
    private SharedViewModel mViewModel;
    private List<Account> mAccounts;
    private RecyclerView mRecyclerView;
    private RecyclerView.Adapter mAdapter;
    private RecyclerView.LayoutManager mLayoutManager;
    private FloatingActionButton mFAB;
    private Toolbar mToolbar;
    private TextView emptyView;
    private ActionModeCallback actionModeCallback = new ActionModeCallback();
    private ActionMode actionMode = null;

    public static AccountsFragment newInstance() { return new AccountsFragment(); }

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
        mView = inflater.inflate(R.layout.accounts_fragment, container, false);
        ((MainActivity)getActivity()).setNavigationVisibility(true);

        new LoadAccountsAsyncTask().execute();

        setHasOptionsMenu(true);

        mFAB = mView.findViewById(R.id.add_account);
        mFAB.show();

        emptyView = mView.findViewById(R.id.empty_view);

        return mView;
    }

    @Override
    public void onActivityCreated(@Nullable Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        mViewModel = ViewModelProviders.of(getActivity()).get(SharedViewModel.class);

        mFAB.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Navigate the user to the CreateAccountFragment
                Navigation.findNavController(mView).navigate(R.id.CreateAccountFragment);
            }
        });
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        inflater.inflate(R.menu.search, menu);
        super.onCreateOptionsMenu(menu, inflater);

        MenuItem mSearch = menu.findItem(R.id.action_search);

        SearchView mSearchView = (SearchView) mSearch.getActionView();
        mSearchView.setQueryHint("Search");

        mSearchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                return false;
            }

            @Override
            public boolean onQueryTextChange(String newText) {
                newText = newText.toLowerCase();
                ArrayList<Account> searchList = new ArrayList<>();
                for (Account account : mAccounts){
                    if (account.getUsername().contains(newText) ||
                            account.getAccount_name().contains(newText)){
                        searchList.add(account);
                    }
                }
                if (searchList.isEmpty()) {
                    mRecyclerView.setVisibility(View.GONE);
                    emptyView.setVisibility(View.VISIBLE);
                }
                else {
                    mRecyclerView.setVisibility(View.VISIBLE);
                    emptyView.setVisibility(View.GONE);
                }
                ((AccountsAdapter)mAdapter).setFilter(searchList);
                return true;
            }
        });
    }

    /**
     * Starts the ActionModeCallback.
     *
     * @param position
     * @return
     */
    @Override
    public boolean onItemLongClicked(int position) {
        if (actionMode == null) {
            // Starts the ActionModeCallback after a longClick with the account that
            // was longClicked as the first account in the selectedAccounts list
            actionMode = ((AppCompatActivity)getActivity()).startSupportActionMode(actionModeCallback);
        }

        toggleSelection(position);

        return true;
    }

    /**
     * onItemClicked will only run when the ActionMode is running, at which point the accounts
     * that are tapped on will be added to the selectedAccounts list. Otherwise, item clicks
     * will be ignored.
     *
     * @param position
     */
    @Override
    public void onItemClicked(int position) {
        if (actionMode != null) {
            toggleSelection(position);
        }
    }

    /**
     * toggleSelection keeps track of the accounts that have been selected to be deleted
     * and displays the number of accounts currently selected in the ActionBar.
     *
     * @param position
     */
    public void toggleSelection(int position) {
        ((AccountsAdapter) mAdapter).toggleSelection(position);
        int count = ((AccountsAdapter) mAdapter).getSelectedItemCount();

        if (count == 0) {
            // If there are no users currently selected, terminate the ActionModeCallback
            actionMode.finish();
        } else {
            actionMode.setTitle("Accounts selected: " + String.valueOf(count));
            actionMode.invalidate();
        }
    }

    private class ActionModeCallback implements androidx.appcompat.view.ActionMode.Callback {

        /**
         * Run once on initial creation of the ActionMode. This method sets the xml layout
         * for the selection process; the menu layout sets the action buttons for this
         * ActionMode.
         *
         * @param mode
         * @param menu
         * @return
         */
        @Override
        public boolean onCreateActionMode(androidx.appcompat.view.ActionMode mode, Menu menu) {
            // Sets the ActionBar for the selection process
            mode.getMenuInflater().inflate(R.menu.selected_menu, menu);
            return true;
        }

        @Override
        public boolean onPrepareActionMode(androidx.appcompat.view.ActionMode mode, Menu menu) {
            return false;
        }

        /**
         * Run when the 'delete accounts' button on the ToolBar is clicked.
         *
         * @param mode
         * @param item
         * @return
         */
        @Override
        public boolean onActionItemClicked(androidx.appcompat.view.ActionMode mode, MenuItem item) {
            switch (item.getItemId()) {
                case R.id.menu_remove:
                    List<Integer> selectedAccounts = ((AccountsAdapter) mAdapter).getSelectedItems();
                    for(Integer position : selectedAccounts) {
                        Account accountToBeRemoved = mAccounts.get(position);
                        // Remove the user from the database
                        // FIXME: 05/07/2019 DO NOT EXECUTE AN ASYNCTASK IN A FOR LOOP--THE APP WILL HAVE TOO MANY THREADS
                        // RUNNING AT ONCE
                        new DeleteAccountsAsyncTask().execute(accountToBeRemoved);
                    }

                    // Remove account from the RecyclerView on the UI
                    ((AccountsAdapter) mAdapter).removeItems(selectedAccounts);
                    mode.finish();
                    Toast.makeText(getActivity(), "Account(s) removed from your vault!",
                            Toast.LENGTH_SHORT).show();
                    return true;

                default:
                    return false;
            }
        }

        /**
         * The following method will run when the selection process is cancelled.
         *
         * @param mode
         */
        @Override
        public void onDestroyActionMode(ActionMode mode) {
            ((AccountsAdapter) mAdapter).clearSelection();
            actionMode = null;
        }
    }


    /**
     * AsyncTask to perform database operations. Database cannot be accessed on the
     * main thread as it will lock up the UI.
     */
    private class LoadAccountsAsyncTask extends AsyncTask<Void, Void, List<Account>> {

        @Override
        protected List<Account> doInBackground(Void... voids) {
            // Retrieve information from AppDatabase
            mAccounts = AppDatabase.Companion.getInstance(getActivity()).AccountDao().getAllAccounts();
            return mAccounts;
        }

        @Override
        protected void onPostExecute(final List<Account> mAccounts) {
            // Initialize RecyclerView with data from AppDatabase
            mRecyclerView = mView.findViewById(R.id.accounts_recycler_view);
            mLayoutManager = new LinearLayoutManager(getActivity());
            mRecyclerView.setLayoutManager(mLayoutManager);
            mRecyclerView.setHasFixedSize(true);
            mAdapter = new AccountsAdapter(getActivity(), mAccounts, new AccountsAdapter.ClickListener() {
                @Override
                public void onItemClicked(int position) {
                    if (actionMode != null) {
                        toggleSelection(position);
                    } else {
                        Account currentAccount = mAccounts.get(position);

                        final Bundle bundle = new Bundle();
                        bundle.putSerializable("displayAccountInformation", currentAccount);

                        Navigation.findNavController(mView)
                                .navigate(R.id.PasswordInfoFragment, bundle);
                    }
                }

                @Override
                public boolean onItemLongClicked(int position) {
                    if (actionMode == null) {
                        actionMode = ((AppCompatActivity)getActivity()).startSupportActionMode(actionModeCallback);
                    }

                    toggleSelection(position);

                    return true;
                }
            });
            mRecyclerView.setAdapter(mAdapter);
        }
    }

    /**
     * AsyncTask to perform database operations. Database cannot be accessed on the
     * main thread as it will lock up the UI.
     */
    private class DeleteAccountsAsyncTask extends AsyncTask<Account, Void, Void> {

        @Override
        protected Void doInBackground(Account... account) {
            Account temp = account[0];
            AppDatabase.Companion.getInstance(getActivity()).AccountDao().deleteAccount(temp);
            return null;
        }
    }

}
