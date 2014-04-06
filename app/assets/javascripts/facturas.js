$(document).ready(function(){

  // calcula el total cuando se hace un cambio en IVA o importe neto
  $('.calcula_total').on('keyup', function() {
    importe_total = parseFloat($('#factura_importe_neto').autoNumeric('get')) + parseFloat($('#factura_iva').autoNumeric('get'));
    $('#factura_importe_total').autoNumeric('set', importe_total );
  });


  // Cuando cambie el nombre del tercero cuando actualicemos el cuit
  $('#factura_tercero_attributes_cuit').on('railsAutocomplete.select', function(event, data){
    $('#factura_tercero_attributes_nombre').val(data.item.nombre);
    $('#factura_tercero_msg').show().find('span').text('Tercero seleccionado: ' + data.item.nombre + ' [' + data.item.value + ']');
    $('#factura_tercero_id').val(data.item.id);
  });

  // Cuando cambie el cuit del tercero cuando actualicemos el nombre
  $('#factura_tercero_attributes_nombre').on('railsAutocomplete.select', function(event, data){
    $('#factura_tercero_attributes_cuit').val(data.item.cuit);
    $('#factura_tercero_msg').show().find('span').text('Tercero seleccionado: ' + data.item.value + ' [' + data.item.cuit + ']');
    $('#factura_tercero_id').val(data.item.id);
  });

  // Quitar tercero seleccionado
  $('#factura_tercero_clear').on('click',function(e){
    e.preventDefault();
    e.stopPropagation();
    $('#factura_tercero_msg').hide().find('span').text('');
    $('#factura_tercero_id').val('');
    $('#factura_tercero_attributes_cuit').val('');
    $('#factura_tercero_attributes_nombre').val('');

    return false;
  });



});
