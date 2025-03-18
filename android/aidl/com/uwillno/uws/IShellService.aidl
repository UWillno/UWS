package com.uwillno.uws;

interface IShellService {

    void destroy() = 16777114;

    void exit() = 1;

    String exec(String command) = 4;

    String execLine(String command) = 2;


    void test1() =5;
//    String execArr(in String[] command) = 3;
}


