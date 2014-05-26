<table class="table table-striped">
    <thead>
    <th><g:message code="crmNote.text.label" default="What"/></th>
    <th><g:message code="crmNote.dateCreated.label" default="When"/></th>
    <th><g:message code="crmNote.username.label" default="Who"/></th>
    <th></th>
    </thead>
    <tbody>
    <g:each in="${list}" var="note" status="i">
        <tr>
            <td><a href="#" class="show-note" data-crm-id="${note.id}">${note.encodeAsHTML()}</a></td>
            <td><g:formatDate date="${note.lastUpdated ?: note.dateCreated}" type="date"/></td>
            <td><crm:user username="${note.username}">${name}</crm:user></td>
            <td>
                <crm:hasPermission permission="crmContent:edit">
                    <g:link action="deleteNote" id="${note.id}" onclick="return confirm('${message(code:'crmNote.button.delete.confirm.message', args:[note.toString()], default:'Are you sure you want to delete the note?')}')"><i class="icon-trash"></i></g:link>
                </crm:hasPermission>
            </td>
        </tr>
    </g:each>
    </tbody>
</table>

<crm:hasPermission permission="crmContent:edit">
        <div class="form-actions">
            <a class="btn btn-primary" href="#addNoteModal" data-toggle="modal">Lägg till notering</a>
        </div>
</crm:hasPermission>
