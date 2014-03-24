# encoding: utf-8
class CajasController < ApplicationController
  before_action :set_caja, only: [:show, :edit, :update, :destroy]
  before_action :set_movimientos, only: [:show]
  before_action :set_obra

  def index
    @cajas = @obra ? @obra.cajas.where(situacion: 'efectivo') : Caja.where(situacion: 'efectivo')
    @cuentas = @obra ? @obra.cajas.where(situacion: 'banco') : Caja.where(situacion: 'banco')
  end

  def show
    @editar = false
  end

  def new
    @caja = Caja.new
    @editar = true
  end

  def edit
    @editar = true
  end

  def create
    @caja = Caja.new caja_params

    respond_to do |format|
      if @caja.save
        format.html { redirect_to @caja, notice: 'Caja creada con éxito.' }
        format.json {
          render action: 'show', status: :created, location: @caja
        }
      else
        # FIXME pasar situacion via controlador o helper
        params[:situacion] = @caja.situacion
        format.html { render action: 'new' }
        format.json { render json: @caja.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @caja.update(caja_params)
        format.html { redirect_to @caja, notice: 'Caja actualizada con éxito.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @caja.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @caja.destroy
    respond_to do |format|
      format.html { redirect_to cajas_url }
      format.json { head :no_content }
    end
  end

  private

    def set_caja
      @caja = Caja.find(params[:id])
    end

    def set_movimientos
      @movimientos = Movimiento.where(caja_id: @caja.id)

      if ( ! @caja.nil? && ! @movimientos.nil? )
        @caja.movimientos = @movimientos
      end
    end
        

    # Never trust parameters from the scary internet, only allow the white list through.
    def caja_params
      params.require(:caja).permit(:obra_id, :situacion, :tipo, :banco, :numero)
    end
end
