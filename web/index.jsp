<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.regex.Pattern" %>
<%@ page import="java.util.regex.Matcher" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.math.BigInteger" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    /**
     * 测试访问路径
     * http://localhost:8080/index.jsp?p=123456
     */
    // 当前页面
    String active = request.getParameter("a");
    // 最大日志行数
    String maxLine = request.getParameter("m");
    // 日志只显示错误信息
    String onlyError = request.getParameter("o");
    // 密码MD5
    String pwd = request.getParameter("p");
    String token = request.getParameter("t");
    if (pwd == null && token == null) {
        response.sendError(404);
        return;
    } else if (token == null && pwd != null) {
        MessageDigest md = MessageDigest.getInstance("MD5");
        md.update(pwd.getBytes());
        byte[] secretBytes = md.digest();
        token = new BigInteger(1, secretBytes).toString(16);
        for (int i = 0; i < 32 - token.length(); i++) {
            token = "0" + token;
        }
    }
    if (!"e10adc3949ba59abbe56e057f20f883e".equalsIgnoreCase(token)) {
        // 防止被扫到 token 不正确直接404
        response.sendError(404);
        return;
    }
    active = active == null ? "index" : active;
    maxLine = maxLine == null ? "200" : maxLine;
    onlyError = onlyError == null ? "0" : onlyError;
    // 基本信息配置 首次使用需要更改
    request.setAttribute("active", active);
    request.setAttribute("token", token);
    request.setAttribute("maxLine", maxLine);
    request.setAttribute("onlyError", onlyError);
    request.setAttribute("nginxLogPath", "C:\\Users\\Administrator\\IdeaProjects\\nginx-gui-jsp\\testData\\nginx\\logs\\");
    request.setAttribute("nginxConfigPath", "C:\\Users\\Administrator\\IdeaProjects\\nginx-gui-jsp\\testData\\nginx\\conf\\");
    request.setAttribute("nginxStatusUrl", "https://bz.zzzmh.cn/nginx/status");
%>
<html lang="zh-CN">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Nginx 控制台</title>
    <link rel="icon" type="image/jpeg"
          href="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAAQABADASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwDtNXvNd8WSa5ZWV7HZQ6fKIEt14a6JLDBfPBO3gdDmqfhjW9a0SDQo7i5+02upXD232edSHt9rheG69+h9KPFGia1o0OuSW9t9ptdRuUuhcwMQ9uVYtyvXv1HpVrSrTXfF02h313Yx2UGnymZ7huDdElSSExwTt5PTn8K4/e5ut/8Ag/5HhfvPbdef52+L7tvl8z//2Q==">
    <%-- 七牛云提供免费CDN AmazeUI https cdn --%>
    <link href="https://cdn.staticfile.org/amazeui/2.7.2/css/amazeui.min.css" rel="stylesheet">
    <link href="https://cdn.staticfile.org/highlight.js/9.15.6/styles/github.min.css" rel="stylesheet">
    <style>
        body {
            font: 14px/1.5 "Helvetica Neue", "Helvetica,Arial", "Microsoft Yahei", "Hiragino Sans GB", "HeitiSC", "WenQuanYi Micro Hei", sans-serif;
        }

        @media only screen and (min-width: 641px) {
            .am-offcanvas {
                display: block;
                position: static;
                background: none;
            }

            .am-offcanvas-bar {
                position: static;
                width: auto;
                background: none;
                -webkit-transform: translate3d(0, 0, 0);
                -ms-transform: translate3d(0, 0, 0);
                transform: translate3d(0, 0, 0);
            }

            .am-offcanvas-bar:after {
                content: none;
            }

        }

        @media only screen and (max-width: 640px) {
            .am-offcanvas-bar .am-nav > li > a {
                color: #ccc;
                border-radius: 0;
                border-top: 1px solid rgba(0, 0, 0, .3);
                box-shadow: inset 0 1px 0 rgba(255, 255, 255, .05)
            }

            .am-offcanvas-bar .am-nav > li > a:hover {
                background: #404040;
                color: #fff
            }

            .am-offcanvas-bar .am-nav > li.am-nav-header {
                color: #777;
                background: #404040;
                box-shadow: inset 0 1px 0 rgba(255, 255, 255, .05);
                text-shadow: 0 1px 0 rgba(0, 0, 0, .5);
                border-top: 1px solid rgba(0, 0, 0, .3);
                font-weight: 400;
                font-size: 75%
            }

            .am-offcanvas-bar .am-nav > li.am-active > a {
                background: #1a1a1a;
                color: #fff;
                box-shadow: inset 0 1px 3px rgba(0, 0, 0, .3)
            }

            .am-offcanvas-bar .am-nav > li + li {
                margin-top: 0;
            }
        }

        .my-button {
            position: fixed;
            top: 0;
            right: 0;
            border-radius: 0;
        }

        .my-sidebar {
            padding-right: 0;
            border-right: 1px solid #eeeeee;
        }

        .am-breadcrumb {
            /*padding-bottom: 0px;*/
            margin-bottom: 0px;
        }
    </style>
