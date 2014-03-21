$(document).ready(function(){

  // calcula el total cuando se hace un cambio en IVA o importe neto
  $('.calcula_total').on('keyup', function() {
    importe_total = parseFloat($('#factura_importe_neto').autoNumeric('get')) + parseFloat($('#factura_iva').autoNumeric('get'));
    $('#factura_importe_total').autoNumeric('set', importe_total );
  });

});
