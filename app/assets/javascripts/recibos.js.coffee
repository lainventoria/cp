$(document)
  # FIXME por qué no está largando ajax:success???
  .on 'ajax:complete', '.agregar-movimiento', (xhr, cosas) ->
    $('#nuevo-movimiento').html(cosas.responseText)

    $("#selector_moneda_pago").on "change", ->
      if $("#selector_moneda_pago").val() is $("#selector_moneda").val()
        $("#movimiento_monto_aceptado").hide()
      else
        $("#movimiento_monto_aceptado").show()

    $("#causa_monto").on "keyup", ->
      if $("#selector_moneda_pago").val() is $("#selector_moneda").val()
        $("#causa_monto_aceptado").val($("#causa_monto").val())

    $("#selector_moneda_pago").trigger("change")

    # TODO Por alguna razón no bindea a los nuevos objetos
    $('input[data-role=money]').autoNumeric('init')
    $(':enabled .input-group.date').datepicker({
      format: "dd M yyyy",
      weekStart: 1,
      autoclose: true,
      language: "es",
      forceParse: false
    })
