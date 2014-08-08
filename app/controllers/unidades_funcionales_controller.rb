# encoding: utf-8
class UnidadesFuncionalesController < ApplicationController
  before_action :set_obra
  before_action :set_unidad, only: [ :update, :edit, :show, :destroy ]

  def index
    @unidades = @obra.unidades_funcionales
  end

  def show
    @editar = false
  end

  def new
    @editar = true
    @unidad = UnidadFuncional.new
  end

  def edit
    @editar = true
  end

  def create
    @unidad = UnidadFuncional.new unidad_funcional_params

    respond_to do |format|
      if @unidad.save
        format.html do redirect_to [@unidad.obra, @unidad],
          notice: 'Unidad funcional creada con éxito.'
        end
        format.json do
          render action: 'show', status: :created, location: @unidad
        end
      else
        format.html { render action: 'new' }
        format.json { render json: @unidad.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @unidad.update(unidad_funcional_params)
        format.html do
          redirect_to [@unidad.obra,@unidad],
            notice: 'Unidad funcional actualizada con éxito.'
        end
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @unidad.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @unidad.destroy
      respond_to do |format|
        format.html { redirect_to obra_unidades_funcionales_path(@obra) }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render action: 'edit', location: @unidad }
        format.json { render json: @unidad.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def set_obra
      @obra = Obra.find(params[:obra_id])
    end

    def set_unidad
      @unidad = UnidadFuncional.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def unidad_funcional_params
      params.require(:unidad_funcional).permit(
        :obra_id, :tipo, :precio_venta, :precio_venta_centavos,
        :precio_venta_moneda, :descripcion
      )
    end
end
