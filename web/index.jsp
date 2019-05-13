<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.regex.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.net.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setBundle basename="config" var="config" scope="request"/>
<fmt:message key="md5Token" var="md5Token" bundle="${config}" scope="request"/>
<fmt:message key="baseLogPath" var="baseLogPath" bundle="${config}" scope="request"/>
<fmt:message key="nginxLogPath" var="nginxLogPath" bundle="${config}" scope="request"/>
<fmt:message key="nginxErrorLogPath" var="nginxErrorLogPath" bundle="${config}" scope="request"/>
<fmt:message key="nginxConfigPath" var="nginxConfigPath" bundle="${config}" scope="request"/>
<fmt:message key="nginxBlocksIpPath" var="nginxBlocksIpPath" bundle="${config}" scope="request"/>
<fmt:message key="nginxStatusUrl" var="nginxStatusUrl" bundle="${config}" scope="request"/>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    // 密码 MD5 格式
    String token = request.getParameter("t");
    // 发现没带token参数 弹出请输入密码 再JS跳转回来
    if (token == null) {
        out.print("<script src='https://cdn.staticfile.org/blueimp-md5/2.10.0/js/md5.min.js'></script>");
        out.print("<script>" +
                "var p = prompt('Plese enter your password');" +
                "if (p)" +
                "window.location.href='?t=' + md5(p)" +
                "</script>");
        return;
    }
    // 密码校验与配置文件对比 WEB-INF/classes/config.properties
    if (!String.valueOf(request.getAttribute("md5Token")).equalsIgnoreCase(token)) {
        // 密码错误送回第一步重输
        response.sendRedirect("/");
        return;
    }
    // 所在页面 默认index
    String active = request.getParameter("a");
    // 日志最大行数 默认200
    String maxLine = request.getParameter("m");
    active = active == null ? "index" : active;
    maxLine = maxLine == null ? "200" : maxLine;
    // 存入attr
    request.setAttribute("active", active);
    request.setAttribute("token", token);
    request.setAttribute("maxLine", maxLine);
    // 获取基本系统信息
    Properties props = System.getProperties();
    // Shell 命令
    String[] nginx_version = {"nginx", "-v"};
    String[] nginx_log_size = {"du", "-sh", String.valueOf(request.getAttribute("baseLogPath"))};
    // awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -nr -k1 | head -n 10
    String[] top10ip = {"awk", "'{print $1}'", String.valueOf(request.getAttribute("nginxLogPath"))
            , "|", "sort", "|", "uniq", "-c", "|", "sort", "-nr", "-k1", "|", "head", "-n", "10"};
