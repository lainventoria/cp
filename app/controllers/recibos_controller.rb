# encoding: utf-8
class RecibosController < ApplicationController
  before_action :set_recibo, only: [:show, :edit, :update, :destroy]
  before_action :set_factura, only: [:show, :edit, :update, :destroy, :index, :create, :new]

  # GET /recibos
  # GET /recibos.json
  def index
    @recibos = Recibo.all
  end

  # GET /recibos/1
  # GET /recibos/1.json
  def show
  end

  # GET /recibos/new
  def new
    @recibo = Recibo.new
  end

  # GET /recibos/1/edit
  def edit
  end

  # POST /recibos
  # POST /recibos.json
  def create
    @recibo = Recibo.new(recibo_params)

    respond_to do |format|
      if @recibo.save
        format.html { redirect_to [@recibo.factura, @recibo], notice: 'Recibo creado con éxito.' }
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
    respond_to do |format|
      if @recibo.update(recibo_params)
        format.html { redirect_to [@recibo.factura, @recibo], notice: 'Recibo actualizado con éxito.' }
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
      format.html { redirect_to [@factura, :recibos] }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recibo
      @recibo = Recibo.find(params[:id])
    end

    def set_factura
      @factura = Factura.find(params[:factura_id])
      if ( ! @factura.nil? && ! @recibo.nil? ) 
        @recibo.factura = @factura
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def recibo_params
      params.require(:recibo).permit(:fecha, :importe, :situacion, :factura_id)
    end
end
