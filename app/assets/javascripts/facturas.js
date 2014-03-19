$(document).ready(function(){

// cuando se hace un cambio en IVA o importe neto, calcular el importe
// bruto
  $('#factura_importe_neto').on('keyup', function() {
    $('#factura_importe_total')[0].value = parse_float($('#factura_importe_neto')[0].value) + parse_float($('#factura_iva')[0].value);
  });

  $('#factura_iva').on('keyup', function() {
    $('#factura_importe_total')[0].value = parse_float($('#factura_importe_neto')[0].value) + parse_float($('#factura_iva')[0].value);
  });

  $('#factura_tercero_id').on('update', function() {
    for each ( lista in $('#factura_tercero_id') ) {
      lista.value = 1;
    }
  });

});
