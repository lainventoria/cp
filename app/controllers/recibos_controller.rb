# encoding: utf-8
class RecibosController < ApplicationController
  before_action :set_recibo, only: [:show, :edit, :update, :destroy]
  before_action :set_factura, only: [:show, :edit, :update, :destroy, :index, :create, :new]
  before_action :set_obra
  before_action :set_facturas, only: [ :index, :cobros, :pagos ]
  before_action :set_causa, only: [ :update, :create ]

  # GET /recibos
  # GET /recibos.json
  def index
    if @facturas
      @recibos = Recibo.where(factura_id: @facturas)
    else
      @recibos = @factura ? @factura.recibos : Recibo.all
    end
  end

  def cobros
    if @facturas
      @recibos = Recibo.where(factura_id: @facturas).where(situacion: 'cobro')
    else
      @recibos = @factura ? @factura.recibos.where(situacion: 'cobro') : Recibo.where(situacion: "cobro")
    end
    @situacion = "Cobros"
    render "index"
  end

  def pagos
    if @facturas
      @recibos = Recibo.where(factura_id: @facturas).where(situacion: 'pago')
    else
      @recibos = @factura ? @factura.recibos.where(situacion: 'pago') : Recibo.where(situacion: "pago")
    end

    @situacion = "Pagos"
    render "index"
  end

  # GET /recibos/1
  # GET /recibos/1.json
  def show
    @editar = false
  end

  # GET /recibos/new
  def new
    @recibo = Recibo.new
    @editar = true
  end

  # GET /recibos/1/edit
  def edit
    @editar = true
  end

  # POST /recibos
  # POST /recibos.json
  def create
    @editar = true
    @recibo = Recibo.new(recibo_params)

    respond_to do |format|
      if @recibo.save && @recibo.pagar_con(@causa)

        format.html { seguir_agregando_o_mostrar }
        format.json { render action: 'show', status: :created, location: [@recibo.factura,@recibo] }
      else
        format.html { render action: 'new' }
        format.json { render json: @recibo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recibos/1
  # PATCH/PUT /recibos/1.json
  def update
    @editar = true
    respond_to do |format|
      if @recibo.update(recibo_params) && @recibo.pagar_con(@causa)

        format.html { seguir_agregando_o_mostrar }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @recibo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recibos/1
  # DELETE /recibos/1.json
  def destroy
    @recibo.destroy
    respond_to do |format|
      format.html { redirect_to [@factura] }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recibo
      if params[:id]
        @recibo = Recibo.find(params[:id])
      end
    end

    def set_factura
      if params[:factura_id]
        @factura = Factura.find(params[:factura_id])
      end

      if ( ! @factura.nil? && ! @recibo.nil? )
        @recibo.factura = @factura
      end
    end

    def set_facturas
      @facturas = @obra ? @obra.facturas : nil
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def recibo_params
      params.require(:recibo).permit(:fecha, :importe, :situacion, :factura_id)
    end

    def seguir_agregando_o_mostrar
      if params[:agregar_causa]
        render action: @recibo.persisted? ? 'edit' : 'new'
      else
        redirect_to [@recibo.factura, @recibo], notice: 'Recibo actualizado con éxito.'
      end
    end

    def set_causa
      @causa = case params[:causa_tipo]
        when 'retencion'
          @factura.retencion
        else
          causa.try :new, causa_params
      end
    end
end
