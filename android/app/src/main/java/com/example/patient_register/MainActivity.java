package com.example.patient_register;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
	private static final String CHANNEL = "samples.flutter.dev/battery";

  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
  super.configureFlutterEngine(flutterEngine);
    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
        .setMethodCallHandler(
          (call, result) -> {
            // Note: this method is invoked on the main thread.
            if (call.method.equals("backupDb")) {
              result.success(backupDb());
            } else if(call.method.equals("importDb")) {
              result.success(importDb());
            }  else {
              result.notImplemented();
            }
          }
        );
  }
  
  private int backupDb() {
    return 1;
  }
  
  private int importDb() {
    return 0;
  }
}