%>
<%!
    /**
     * Java 执行shell命令方法
     * 传入参数例子
     * String[] command = {"java","-version"}
     * String[] command = {"ssh","127.0.0.1","ps","-ef","|","grep","java"};
     */
    public String shell(String[] command) {
        String result = "";
        try {
            ProcessBuilder pb = new ProcessBuilder();
            pb.command(command);
            pb.redirectErrorStream(true);
            Process process = pb.start();
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            while (true) {
                String line = reader.readLine();
                if (line == null) {
                    break;
                }
                result += line + "<br>";
            }
            process.destroy();
            reader.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public String getLineNum(String filePath) {
        String[] command = {"wc", "-l", filePath};
        return shell(command).replace(filePath, "").trim();
    }

    /**
     * Java 请求Url 简易版本
     * 用于请求nginx status
     */
    public String httpGet(String url) {
        String result = "";
        try {
            URL realUrl = new URL(url);
            URLConnection connection = realUrl.openConnection();
            connection.connect();
            BufferedReader in = new BufferedReader(new InputStreamReader(
                    connection.getInputStream()));
            String line;
            while ((line = in.readLine()) != null) {
                result += line + "<br>";
            }
            in.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public String getStatusNum(String nginxStatusUrl, int num) {
        String line = httpGet(nginxStatusUrl);
        return line == null || "".equals(line) ? "" : num == 0 ? line.substring(line.indexOf("connections:") + "connections:".length(), line.indexOf("server")).trim()
                : line.substring(line.indexOf("Waiting:") + "Waiting:".length()).trim();
    }
%>
<html lang="zh-CN">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Nginx 控制台</title>
    <link rel="icon" type="image/jpeg"
          href="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAAQABADASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwDtNXvNd8WSa5ZWV7HZQ6fKIEt14a6JLDBfPBO3gdDmqfhjW9a0SDQo7i5+02upXD232edSHt9rheG69+h9KPFGia1o0OuSW9t9ptdRuUuhcwMQ9uVYtyvXv1HpVrSrTXfF02h313Yx2UGnymZ7huDdElSSExwTt5PTn8K4/e5ut/8Ag/5HhfvPbdef52+L7tvl8z//2Q==">
    <%-- 七牛云公共 cdn --%>
    <link href="https://cdn.staticfile.org/amazeui/2.7.2/css/amazeui.min.css" rel="stylesheet">
    <link href="https://cdn.staticfile.org/highlight.js/9.15.6/styles/github.min.css" rel="stylesheet">
    <style>
        <%-- 全局css --%>
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
            margin-bottom: 0px;
        }
    </style>
</head>
<body>
<div class="am-g">
    <%-- 中间部分 --%>
    <div class="am-u-md-11 am-u-md-push-1">
        <div class="am-g">
            <div class="am-u-sm-12 am-u-sm-centered am-animation-fade am-animation-delay-1">
                <div class="am-cf am-article">
                    <div class="am-u-md-12">
                        <ol class="am-breadcrumb">
                            <li><a href="/?a=index&t=${token}">控制台</a></li>
                            <li class="am-active">
                                <c:if test="${active == 'index'}">首页</c:if>
                                <c:if test="${active == 'nginxConfig'}">配置</c:if>
                                <c:if test="${active == 'nginxLogs'}">日志</c:if>
                            </li>
                        </ol>
                    </div>
                    <c:if test="${active == 'index'}">
                        <div class="am-u-md-6">
                            <div class="am-panel am-panel-secondary">
                                <div class="am-panel-hd">基本信息</div>
                                <table class="am-table">
                                    <tbody>
                                    <tr>
                                        <td class="am-u-md-4">操作系统</td>
                                        <td class="am-u-md-8"><%=props.getProperty("os.name")%>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="am-u-md-4">Java 版本</td>
                                        <td class="am-u-md-8"><%=props.getProperty("java.version")%>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="am-u-md-4">Nginx 版本</td>
                                        <td class="am-u-md-8"><%=shell(nginx_version).replace("nginx version:", "").trim()%>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="am-u-md-4">Nginx 日志总量</td>
                                        <td class="am-u-md-8"><%=shell(nginx_log_size)
                                                .replace(String.valueOf(request.getAttribute("baseLogPath")), "").trim()%>
                                        </td>
                                    </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <div class="am-u-md-6">
                            <div class="am-panel am-panel-secondary">
                                <div class="am-panel-hd">实时数据</div>
                                <div class="am-panel-bd">
                                    TCP连接数：<%=getStatusNum(String.valueOf(request.getAttribute("nginxStatusUrl")), 0)%>
                                    等待连接数：<%=getStatusNum(String.valueOf(request.getAttribute("nginxStatusUrl")), 1)%>
                                </div>
                            </div>
                        </div>
                        <div class="am-u-md-6">
                            <div class="am-panel am-panel-secondary">
                                <div class="am-panel-hd">当日前十IP</div>
                                <div class="am-panel-bd">
                                    <%=shell(top10ip)%>
                                </div>
                            </div>
                        </div>
                        <div class="am-u-md-6">
                            <div class="am-panel am-panel-secondary">
                                <div class="am-panel-hd">今日汇总</div>
                                <div class="am-panel-bd">
                                    访问次数：<%=getLineNum(String.valueOf(request.getAttribute("nginxLogPath")))%>
                                    异常次数：<%=getLineNum(String.valueOf(request.getAttribute("nginxErrorLogPath")))%>
                                </div>
                            </div>
                        </div>

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
                            <button type="button" class="am-btn am-btn-success am-btn-xs" onclick="{
                                    // 调用service.jsp实现 把配置信息转base64回传到本页面
                                    if(confirm('修改Nginx配置有可能造成系统异常\n点击确认后操作不可逆\n是否确认？')){
                                    var nc = window.btoa(window.encodeURIComponent($('#nginx-config').text()));
                                    jQuery.post('service.jsp',{t:'${token}',m:'saveNc',nc:nc},function(res){
                                    alert(res);
                                    location.reload();
                                    });
                                    }
                                    }">保存
                            </button>
                            <button type="button" class="am-btn am-btn-warning am-btn-xs" onclick="{
                                // 调用service.jsp实现 通过java调用shell nginx -t 再通过解析弹出效果提示
                                alert('抱歉，测试版本不开放此功能');
                            }">校验
                            </button>
                            <button type="button" class="am-btn am-btn-secondary am-btn-xs" onclick="{
                                // 调用service.jsp实现 通过java调用shell nginx -s reload
                                alert('抱歉，测试版本不开放此功能');
                            }">生效
                            </button>
                            <span class="am-fr">参考文档: <a href="https://cloud.tencent.com/developer/doc/1158"
                                                         target="_blank">https://cloud.tencent.com/developer/doc/1158</a></span>
                        </div>
                        <div class="am-u-md-12">
                            <pre id="nginx-config" class=""><code class="nginx"><%
                                // 若配置文件存在编码问题，在此处修改UTF-8为指定编码再试
                                BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(
                                        new FileInputStream(String.valueOf(request.getAttribute("nginxConfigPath"))), "UTF-8"));
                                String temp = null;
                                while ((temp = bufferedReader.readLine()) != null) {
                                    out.print(temp + "\n");
                                }
                            %></code></pre>
                        </div>
                    </c:if>
                    <c:if test="${active == 'nginxLogs'}">
                        <div class="am-u-md-12" style="margin-bottom: 6px;">
                                <%-- 这里开太高会导致内存溢出等问题 --%>
                            <label>显示条数：</label>
                            <select id="maxLine" data-am-selected="{btnSize: 'xs'}">
                                <option value="200" ${maxLine == 200 ? 'selected': ''}>200</option>
                                <option value="500" ${maxLine == 500 ? 'selected': ''}>500</option>
                                <option value="1000" ${maxLine == 1000 ? 'selected': ''}>1000</option>
                            </select>
                            <button type="button" class="am-btn am-btn-secondary am-btn-xs"
                                    onclick="{
                                            window.location.href = 'index.jsp?a=nginxLogs&t=${token}'
                                            + '&m=' + $('#maxLine').val()
                                            + '&s=' + $('#status').val();
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
                                    <th>位置</th>
                                    <th>UA</th>
                                </tr>
                                </thead>
                                <tbody>
                                <%
                                    String filename = String.valueOf(request.getAttribute("nginxLogPath"));
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
                                        String pattern = "^(\\d+\\.\\d+\\.\\d+\\.\\d+)\\s\\-\\s\\-\\s(\\[[^\\[\\]]+\\])\\s(\\\"(?:[^\"]|\\\")+|-\\\")\\s(\\d{3})\\s(\\d+|-)\\s(\\\"(?:[^\"]|\\\")+|-\\\")\\s(\\\"(?:[^\"]|\\\")+|-\\\")\\s(\\\"(?:[^\"]|\\\")+|-\\\")";
                                        Pattern r = null;
                                        Matcher m = null;
                                        String tr = null;
                                        while (nextend > start && count <= Integer.parseInt(maxLine)) {
                                            c = rf.read();
                                            if (c == '\n' || c == '\r') {
                                                line = rf.readLine();
                                                if (line != null) {
                                                    line = new String(line.getBytes("ISO-8859-1"), charset);
                                                    r = Pattern.compile(pattern);
                                                    m = r.matcher(line);
                                                    tr = "";
                                                    count++;
                                                    if (m.find()) {
                                                        tr += "<tr";
                                                        if ("304".equals(m.group(4))) {
                                                            tr += " class='am-active' ";
                                                        } else if (!"200".equals(m.group(4))) {
                                                            tr += " class='am-danger' ";
                                                        }
                                                        tr += ">";
                                                        tr += "<td>" + m.group(1) + "</td>";
                                                        tr += "<td>" + sdf.format(dateFormat.parse(m.group(2))) + "</td>";
                                                        tr += "<td>" + m.group(3) + "</td>";
                                                        tr += "<td>" + m.group(4) + "</td>";
                                                        tr += "<td>" + m.group(5) + "</td>";
                                                        tr += "<td>" + m.group(6) + "</td>";
                                                        tr += "<td title='" + m.group(7) + "'>" + m.group(7) + "</td>";
                                                        tr += "</tr>";
                                                        out.print(tr);
                                                    }
                                                }
                                                nextend--;
                                            }
                                            nextend--;
                                            rf.seek(nextend);
                                        }
                                        rf.close();
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    }
                                %>
                                </tbody>
                            </table>
                        </div>
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
                    <li class="${active == 'nginxConfig' ? 'am-active' : ''}"><a
                            href="?a=nginxConfig&t=${token}">配置</a></li>
                    <li class="${active == 'nginxLogs' ? 'am-active' : ''}"><a href="?a=nginxLogs&t=${token}">日志</a>
                    </li>
                </ul>
            </div>
        </div>
    </div>
    <a href="#sidebar" class="am-btn am-btn-sm am-btn-success am-icon-bars am-show-sm-only my-button"
       data-am-offcanvas>
        <span class="am-sr-only">导航</span>
    </a>
    <%-- 七牛云公共 cdn --%>
    <script src="https://cdn.staticfile.org/jquery/2.2.4/jquery.min.js"></script>
    <script src="https://cdn.staticfile.org/amazeui/2.7.2/js/amazeui.min.js"></script>
    <script src="https://cdn.staticfile.org/highlight.js/9.15.6/highlight.min.js"></script>
    <script src="https://cdn.staticfile.org/Base64/1.0.2/base64.min.js"></script>
    <script>
        <%-- 全局js --%>
        // 顶部加载条
        $.AMUI.progress.start();
        window.onload = function () {
            $.AMUI.progress.done();
        }
        $(function () {
            // 代码高亮初始化
            hljs.initHighlightingOnLoad();
        });
    </script>
</body>
</html>