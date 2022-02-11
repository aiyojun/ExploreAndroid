package com.jpro;

import android.app.Activity;
import android.media.projection.MediaProjectionManager;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.WindowInsets;
import android.view.WindowInsetsController;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;

public class MainActivity extends Activity {

	@Override
	protected void onCreate(Bundle bundle) {
		super.onCreate(bundle);
		setContentView(R.layout.activity_main);
        getActionBar().hide();
//		MediaProjectionManager
//		View decorView = getWindow().getDecorView();
//		WindowInsetsController controller = getWindow()
//				.getDecorView().getWindowInsetsController();
//		controller.hide(WindowInsets.Type.navigationBars());
//		controller.setSystemBarsBehavior(WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
//		controller.hide(WindowInsets.Type.statusBars());
//		int uiOptions  = View.SYSTEM_UI_FLAG_FULLSCREEN;
//		decorView.setSystemUiVisibility();
//		ViewCompat.getWindowSystemUiVisibility(decorView);
//		ViewCompat.
	}

}