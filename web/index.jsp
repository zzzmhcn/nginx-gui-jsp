<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // jsp 获取url参数token做最简单的登录权限控制 例如用 123456的MD5 e10adc3949ba59abbe56e057f20f883e
    if (!"e10adc3949ba59abbe56e057f20f883e".equalsIgnoreCase(request.getParameter("token"))) {
        out.print("{'msg':'error','code':'403'}");
        return;
    }
    // 基本信息配置
    request.setAttribute("logPath","C:\\Users\\Administrator\\Documents\\nginx\\logs\\");
    request.setAttribute("configPath","C:\\Users\\Administrator\\Documents\\nginx\\conf\\");
%>
<html lang="zh-CN">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Nginx 监控管理系统</title>
    <link rel="icon" type="image/png"
          href="data:image/png;base64,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">
    <%-- 用七牛云免费的 AmazeUI https cdn --%>
    <link href="https://cdn.staticfile.org/amazeui/2.7.2/css/amazeui.min.css" rel="stylesheet">
    <style>
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
    </style>
</head>
<body>


<div class="am-g">
    <div class="am-u-md-11 am-u-md-push-1">
        <div class="am-g">
            <div class="am-u-sm-11 am-u-sm-centered">
                <div class="am-cf am-article">
                    展示部分
                </div>
            </div>
        </div>
    </div>
    <div class="am-u-md-1 am-u-md-pull-11 my-sidebar">
        <div class="am-offcanvas" id="sidebar">
            <div class="am-offcanvas-bar">
                <ul class="am-nav">
                    <li class="am-nav-header">NGINX</li>
                    <li><a href="#">首页</a></li>
                    <li><a href="#">配置</a></li>
                    <li><a href="#">日志</a></li>
                </ul>
            </div>
        </div>
    </div>
    <a href="#sidebar" class="am-btn am-btn-sm am-btn-success am-icon-bars am-show-sm-only my-button" data-am-offcanvas><span
            class="am-sr-only">侧栏导航</span></a>
    <%-- 用七牛云免费的 AmazeUI https cdn --%>
    <script src="https://cdn.staticfile.org/jquery/2.2.4/jquery.min.js"></script>
    <script src="https://cdn.staticfile.org/amazeui/2.7.2/js/amazeui.min.js"></script>
    <script>
        <%-- 直接在jsp里写 js --%>
    </script>
</body>
</html>
