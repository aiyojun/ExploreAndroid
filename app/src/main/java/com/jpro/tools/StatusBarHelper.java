package com.jpro.tools;

import android.app.Activity;
import android.graphics.Color;
import android.util.Log;
import android.view.*;

public class StatusBarHelper {
    private Activity activity;

    public StatusBarHelper(Activity activity) {
        this.activity = activity;
    }

    public StatusBarHelper transparent(Activity activity) {
        activity.getWindow().setStatusBarColor(Color.TRANSPARENT);
        return this;
    }


    public StatusBarHelper immersionStyle() {
//        activity.getWindow().getDecorView().setSystemUiVisibility();
        Window window = activity.getWindow();
//        window.setFlags(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
//        window.setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        WindowManager windowManager = activity.getWindowManager();
//        windowManager.updateViewLayout();
//        windowManager.updateViewLayout();
//        WindowManager.LayoutParams
        View decor = window.getDecorView();
//        decor.setLayoutParams();
//        decor.getLayoutParams();
        Log.i("YYY", String.valueOf(decor.getLayoutParams()));
//        ((WindowManager.LayoutParams) decor.getLayoutParams()).setFitInsetsTypes(WindowInsets.Type.statusBars());
//        decor.getWindowInsetsController().setSystemBarsBehavior();
//        WindowInsetsController controller = window.getDecorView().getWindowInsetsController();
//        controller.hide(WindowInsets.Type.statusBars());
//        decor.setOnApplyWindowInsetsListener(new View.OnApplyWindowInsetsListener() {
//            @Override
//            public WindowInsets onApplyWindowInsets(View v, WindowInsets insets) {
//                Log.i("XXX", String.valueOf(v.getTop()));
//                Log.i("XXX", String.valueOf(v.getBottom()));
//                return insets;
//            }
//        });
//        decor.setFitsSystemWindows();
//        decor.setFitsSystemWindows(true);
//        window.setFi
//        decor.getLayoutParams()
//        decor.setSystemUiVisibility();
//        controller.setSystemBarsBehavior();

        return this;
    }
}
