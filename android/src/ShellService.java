package com.uwillno.uws;

import android.os.RemoteException;
import android.util.Log;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ShellService extends IShellService.Stub {
    private static final String TAG = "ShellService";

    @Override
    public void destroy() throws RemoteException {
        System.exit(0);
    }

    @Override
    public void exit() throws RemoteException {
        destroy();
    }
    @Override
    public void test1() throws RemoteException {
        new Thread(() -> test()).start();
    }
    public native void test();


    @Override
    public String exec(String command) throws RemoteException {
        Log.d(TAG, "执行命令: " + command);
        // 分割命令，假设命令之间是用分号（;）分隔的
        String[] commands = command.split(";");
        // 执行每个命令，只返回最后一个命令的结果
        String result = "";
        for (String cmd : commands) {
            cmd = cmd.trim(); // 去除每个命令两边的空格
            if (!cmd.isEmpty()) {
                result += execLine(cmd); // 执行每个命令，并更新 result
            }
        }
        // test();
        return result; // 只返回最后一个命令的执行结果
    }

    @Override
    public String execLine(String command) throws RemoteException {
        try {
            Process process = Runtime.getRuntime().exec(command);
            return readResult(process);
        } catch (IOException | InterruptedException e) {
            throw new RemoteException();
        }
    }

    // public native void test();

    private String readResult(Process process) throws IOException, InterruptedException {
        StringBuilder stringBuilder = new StringBuilder();
        BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(process.getInputStream()));
        String line;
        while ((line = bufferedReader.readLine()) != null) {
            stringBuilder.append(line).append("\n");
        }
        bufferedReader.close();
        process.waitFor();
        return stringBuilder.toString();
    }

}
