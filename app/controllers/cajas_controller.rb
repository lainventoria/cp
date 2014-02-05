# encoding: utf-8
class CajasController < ApplicationController
  before_action :set_obra
  before_action :set_caja, only: [:show, :edit, :update, :destroy]

  def index
    @cajas = @obra.cajas
  end

  def show
  end

  def new
    @caja = @obra.cajas.build
  end

  def edit
  end

  def create
    @caja = @obra.cajas.build(caja_params)

    respond_to do |format|
      if @caja.save
        format.html { redirect_to [@obra, @caja], notice: 'Caja creada con éxito.' }
        format.json {
          render action: 'show', status: :created, location: [@obra, @caja]
        }
      else
        format.html { render action: 'new' }
        format.json { render json: @caja.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @caja.update(caja_params)
        format.html { redirect_to [@obra, @caja], notice: 'Caja actualizada con éxito.' }
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
      format.html { redirect_to obra_cajas_url(@obra) }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_obra
      @obra = Obra.find(params[:obra_id])
    end

    def set_caja
      @caja = @obra.cajas.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def caja_params
      params.require(:caja).permit(:obra_id)
    end
end
