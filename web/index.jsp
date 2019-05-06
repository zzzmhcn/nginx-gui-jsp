<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.regex.Pattern" %>
<%@ page import="java.util.regex.Matcher" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    /**
     * 测试访问路径
     * http://localhost:8080/index.jsp?active=index&token=e10adc3949ba59abbe56e057f20f883e
     *
     * 参数
     * active 指页面，默认index
     * token 指默认密码的md5 (目前写死在jsp)
     *
     * 其他基本信息位置
     * request.setAttribute
     */
    String token = request.getParameter("token");
    String active = request.getParameter("active");
    if (!"e10adc3949ba59abbe56e057f20f883e".equalsIgnoreCase(token)) {
        // 防止被扫到 token 不正确直接404
        response.sendError(404);
        return;
    }
    active = active == null ? "index" : active;
    // 基本信息配置
    request.setAttribute("active", active);
    request.setAttribute("token", token);
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
    <link rel="icon" href="favicon.ico">
    <%-- 用七牛云免费的 AmazeUI https cdn --%>
    <link href="https://cdn.staticfile.org/amazeui/2.7.2/css/amazeui.min.css" rel="stylesheet">
    <link href="https://cdn.staticfile.org/highlight.js/9.15.6/styles/github.min.css" rel="stylesheet">
    <style>
        body {
            font: 14px/1.5 "Helvetica Neue", "Helvetica,Arial", "Microsoft Yahei", "Hiragino Sans GB", "HeitiSC", "WenQuanYi Micro Hei", sans-serif;
        }

        <%-- 直接在jsp里写 css --%>
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
                            <li><a href="/?active=index&token=${token}">控制台</a></li>
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
                        <div class="am-u-md-12">
                            <table class="am-table am-table-bordered am-table-radius am-table-striped">
                                <thead>
                                <tr>
                                    <th>网站名称</th>
                                    <th>网址</th>
                                    <th>创建时间</th>
                                </tr>
                                </thead>
                                <tbody>
                                <%
                                    // 读取配置文件
                                    BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(
                                            new FileInputStream(request.getAttribute("nginxLogPath") + "access.log"), "UTF-8"));
                                    String temp = null;
                                    while ((temp = bufferedReader.readLine()) != null) {
                                        try {
                                            String tr = "";
                                            String pattern = "([^ ]*) ([^ ]*) ([^ ]*) (\\[.*\\]) (\".*?\") (-|[0-9]*) (-|[0-9]*) (\".*?\") (\".*?\")";
                                            Pattern r = Pattern.compile(pattern);
                                            Matcher m = r.matcher(temp);
                                            tr += "<tr>";
                                            for (int i = 1; i < 10; i++) {
                                                tr += "<td>";
                                                m.group(i);
                                                tr +=  "</td>";
                                            }
                                            tr += "</tr>";
                                            out.print(tr);
                                        } catch (Exception e) {
                                            System.out.println(e.getLocalizedMessage());
                                        }
                                    }
                                    // 解析比较累 考虑到文件过大，可能存在性能问题

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
                    <li class="${active == 'index' ? 'am-active' : ''}"><a href="?active=index&token=${token}">首页</a>
                    </li>
                    <li class="${active == 'nginxMonitor' ? 'am-active' : ''}"><a
                            href="?active=nginxMonitor&token=${token}">监控</a></li>
                    <li class="${active == 'nginxConfig' ? 'am-active' : ''}"><a
                            href="?active=nginxConfig&token=${token}">配置</a></li>
                    <li class="${active == 'nginxLogs' ? 'am-active' : ''}"><a href="?active=nginxLogs&token=${token}">日志</a>
                    </li>
                    <li class="${active == 'about' ? 'am-active' : ''}"><a href="?active=about&token=${token}">关于</a>
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
