package com.uwillno.uws;

import android.app.Service;
import android.content.ComponentName;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.pm.PackageManager;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.Log;

import androidx.annotation.Nullable;

import rikka.shizuku.Shizuku;

import android.content.ComponentName;
import android.content.ServiceConnection;
import android.content.pm.PackageManager;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.Log;

import rikka.shizuku.Shizuku;

public class SZK {
    private static final String TAG = "shizukuService";
    private final static int PERMISSION_CODE = 10001;
    private boolean isServiceConnected = false;
    private IShellService binder;

    private final Shizuku.UserServiceArgs userServiceArgs =
            new Shizuku.UserServiceArgs(new ComponentName(BuildConfig.APPLICATION_ID, ShellService.class.getName()))
                    .daemon(false)
                    .processNameSuffix("shizuku_service")
                    .debuggable(BuildConfig.DEBUG)
                    .version(BuildConfig.VERSION_CODE);

    private final ServiceConnection serviceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            Log.d(TAG, "Shizuku 用户服务已连接！");
                signal("Shizuku 用户服务已连接！");
            if(service != null && service.pingBinder())
                binder = IShellService.Stub.asInterface(service);
            isServiceConnected = true;
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            Log.d(TAG, "Shizuku 用户服务断开连接！");
              signal("Shizuku 用户服务断开连接！");
            isServiceConnected = false;
        }
    };

    public native void signal(String info);
    // SZK(){
    //     initShizuku();
    //     }

    public String execCommand(String command) throws RemoteException {
        return checkPermission() && isServiceConnected && binder!=null ? binder.exec(command) : "无权限或未连接上Shizuku服务";
    }
    // 是否检出
    public void initShizuku() {
        if(Shizuku.pingBinder()) {
            if (!checkPermission()) {
                Log.d(TAG, "没有权限，正在请求权限...");
                signal("没有权限，正在请求权限...");
                Shizuku.requestPermission(PERMISSION_CODE);
                // return false;
            }
            Log.d(TAG, "正在绑定 Shizuku 用户服务...");
            signal("正在绑定 Shizuku 用户服务...");
            Shizuku.bindUserService(userServiceArgs, serviceConnection);
            // return checkPermission();
        }
        signal("shizuku未启动");
        // return false;
     }
     // 检查是否有权限
    private boolean checkPermission() {
        return Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED;
    }

}
