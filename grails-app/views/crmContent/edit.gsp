<%@ page import="grails.plugins.crm.content.CrmResourceRef" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmResourceRef.label', default: 'Content')}"/>
    <g:set var="metadata" value="${crmResourceRef.metadata}"/>
    <title><g:message code="crmResourceRef.edit.title" args="[entityName, crmResourceRef]"/></title>
    <r:require module="select2"/>
    <% if (metadata.contentType == 'text/html') { %>
    <ckeditor:resources/>
    <r:script>
        function updateAndStay(elem) {
            var $form = $(elem).closest('form');
            if($form) {
                $('input[name="stay"]', $form).val("true");
                $('button[name="_action_edit"]', $form).click();
            }
            return false;
        }

        $(document).ready(function () {
            var stylesheet = ["${resource(dir: 'less', file: 'bootstrap.less.css', plugin: 'twitter-bootstrap')}",
            "${resource(dir: 'less', file: 'crm-ui-bootstrap.less.css', plugin: 'crm-ui-bootstrap')}",
            "${resource(dir: 'less', file: 'responsive.less.css', plugin: 'twitter-bootstrap')}"];
            <% if (css) { %>
            stylesheet.push("${resource(css)}");
            <% } %>
            var editor = CKEDITOR.replace('content',
            {
                customConfig: "${resource(dir: 'js', file: 'crm-ckeditor-config.js', plugin: 'crm-content-ui')}",
                stylesSet: "crm-web-styles:${resource(dir: 'js', file: 'crm-ckeditor-styles.js', plugin: 'crm-content-ui')}",
                baseHref: "${createLink(controller: 'static')}",
                contentsCss: stylesheet,
                filebrowserBrowseUrl: "${createLink(controller: 'crmContent', action: 'browse', params: [reference: 'crmResourceRef@' + crmResourceRef.ident()])}",
                filebrowserUploadUrl: "${createLink(controller: 'crmContent', action: 'upload')}",
                filebrowserImageBrowseUrl: "${createLink(controller: 'crmContent', action: 'browse', params: [pattern: 'image', reference: 'crmResourceRef@' + crmResourceRef.ident()])}",
                filebrowserImageUploadUrl: "${createLink(controller: 'crmContent', action: 'upload')}"
            });
        });
    </r:script>
    <% } %>
    <r:script>
        $(document).ready(function() {
            $.ajax({
                cache: false,
                url: "${createLink(controller: 'crmTag', action: 'autocomplete', params: [entity: CrmResourceRef.name])}",
                dataType: "json",
                success: function(tags) {
                    $("#inputTags").select2({
                        tags: tags,
                        tokenSeparators: [",", " "]
                    });
                }
            });
        });
    </r:script>
</head>

<body>

<crm:header title="crmResourceRef.edit.title" subtitle="${crmResourceRef.reference?.encodeAsHTML()}"
            args="[entityName, crmResourceRef.title]"/>

<g:if test="${crmResourceRef.shared}">
    <div class="alert alert-error">
        <h4><g:message code="crmResourceRef.shared.title"/></h4>
        <g:set var="resourceURL" value="${crm.createResourceLink(resource: crmResourceRef)}"/>
        <a href="${resourceURL}" target="_blank">${resourceURL}</a>
    </div>
</g:if>

<g:hasErrors bean="${crmResourceRef}">
    <crm:alert class="alert-error">
        <ul>
            <g:eachError bean="${crmResourceRef}" var="error">
                <li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message
                        error="${error}"/></li>
            </g:eachError>
        </ul>
    </crm:alert>
</g:hasErrors>

