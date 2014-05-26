<%@ page defaultCodec="html" %>
<div class="modal hide fade" id="deleteModal">

    <g:form class="form-horizontal" action="${action ?: 'delete'}">
        <g:hiddenField name="id" id="delete-modal-crm-id" value="${id}"/>
        <div class="modal-header">
            <a class="close" data-dismiss="modal">×</a>

            <h3><g:message code="default.delete.title" default="Confirm Delete"/></h3>
        </div>

        <div class="modal-body">
            <p>${message(code: 'default.button.delete.confirm.message')}</p>
        </div>

        <div class="modal-footer">
            <crm:button action="${action ?: 'delete'}" visual="danger" icon="icon-trash icon-white"
                        label="default.button.delete.label"/>
            <a href="#" class="btn" data-dismiss="modal"><i class="icon-remove"></i> <g:message
                    code="default.button.cancel.label" default="Cancel"/></a>
        </div>

    </g:form>
</div>
