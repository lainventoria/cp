# encoding: utf-8
class RecibosController < ApplicationController
  before_action :set_obra
  before_action :set_factura, only: [:show, :edit, :update, :destroy, :index, :create, :new]
  before_action :set_recibo, only: [:show, :edit, :update, :destroy]
  before_action :set_recibos, only: [ :index, :cobros, :pagos ]

  before_action :set_causa, only: [ :update, :create ]

  def index
  end

  def cobros
    @recibos.where(situacion: 'cobro')
    @situacion = "Cobros"
    render "index"
  end

  def pagos
    @recibos.where(situacion: 'pago')
    @situacion = "Pagos"
    render "index"
  end

  def show
    @editar = false
  end

  def new
    @recibo = @factura.recibos.build
    @editar = true
  end

  def edit
    @editar = true
  end

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
      @recibo = if @factura.present?
        @factura.recibos
      elsif @obra.present?
        @obra.recibos
      else
        Recibo
      end.find(params[:id])

      # Y cargamos la factura por si se encontró por otro lado
      @factura = @recibo.try :factura
    end

    def set_recibos
      @recibos = if @factura.present?
        @factura.recibos
      elsif @obra.present?
        @obra.recibos
      else
        Recibo.all
      end
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