<g:uploadForm>
    <g:hiddenField name="id" value="${crmResourceRef.id}"/>
    <g:hiddenField name="version" value="${crmResourceRef?.version}"/>
    <g:hiddenField name="referer" value="${params.referer}"/>

    <div class="tabbable">
        <ul class="nav nav-tabs">
            <li class="active"><a href="#main" data-toggle="tab"><g:message code="crmContent.tab.main.label"
                                                                            default="Preview"/></a></li>
            <li><a href="#misc" data-toggle="tab"><g:message code="crmContent.tab.misc.label" default="Settings"/></a>
            </li>
        </ul>

        <div class="tab-content">
            <div class="tab-pane active" id="main">

                <div class="row-fluid">

                    <g:if test="${metadata.contentType.startsWith('text')}">
                        <g:textArea id="content" name="text" cols="70" rows="18" class="span11"
                                    value="${crmResourceRef.text}"/>
                    </g:if>
                    <g:else>
                        <iframe id="preview"
                                src="${g.createLink(action: 'open', params: [id: crmResourceRef.id, preview: true])}"
                                width="99%"
                                height="500">
                        </iframe>
                    </g:else>
                </div>
            </div>

            <div class="tab-pane" id="misc">

                <div class="row-fluid">
                    <f:with bean="crmResourceRef">

                        <div class="span4">

                            <f:field property="title" input-autofocus="" input-class="span12"
                                     input-placeholder="${message(code: 'crmResourceRef.title.placeholder', default: '')}"/>
                            <f:field property="name" input-class="span12"
                                     input-placeholder="${message(code: 'crmResourceRef.name.placeholder', default: '')}"/>
                            <g:if test="${crmResourceFolder}">
                                <f:field property="ref" label="crmResourceFolder.label">
                                    <g:select from="${folders}" name="ref" class="span12"
                                              keys="${folders.collect { 'crmResourceFolder@' + it.id }}"
                                              value="${crmResourceRef.ref}" optionValue="${{ it.path.join('/') }}"/>
                                </f:field>
                            </g:if>
                        </div>

                        <div class="span4">
                            <f:field property="status">
                                <g:select name="status"
                                          from="${grails.plugins.crm.content.CrmResourceRef.STATUS_TEXTS.keySet()}"
                                          value="${crmResourceRef.statusText}"
                                          valueMessagePrefix="crmResourceRef.status"/>
                            </f:field>
                            <div class="control-group">
                                <label class="control-label"><g:message code="crmContent.contentType.label"
                                                                        default="Content Type"/></label>

                                <div class="controls">
                                    <g:textField name="contentType" value="${metadata.contentType}" maxlength="100"
                                                 class="span12"
                                                 placeholder="${message(code: 'crmContent.contentType.placeholder', default: '')}"/>
                                </div>
                            </div>

                            <div class="control-group">
                                <label class="control-label"><g:message code="crmContent.button.upload.label"
                                                                        default="Upload file"/></label>

                                <div class="controls">
                                    <input type="file" name="file"/>
                                </div>
                            </div>
                        </div>

                        <div class="span4">
                            <f:field property="description" input-class="span12" input-rows="4"
                                     input-placeholder="${message(code: 'crmResourceRef.description.placeholder', default: '')}"/>

                            <div class="control-group">
                                <label for="inputTags" class="control-label"><g:message code="crmTag.list.label" default="Tags"/></label>
                                <div class="controls">
                                    <input type="hidden" id="inputTags" name="tags" value="${crmResourceRef.getTagValue()?.join(',')}" class="input-large">
                                </div>
                            </div>
                        </div>
                    </f:with>
                </div>
            </div>
        </div>
    </div>

    <div class="form-actions">
        <input type="hidden" name="stay" value=""/>
        <crm:button group="true" action="edit" visual="warning" icon="icon-ok icon-white"
                    label="crmContent.button.update.label">
            <button class="btn btn-warning dropdown-toggle" data-toggle="dropdown">
                <span class="caret"></span>
            </button>
            <ul class="dropdown-menu">
                <li>
                    <a href="#" onclick="return updateAndStay(this);"><g:message
                            code="crmContent.button.update.stay.label" default="Push Changes"/></a>
                </li>
            </ul>
        </crm:button>

        <crm:button action="delete" visual="danger" icon="icon-trash icon-white"
                    label="crmContent.button.delete.label"
                    confirm="crmContent.button.delete.confirm.message"
                    permission="crmContent:delete"/>
        <g:if test="${params.referer}">
            <crm:button type="url" href="${params.referer}" label="crmContent.button.back.label" icon="icon-remove"/>
        </g:if>
        <g:else>
            <crm:button type="link" controller="crmContent" action="show" id="${crmResourceRef.ident()}"
                        label="crmContent.button.back.label" icon="icon-remove" title="${crmResourceRef.toString()}"/>
        </g:else>
    </div>

</g:uploadForm>

</body>
</html>