</head>
<body>
<div class="am-g">
    <%-- 中间部分 --%>
    <div class="am-u-md-11 am-u-md-push-1">
        <div class="am-g">
            <div class="am-u-sm-12 am-u-sm-centered">
                <div class="am-cf am-article">
                    <div class="am-u-md-12">
                        <ol class="am-breadcrumb">
                            <li><a href="/?a=index&t=${token}">控制台</a></li>
                            <li class="am-active">
                                <c:if test="${active == 'index'}">首页</c:if>
                                <c:if test="${active == 'nginxMonitor'}">Nginx 监控</c:if>
                                <c:if test="${active == 'nginxConfig'}">Nginx 配置</c:if>
                                <c:if test="${active == 'nginxLogs'}">Nginx 日志</c:if>
                                <c:if test="${active == 'about'}">关于</c:if>
                            </li>
                        </ol>
                    </div>
                    <c:if test="${active == 'index'}">
                        <h1>首页</h1>
                    </c:if>
                    <c:if test="${active == 'nginxMonitor'}">
                        <h1>Nginx监控</h1>
                    </c:if>
                    <c:if test="${active == 'nginxConfig'}">
                        <div class="am-u-md-12">
                            <button type="button" class="am-btn am-btn-primary am-btn-xs" onclick="{
                                $('#nginx-config code').attr('contentEditable',true);
                                $('#nginx-config code').focus();
                            }">编辑
                            </button>
                            <button type="button" class="am-btn am-btn-danger am-btn-xs" onclick="{
                                $('#nginx-config code').attr('contentEditable',false);
                            }">取消
                            </button>
                            <button type="button" class="am-btn am-btn-success am-btn-xs">保存</button>
                            <button type="button" class="am-btn am-btn-warning am-btn-xs">校验</button>
                            <button type="button" class="am-btn am-btn-secondary am-btn-xs">生效</button>
                            <span class="am-fr">参考文档: <a href="https://cloud.tencent.com/developer/doc/1158"
                                                         target="_blank">https://cloud.tencent.com/developer/doc/1158</a></span>
                        </div>
                        <div class="am-u-md-12">
                            <pre id="nginx-config" class=""><code class="nginx"><%
                                BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(
                                        new FileInputStream(request.getAttribute("nginxConfigPath") + "nginx.conf"), "UTF-8"));
                                String temp = null;
                                while ((temp = bufferedReader.readLine()) != null) {
                                    out.print(temp + "\n");
                                }
                            %></code></pre>
                        </div>
                    </c:if>
                    <c:if test="${active == 'nginxLogs'}">
                        <div class="am-u-md-12" style="margin-bottom: 6px;">
                            <label>显示条数：</label>
                            <select id="maxLine" data-am-selected="{btnSize: 'xs'}">
                                <option value="200" ${maxLine == 200 ? 'selected': ''}>200</option>
                                <option value="400" ${maxLine == 400 ? 'selected': ''}>400</option>
                                <option value="800" ${maxLine == 800 ? 'selected': ''}>800</option>
                            </select>
                            <label>只显示异常：</label>
                            <select id="onlyError" data-am-selected="{btnSize: 'xs'}">
                                <option value="0" ${onlyError == 0 ? 'selected': ''}>关闭</option>
                                <option value="1" ${onlyError == 1 ? 'selected': ''}>开启</option>
                            </select>
                            <button type="button" class="am-btn am-btn-secondary am-btn-xs"
                                    onclick="{
                                            window.location.href = 'index.jsp?a=nginxLogs&t=${token}'
                                            + '&m=' + $('#maxLine').val() + '&o=' + $('#onlyError').val();
                                            }">刷新
                            </button>
                        </div>
                        <div class="am-u-md-12">
                            <table class="am-table am-table-bordered am-table-radius am-table-striped am-text-nowrap am-scrollable-horizontal"
                                   style="font-size: 12px">
                                <thead>
                                <tr>
                                    <th>IP</th>
                                    <th>时间</th>
                                    <th>目标</th>
                                    <th>状态</th>
                                    <th>消耗</th>
                                    <th>主域</th>
                                    <th>UA</th>
                                </tr>
                                </thead>
                                <tbody>
                                <%
                                    String filename = request.getAttribute("nginxLogPath") + "access.log";
                                    String charset = "UTF-8";
                                    SimpleDateFormat dateFormat = new SimpleDateFormat("[dd/MMM/yyyy:HH:mm:ss Z]", Locale.ENGLISH);
                                    SimpleDateFormat sdf = new SimpleDateFormat("MM/dd HH:mm");
                                    RandomAccessFile rf = null;
                                    try {
                                        rf = new RandomAccessFile(filename, "r");
                                        long len = rf.length();
                                        long start = rf.getFilePointer();
                                        long nextend = start + len - 1;
                                        String line;
                                        rf.seek(nextend);
                                        int c = -1;
                                        int count = 0;
                                        while (nextend > start && count <= Integer.parseInt(maxLine)) {
                                            c = rf.read();
                                            if (c == '\n' || c == '\r') {
                                                line = rf.readLine();
                                                if (line != null) {
                                                    line = new String(line.getBytes("ISO-8859-1"), charset);
                                                    String pattern = "^(\\d+\\.\\d+\\.\\d+\\.\\d+)\\s\\-\\s\\-\\s(\\[[^\\[\\]]+\\])\\s(\\\"(?:[^\"]|\\\")+|-\\\")\\s(\\d{3})\\s(\\d+|-)\\s(\\\"(?:[^\"]|\\\")+|-\\\")\\s(\\\"(?:[^\"]|\\\")+|-\\\")\\s(\\\"(?:[^\"]|\\\")+|-\\\")";
                                                    Pattern r = Pattern.compile(pattern);
                                                    Matcher m = r.matcher(line);
                                                    String tr = "";
                                                    if (m.find()) {
                                                        if ("0".equals(request.getAttribute("onlyError")) && "200".equals(m.group(4)) || !"200".equals(m.group(4))) {
                                                            tr += "<tr";
                                                            if (!"200".equals(m.group(4))) {
                                                                tr += " class='am-danger' ";
                                                            }
                                                            tr += "";
                                                            tr += ">";
                                                            tr += "<td>";
                                                            tr += m.group(1);
                                                            tr += "</td>";
                                                            tr += "<td>";
                                                            tr += sdf.format(dateFormat.parse(m.group(2)));
                                                            tr += "</td>";
                                                            tr += "<td>";
                                                            tr += m.group(3);
                                                            tr += "</td>";
                                                            tr += "<td>";
                                                            tr += m.group(4);
                                                            tr += "</td>";
                                                            tr += "<td>";
                                                            tr += m.group(5);
                                                            tr += "</td>";
                                                            tr += "<td>";
                                                            tr += m.group(6);
                                                            tr += "</td>";
                                                            tr += "<td title='" + m.group(7) + "'>";
                                                            tr += m.group(7);
                                                            tr += "</td>";
                                                            tr += "</tr>";
                                                            out.print(tr);
                                                            count++;
                                                        }
                                                    }
                                                }
                                                nextend--;
                                            }
                                            nextend--;
                                            rf.seek(nextend);
                                            if (nextend == 0) {
                                                System.out.println(new String(rf.readLine().getBytes(
                                                        "ISO-8859-1"), charset));
                                            }
                                        }
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    } finally {
                                        try {
                                            if (rf != null)
                                                rf.close();
                                        } catch (IOException e) {
                                            e.printStackTrace();
                                        }
                                    }
                                %>
                                </tbody>
                            </table>
                        </div>
                    </c:if>
                    <c:if test="${active == 'about'}">
                        <h1>关于页</h1>
                    </c:if>
                </div>
            </div>
        </div>
    </div>
    <%-- 左边栏 --%>
    <div class=" am-u-md-1 am-u-md-pull-11 my-sidebar">
        <div class="am-offcanvas" id="sidebar">
            <div class="am-offcanvas-bar">
                <ul class="am-nav">
                    <li class="am-nav-header">NGINX</li>
                    <li class="${active == 'index' ? 'am-active' : ''}"><a href="?a=index&t=${token}">首页</a>
                    </li>
                    <li class="${active == 'nginxMonitor' ? 'am-active' : ''}"><a
                            href="?a=nginxMonitor&t=${token}">监控</a></li>
                    <li class="${active == 'nginxConfig' ? 'am-active' : ''}"><a
                            href="?a=nginxConfig&t=${token}">配置</a></li>
                    <li class="${active == 'nginxLogs' ? 'am-active' : ''}"><a href="?a=nginxLogs&t=${token}">日志</a>
                    </li>
                    <li class="${active == 'about' ? 'am-active' : ''}"><a href="?a=about&t=${token}">关于</a>
                    </li>
                </ul>
            </div>
        </div>
    </div>
    <a href="#sidebar" class="am-btn am-btn-sm am-btn-success am-icon-bars am-show-sm-only my-button"
       data-am-offcanvas>
        <span class="am-sr-only">侧栏导航</span>
    </a>
    <%-- 用七牛云免费的 AmazeUI https cdn --%>
    <script src="https://cdn.staticfile.org/jquery/2.2.4/jquery.min.js"></script>
    <script src="https://cdn.staticfile.org/amazeui/2.7.2/js/amazeui.min.js"></script>
    <script src="https://cdn.staticfile.org/highlight.js/9.15.6/highlight.min.js"></script>
    <script>
        <%-- 直接在jsp里写 js --%>
        $(function () {
            // 代码高亮初始化
            hljs.initHighlightingOnLoad();

        });

    </script>
</body>
</html>
