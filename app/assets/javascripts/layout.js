$(document).ready(function(){

  $('input[data-role=money]').autoNumeric('init');

  // Inicializar los datepicker
  $('.input-group.date').datepicker({
    format: "dd M yyyy",
    weekStart: 1,
    autoclose: true,
    language: "es",
    forceParse: false
  });

  // Submite formularios al hacer click en id = btnGuardar
  $('#btnGuardar').on('click', function() {
    $('form').submit();
  });
  
  // al hacer click en un objeto con clase = 'ir-a'
  // redirige al path almacenado en data-uri
  // ej: se utiliza en listados para redirigir a vista detallada 
  $(document).on('click', '.ir-a', function(e) {
    if ( $(e.target).data('uri') ) {
      window.location.href = $(e.target).data('uri');
      return false;
    }
    if ( $(e.target.parentElement).data('uri') ) {
      window.location.href = $(e.target.parentElement).data('uri');
      return false;
    }
  });

  // actualiza campos con clase 'actualizar_moneda' con lo que se elija
  // en el selector incluido en el partial 'layouts/selector_moneda'
  $('#selector_moneda').on('change', function() {
    $('.actualizar_moneda').each( function() {
      this.value = $('#selector_moneda')[0].value;
    });
  });

  // inicializa los bootstrap-filestyle
  $("form :file").filestyle({
    buttonText: 'Adjuntar',
    classInput: 'filestyle form-control',
    classButton: 'filestyle btn btn-primary',
    classIcon: 'glyphicon glyphicon-paperclip',
    input: false
  });

});
