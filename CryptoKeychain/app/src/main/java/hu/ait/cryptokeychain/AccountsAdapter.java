package hu.ait.cryptokeychain;

import android.content.Context;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import hu.ait.cryptokeychain.data.Account;
import hu.ait.cryptokeychain.data.AppDatabase;
import org.jetbrains.annotations.NotNull;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;

public class AccountsAdapter extends AccountsSelectableAdapter<AccountsAdapter.AccountsViewHolder> {
    private static String TAG = "AccountsAdapter";
    private LayoutInflater inflater;
    private List<Account> mAccounts;
    private ClickListener clickListener;

    /**
     * The adapter populates the data into the RecyclerView by converting an object at a position
     * into a list row item to be inserted. Adapters require the existence of a "ViewHolder"
     * object which describes and provides access to all the views within each item row. In our case,
     * each item row is composed of CardViews.
     *
     *  @param context
     *  @param accounts
     *  @param clickListener
     */
    public AccountsAdapter(Context context, List<Account> accounts, ClickListener clickListener) {
        inflater = LayoutInflater.from(context);
        this.mAccounts = accounts;
        this.clickListener = clickListener;
    }

    // Allows accounts to be selectable after a long click on any account
    public static class AccountsViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener,
            View.OnLongClickListener {
        private View mView;
        public TextView mAccountName;
        public TextView mAccountDescription;
        public int defaultColor;
        public int primaryColor;
        private ClickListener clickListener;

        public AccountsViewHolder(View itemView, ClickListener clickListener) {
            super(itemView);
            mView = itemView;
            this.clickListener = clickListener;

            mAccountName = mView.findViewById(R.id.account_name);
            mAccountDescription = mView.findViewById(R.id.account_description);

            // Color accounts' names will be highlighted with once selected
            primaryColor = mView.getResources().getColor(R.color.colorPrimary);
            // Default color accounts will display (i.e. when not selected or de-selected)
            defaultColor = mView.getResources().getColor(R.color.colorDefault);

            mView.setOnClickListener(this);
            mView.setOnLongClickListener(this);
        }
            // Only available when action mode is running
            @Override
            public void onClick(View v) {
                if (clickListener != null) {
                    Log.d(TAG, "Account clicked at position " + getPosition());
                    clickListener.onItemClicked(getPosition());
                }
            }

            // Starts the selection action mode
            @Override
            public boolean onLongClick(View v) {
                if (clickListener != null) {
                    Log.d(TAG, "Account long-clicked at position " + getPosition());
                    return clickListener.onItemLongClicked(getPosition());
                }
                return false;
            }
        }

    @NotNull
    @Override
    public AccountsAdapter.AccountsViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        // Inflates the XML layout file that will be used for each row within the list
        View view = inflater.inflate(R.layout.account, parent, false);
        return new AccountsViewHolder(view, this.clickListener);
    }

    /**
     * Sets the view attributes based on the data.
     *
     * @param holder
     * @param position The account whose index is 'position'
     */
    @Override
    public void onBindViewHolder(@NonNull final AccountsViewHolder holder, final int position) {
        Account currentAccount = mAccounts.get(position);
        holder.mAccountName.setText(currentAccount.getAccount_name());
        holder.mAccountDescription.setText(currentAccount.getUsername());

        // If the account is selected, set the account name to a different color
        holder.mAccountName.setTextColor(isSelected(position) ? holder.primaryColor : holder.defaultColor);
    }

    @Override
    public int getItemCount() {
        return mAccounts.size();
    }

    public void setFilter(List<Account> searchList){
        mAccounts = searchList;
        notifyDataSetChanged();
    }

    /**
     * Remove the account at position 'deletePos'
     * @param deletePos
     */
    public void deleteItem(int deletePos) {
        mAccounts.remove(deletePos);
        notifyItemRemoved(deletePos);
    }

    //TODO: Document this method
    public void removeItems(List<Integer> positions) {
        // Reverse-sort the list
        Collections.sort(positions, new Comparator<Integer>() {
            @Override
            public int compare(Integer lhs, Integer rhs) {
                return rhs - lhs;
            }
        });

        // Split the list in ranges
        while (!positions.isEmpty()) {
            if (positions.size() == 1) {
                deleteItem(positions.get(0));
                positions.remove(0);
            } else {
                int count = 1;
                while (positions.size() > count && positions.get(count).equals
                        (positions.get(count - 1) - 1)) {
                    count++;
                }

                if (count == 1) {
                    deleteItem(positions.get(0));
                } else {
                    removeRange(positions.get(count - 1), count);
                }

                for (int i = 0; i < count; ++i) {
                    positions.remove(0);
                }
            }
        }
    }

    //TODO: Document this method
    private void removeRange(int positionStart, int itemCount) {
        for (int i = 0; i < itemCount; i++) {
            mAccounts.remove(positionStart);
        }
        notifyItemRangeRemoved(positionStart, itemCount);
    }

    /**
     * Interface to listen for account clicks.
     */
    interface ClickListener {
        void onItemClicked(int position);
        boolean onItemLongClicked(int position);
    }

}
