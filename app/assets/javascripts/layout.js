function parse_float (s){
  return parseFloat (s.replace(/,/,'.'));
};

$(document).ready(function(){

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

});
