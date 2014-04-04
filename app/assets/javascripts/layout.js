$(document).ready(function(){

  $('input[data-role=money]').autoNumeric('init');

  // Inicializar los datepicker
  $(':enabled .input-group.date').datepicker({
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

  // ejecuta acciones despues de seleccionar una moneda (1)
  // actualiza campos con clase 'actualizar_moneda' con lo que se elija
  $('#selector_moneda').on('change', function() {
    $('.actualizar_moneda').each( function() {
      this.value = $('#selector_moneda')[0].value;
    });
  });

  // ejecuta acciones despues de seleccionar una moneda (2)
  // cambia el css (afecta al formulario de medios de pago)
  $("*[name='causa[monto_moneda]']").on('change', function() {
    if ( $("*[name='causa[monto_moneda]']")[0].value == $('#causa_monto_aceptado_moneda')[0].value ) {
      $('#movimiento_monto')[0].className = $('#movimiento_monto')[0].className.replace('col-md-2','col-md-4');
      $('#movimiento_monto_aceptado')[0].className = $('#movimiento_monto_aceptado')[0].className.replace('col-md-2','hidden');
    } else {
      $('#movimiento_monto')[0].className = $('#movimiento_monto')[0].className.replace('col-md-4','col-md-2');
      $('#movimiento_monto_aceptado')[0].className = $('#movimiento_monto_aceptado')[0].className.replace('hidden','col-md-2');
    }
  });

  // inicializa los bootstrap-filestyle
  $("form :file").filestyle({
    buttonText: 'Adjuntar',
    classInput: 'filestyle form-control',
    classButton: 'filestyle btn btn-primary',
    classIcon: 'glyphicon glyphicon-paperclip',
  });

});
