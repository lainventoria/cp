# encoding: utf-8
class FacturasController < ApplicationController
  before_action :set_obra
  before_action :set_factura, only: [:show, :edit, :update, :destroy]
  before_action :set_tercero, only: [:create, :update]
  before_action :set_order, [:cobros, :pagos]

  autocomplete :tercero, :nombre, :extra_data => [:cuit]
  autocomplete :tercero, :cuit, :extra_data => [:nombre]

  def index
    @facturas = @obra ? @obra.facturas : Factura.all
    @facturas = params[:saldadas].present? ? @facturas.saldadas : @facturas.por_saldar
  end

  # Solo mostrar facturas para cobrar reciclando la vista de lista
  def cobros
    @facturas = (@obra ? @obra.facturas : Factura).joins(:tercero).where(situacion: 'cobro').order(@order)
    @facturas = params[:saldadas].present? ? @facturas.saldadas : @facturas.por_saldar
    @situacion = "cobro"
    render "index"
  end

  def pagos
    @facturas = (@obra ? @obra.facturas : Factura).joins(:tercero).where(situacion: 'pago').order(@order)
    @facturas = params[:saldadas].present? ? @facturas.saldadas : @facturas.por_saldar
    @situacion = "pago"
    render "index"
  end

  def show
    @editar = false
  end

  def new
    @editar = true
    @factura = Factura.new
    @factura.tercero = Tercero.new
  end

  def edit
    @editar = true
  end

  def create
    @factura = Factura.new(factura_params)

    respond_to do |format|
      if @factura.save
        format.html { redirect_to [@factura.obra, @factura], notice: 'Factura creada con éxito.' }
        format.json { render action: 'show', status: :created, location: @factura }
      else
        format.html { render action: 'new' }
        format.json { render json: @factura.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @factura.update(factura_params)
        format.html { redirect_to @factura, notice: 'Factura actualizada con éxito.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @factura.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @factura.destroy
      volver_a_listado =  @factura.pago? ?  pagos_facturas_url : cobros_facturas_url
      respond_to do |format|
        format.html { redirect_to volver_a_listado }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render action: :edit }
        format.json { render json: @factura.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def set_tercero
      if params[:tercero_id]
        @tercero = Tercero.find(params[:tercero_id])
      end

      if @tercero.nil?
        @tercero = Tercero.new(
          nombre: params[:nombre_tercero],
          cuit: params[:cuit_tercero]
        )
      end

      if ( @tercero.present? && @factura.present? )
        @factura.tercero = @tercero
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def factura_params
      params.require(:factura).permit(
        :tipo, :numero, :situacion, :tercero_id, :importe_neto, :iva,
        :descripcion, :importe_total, :fecha, :fecha_pago, :obra_id,
        :importe_neto_moneda, :iva_moneda, :importe_total_moneda,
        tercero_attributes: [ :nombre, :cuit ]
      )
    end
end
