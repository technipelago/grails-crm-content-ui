CKEDITOR.editorConfig = function (config) {
    config.width = '98.3%';
    config.height = '400px';
    config.resize_enabled = true;
    config.startupFocus = true;
    config.toolbar = [
        ['Bold', 'Italic', 'Underline', 'Strike'], ['TextColor', 'BGColor'], ['RemoveFormat'],
        ['Styles', 'Format', 'Font', 'FontSize'],
        '/',
        ['Paste', 'PasteText', 'PasteFromWord'],
        ['JustifyLeft', 'JustifyCenter', 'JustifyRight'],
        ['NumberedList', 'BulletedList', '-', 'Outdent', 'Indent'],
        ['Image', 'Link', 'Unlink'],
        ['Table', 'HorizontalRule'],
        ['Templates'],
        ['Undo', 'Redo'],
        ['Source']
    ];
    config.allowedContent = true;
    config.basicEntities = false;
    config.protectedSource = [/\[@link\s+[\s\S]*?\[\/@link\]/g, /\[#[\s\S]*?\]/g];
    config.extraPlugins = 'fakeobjects,showprotected,templates';
    config.templates_files = [
        '../../crmContent/templates.js'
    ];
    config.templates = 'crm';
    config.templates_replaceContent = false;
};

CKEDITOR.plugins.addExternal('fakeobjects', '../../../crm-content-ui-2.4.5/js/ckeditor/plugins/fakeobjects/');
CKEDITOR.plugins.addExternal('showprotected', '../../../crm-content-ui-2.4.5/js/ckeditor/plugins/showprotected/');
CKEDITOR.plugins.addExternal('templates', '../../../crm-content-ui-2.4.5/js/ckeditor/plugins/templates/');
