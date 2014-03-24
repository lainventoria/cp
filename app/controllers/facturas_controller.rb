# encoding: utf-8
class FacturasController < ApplicationController
  before_action :set_factura, only: [:show, :edit, :update, :destroy]
  before_action :set_obra

  # GET /facturas
  # GET /facturas.json
  def index
    @facturas = @obra ? @obra.facturas : Factura.all
  end

  # Solo mostrar facturas para cobrar reciclando la vista de lista
  def cobros
    @facturas = @obra ? @obra.facturas.where(situacion: 'cobro') : Factura.where(situacion: "cobro")
    @situacion = "cobro"
    render "index"
  end

  def pagos
    @facturas = @obra ? @obra.facturas.where(situacion: 'pago') : Factura.where(situacion: "pago")
    @situacion = "pago"
    render "index"
  end

  # GET /facturas/1
  # GET /facturas/1.json
  def show
    @editar = false
  end

  # GET /facturas/new
  def new
    @editar = true
    @factura = Factura.new
  end

  # GET /facturas/1/edit
  def edit
    @editar = true
  end

  # POST /facturas
  # POST /facturas.json
  def create
    @factura = Factura.new(factura_params)

    respond_to do |format|
      if @factura.save
        format.html { redirect_to @factura, notice: 'Factura creada con éxito.' }
        format.json { render action: 'show', status: :created, location: @factura }
      else
        format.html { render action: 'new' }
        format.json { render json: @factura.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /facturas/1
  # PATCH/PUT /facturas/1.json
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

  # DELETE /facturas/1
  # DELETE /facturas/1.json
  def destroy
    volver_a_listado =  @factura.pago? ?  pagos_facturas_url : cobros_facturas_url
    @factura.destroy
    respond_to do |format|
      format.html { redirect_to volver_a_listado }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_factura
      @factura = Factura.find(params[:id])
    end

    def set_tercero
      if params[:tercero_id]
        @tercero = Tercero.find(params[:tercero_id])
      end

      if ( ! @tercero.nil? && ! @factura.nil? )
        @factura.tercero = @tercero
      end
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def factura_params
      params.require(:factura).permit(:tipo, :numero, :situacion, :tercero_id, :importe_neto, :iva, :descripcion, :importe_total, :fecha, :fecha_pago, :obra_id)
    end
end
