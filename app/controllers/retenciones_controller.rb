# encoding: utf-8
class RetencionesController < ApplicationController
  # En orden de jerarquía
  before_action :set_obra
  before_action :set_factura, only: [:show, :edit, :update, :new, :create]
  before_action :set_retencion, only: [:show, :edit, :update, :destroy]
  before_action :set_retenciones, only: [:index]

  def index
  end

  def show
    @editar = false
  end

  def new
    @retencion = @factura.retenciones.build
    @editar = true
  end

  def edit
    @editar = true
  end

  def create
    @retencion = @factura.retenciones.build retencion_params

    respond_to do |format|
      if @retencion.save
        format.html { redirect_to [@retencion.factura, @retencion], notice: "Retención creada con éxito." }
        format.json { render action: 'show', status: :created, location: @retencion }
      else
        format.html { render action: 'new' }
        format.json { render json: @retencion.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @retencion.update(retencion_params)
        format.html { redirect_to [@retencion.factura, @retencion], notice: "Retención actualizada con éxito." }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @retencion.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @retencion.destroy
    respond_to do |format|
      format.html { redirect_to retenciones_url }
      format.json { head :no_content }
    end
  end

  private

    def set_retencion
      @retencion = if @factura.present?
        @factura.retenciones
      elsif @obra.present?
        @obra.retenciones
      else
        Retencion
      end.find(params[:id])

      # Y cargamos la factura por si se encontró por otro lado
      @factura = @retencion.try :factura
    end

    def set_retenciones
      @retenciones = if @factura.present?
        @factura.retenciones
      elsif @obra.present?
        @obra.retenciones
      else
        Retencion.all
      end
    end

    def retencion_params
      params.require(:retencion).permit(
        :monto, :documento, :factura_id, :fecha_vencimiento
      )
    end
end
