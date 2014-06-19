CKEDITOR.editorConfig = function( config ) {
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
        ['Undo', 'Redo'],
        ['Source']
    ];
    config.basicEntities = false;
    config.protectedSource = [/\[@link\s+[\s\S]*?\[\/@link\]/g, /\[#[\s\S]*?\]/g];
};