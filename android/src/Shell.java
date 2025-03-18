package com.uwillno.uws;

import android.os.RemoteException;
import android.util.Log;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;


public class Shell {


    public static String exec(String command) throws IOException, InterruptedException {

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


    // public static String execLine(String command) throws IOException, InterruptedException {
    //         Process process = Runtime.getRuntime().exec(new String[]{"su", "-c", command});
    //         return readResult(process);
    // }
    public static String execLine(String command) throws IOException, InterruptedException {
        if (isRootAvailable()) {
            signal("已获取root权限！");
            Process process = Runtime.getRuntime().exec(new String[]{"su", "-c", command});
            return readResult(process);
        } else {
            signal("无root权限，以普通权限执行！");
            Process process = Runtime.getRuntime().exec(command);
            return readResult(process);
        }
    }

    public static boolean isRootAvailable() {
        try {
            Process process = Runtime.getRuntime().exec("su -c echo test");
            int exitCode = process.waitFor();
            return exitCode == 0;
        } catch (Exception e) {
            return false;
        }
    }

    private static String readResult(Process process) throws IOException, InterruptedException {
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


    public static native void signal(String info);
}
