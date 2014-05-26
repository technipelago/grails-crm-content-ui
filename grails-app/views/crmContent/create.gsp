<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <title><g:message code="crmContent.create.title" args="${[reference]}"/></title>
    <% if (contentType == 'text/html') { %>
    <ckeditor:resources/>
    <r:script>
        $(document).ready(function () {
            var editor = CKEDITOR.replace('content',
                    {
                        width: '98.3%',
                        height: '480px',
                        resize_enabled: true,
                        startupFocus: true,
                        skin: 'kama',
                        toolbar: [
                            ['Styles', 'Format', 'Font', 'FontSize'],
                            ['Source'],
                            '/',
                            ['Bold', 'Italic', 'Underline', 'Strike', 'TextColor', 'BGColor', 'RemoveFormat'],
                            ['Paste', 'PasteText', 'PasteFromWord'],
                            ['JustifyLeft', 'JustifyCenter', 'JustifyRight'],
                            ['NumberedList', 'BulletedList', '-', 'Outdent', 'Indent'],
                            ['Link', 'Unlink'], /* Image upload is not available until document is created */
                            ['Table', 'HorizontalRule']
                        ],
                        basicEntities: false,
                        protectedSource: [/\[@link\s+[\s\S]*?\[\/@link\]/g, /\[#[\s\S]*?\]/g],
                        baseHref: "${createLink(controller:'static')}"
                    });
        });
    </r:script>
    <% } %>
</head>

<body>

<crm:header title="crmContent.create.title" subtitle="${reference?.encodeAsHTML()}" args="${[reference]}"/>

<g:form action="create">

    <g:hiddenField name="ref" value="${ref}"/>
    <g:hiddenField name="referer" value="${referer}"/>
    <g:hiddenField name="contentType" value="${contentType}"/>

    <div class="row-fluid">
        <g:textArea id="content" name="text" cols="70" rows="18" class="span12" value="${text}"/>
    </div>

    <div class="form-actions">
        <crm:button visual="success" icon="icon-ok icon-white" label="crmContent.button.save.label"/>
        <g:textField name="name" required="" class="input-large" placeholder="Filnamn" style="margin-top: 9px;margin-left:5px;"/>
    </div>
</g:form>
</body>
</html>