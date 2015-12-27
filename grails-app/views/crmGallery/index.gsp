<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.crm.content.cms.layout ?: 'main'}"/>
    <title><g:message code="crmContent.photo.gallery.title" default="Gallery - {0}" args="${[bean]}"/></title>
    <r:require module="gallery"/>
    <r:script>
        document.getElementById('links').onclick = function (event) {
            event = event || window.event;
            var target = event.target || event.srcElement,
                    link = target.src ? target.parentNode : target,
                    options = {index: link, event: event},
                    links = this.getElementsByTagName('a');
            blueimp.Gallery(links, options);
        };
    </r:script>
    <style type="text/css">
    #links img {
        margin-bottom: 4px;
    }
    </style>
</head>

<body>
<div class="crm-gallery">
    <div class="row-fluid">
        <div class="span10 offset1">
            <h1><g:message code="crmContent.photo.gallery.title" default="Gallery - {0}" args="${[bean]}"/></h1>

            <div id="links" class="row-fluid">
                <g:each in="${result}" var="photo">
                    <crm:resourceLink resource="${photo}" title="${photo.title}">
                        <crm:image resource="${photo}" width="160" height="120" alt="${photo.title}"/>
                    </crm:resourceLink>
                </g:each>
            </div>
        </div>
    </div>

    <div id="blueimp-gallery" class="blueimp-gallery blueimp-gallery-controls">
        <div class="slides"></div>

        <h3 class="title"></h3>
        <a class="prev">‹</a>
        <a class="next">›</a>
        <a class="close">×</a>
        <a class="play-pause"></a>
        <ol class="indicator"></ol>
    </div>
</div>
</body>
</html>