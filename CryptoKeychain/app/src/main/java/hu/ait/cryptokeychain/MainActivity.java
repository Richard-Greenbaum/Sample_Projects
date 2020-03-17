package hu.ait.cryptokeychain;

import android.content.Intent;
import android.util.Log;
import android.view.View;
import androidx.appcompat.widget.Toolbar;
import com.google.android.material.bottomnavigation.BottomNavigationView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.view.MenuItem;

import androidx.lifecycle.ViewModelProviders;
import androidx.navigation.NavController;
import androidx.navigation.Navigation;
import androidx.navigation.ui.NavigationUI;
import com.google.android.material.bottomnavigation.LabelVisibilityMode;

import javax.crypto.spec.SecretKeySpec;
import java.lang.reflect.Array;

import static androidx.navigation.Navigation.findNavController;

public class MainActivity extends AppCompatActivity {
    private static String TAG = "MainActivity";
    private BottomNavigationView mNavigationView;
    public NavController mNavController;
    private SharedViewModel mViewModel;
    protected SecretKeySpec passwordKey;
    public Toolbar mToolbar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main_activity);

        // Retrieve the key derived from the user's master password
        Intent intent = getIntent();
        if (intent.getExtras().containsKey("passwordKey")) {
            byte[] byte_array = intent.getByteArrayExtra("passwordKey");
            passwordKey = new SecretKeySpec(byte_array, "AES");
        }

        mViewModel = ViewModelProviders.of(this).get(SharedViewModel.class);

        setSupportActionBar(mToolbar);
        setupNavigation();

    }

    // Setting Up One Time Navigation
    private void setupNavigation(){
        mToolbar = findViewById(R.id.toolbar);
        setSupportActionBar(mToolbar);
        mNavigationView = findViewById(R.id.navigation);

        mNavController = findNavController(this, R.id.nav_host_fragment);
        NavigationUI.setupWithNavController(mNavigationView, mNavController);

        mNavigationView.setOnNavigationItemSelectedListener(new BottomNavigationView.OnNavigationItemSelectedListener() {
            @Override
            public boolean onNavigationItemSelected(@NonNull MenuItem item) {
                switch (item.getItemId()) {
                    case R.id.navigation_accounts:
                        mNavController.navigate(R.id.AccountsFragment);
                        break;
                    case R.id.navigation_settings:
                        mNavController.navigate(R.id.SettingsFragment);
                        break;
                }
                return true;
            }
        });
    }

    /**
     * Function that hides bottom navigation bar.
     *
     * @param showBottomNavigationBar when set to true, the bottom navigation bar is shown.
     */
    public void setNavigationVisibility(boolean showBottomNavigationBar) {
        if (!showBottomNavigationBar) {
            mNavigationView.setVisibility(View.GONE);
        } else {
            mNavigationView.setVisibility(View.VISIBLE);
        }
    }
}