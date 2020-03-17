package hu.ait.cryptokeychain;

import android.util.SparseBooleanArray;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;
import java.util.List;

public abstract class AccountsSelectableAdapter<VH extends RecyclerView.ViewHolder> extends RecyclerView.Adapter<VH> {
    private static String TAG = "AccountsSelectableAdapter";
    private SparseBooleanArray selectedAccounts;

    public AccountsSelectableAdapter() {
        selectedAccounts = new SparseBooleanArray();
    }

    /**
     * Indicates if the account at position 'position' is selected.
     *
     * @param position Position of the account to check
     * @return true if the account is selected, false otherwise
     */
    public boolean isSelected(int position) {
        return getSelectedItems().contains(position);
    }

    /**
     * Toggle the selection status of the account at a given position.
     *
     * @param position Position of the account to toggle the selection status for
     */
    public void toggleSelection(int position) {
        if (selectedAccounts.get(position, false)) {
            selectedAccounts.delete(position);
        } else {
            selectedAccounts.put(position, true);
        }
        notifyItemChanged(position);
    }

    /**
     * Clear the selection status for all accounts.
     */
    public void clearSelection() {
        List<Integer> selection = getSelectedItems();
        selectedAccounts.clear();
        for (Integer i : selection) {
            notifyItemChanged(i);
        }
    }

    /**
     * Count the selected accounts.
     *
     * @return Selected accounts count
     */
    public int getSelectedItemCount() {
        return selectedAccounts.size();
    }

    /**
     * Indicates the list of selected accounts.
     *
     * @return List of selected account ids
     */
    public List<Integer> getSelectedItems() {
        List<Integer> items = new ArrayList<>(selectedAccounts.size());
        for (int i = 0; i < selectedAccounts.size(); ++i) {
            items.add(selectedAccounts.keyAt(i));
        }
        return items;
    }

}
