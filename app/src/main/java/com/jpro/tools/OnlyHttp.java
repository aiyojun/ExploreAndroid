package com.jpro.tools;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

public class OnlyHttp {
    private String url;
    private String method;
    private String data;
    private int timeout = 0;
    private final Map<String, String> headers = new HashMap<>(128);
    private OnlyCallback solver;
    private OnlyCallback reject;

    public OnlyHttp get(String url) {
        this.headers.clear();
        this.url = url;
        this.method = "GET";
        return this;
    }

    public OnlyHttp post(String url, String data) {
        this.headers.clear();
        this.url = url;
        this.data = data;
        return this;
    }

    public OnlyHttp header(String key, String value) {
        this.headers.put(key, value);
        return this;
    }

    public OnlyHttp setTimeout(int ms) {
        this.timeout = ms;
        return this;
    }

    public OnlyHttp apply() {
        new Thread(() -> {
            try {
                HttpURLConnection http = (HttpURLConnection) new URL(this.url).openConnection();
                http.setRequestMethod(this.method);
                this.headers.forEach(http::setRequestProperty);
                if (this.timeout > 0) {
                    http.setConnectTimeout(this.timeout);
                    http.setReadTimeout(this.timeout);
                }
                http.connect();
                if ("POST".equals(this.method)) {
                    OutputStream outs = http.getOutputStream();
                    outs.write(data.getBytes(StandardCharsets.UTF_8));
                    outs.close();
                }
                InputStream ins = http.getInputStream();
                BufferedReader reader = new BufferedReader(new InputStreamReader(ins, StandardCharsets.UTF_8));
                String s;
                StringBuilder b = new StringBuilder();
                while ((s = reader.readLine()) != null) {
                    b.append(s);
                }
                reader.close();
                ins.close();
                http.disconnect();

                if (this.solver != null) {
                    this.solver.call(b.toString());
                }
            } catch (IOException e) {
                if (this.reject != null) {
                    this.reject.call(e);
                }
            }
        }).start();
        return this;
    }

    public OnlyHttp then(OnlyCallback solver) {
        this.solver = solver;
        return this;
    }

    public OnlyHttp then(OnlyCallback solver, OnlyCallback reject) {
        this.solver = solver;
        this.reject = reject;
        return this;
    }

    public interface OnlyCallback {
        void call(Object data);
    }
}
