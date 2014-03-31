# encoding: utf-8
class RetencionesController < ApplicationController
  before_action :set_retencion, only: [:show, :edit, :update, :destroy]
  before_action :set_factura, only: [:show, :edit, :update, :new]
  before_action :set_obra

  def index
    @retencions = Retencion.all
  end

  def show
  end

  def new
    @retencion = Retencion.new
  end

  def edit
  end

  def create
    @retencion = Retencion.new(retencion_params)

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
      @retencion = Retencion.find(params[:id])
    end

    def set_factura
      if params[:action] == 'new'
        @factura = Factura.find(params[:factura_id])
      else
        @factura = Factura.find(@retencion.factura_id)
      end

      if ( ! @factura.nil? && ! @retencion.nil? )
        @retencion.factura = @factura
      end
    end

    def retencion_params
      params.require(:retencion).permit(
        :monto, :documento, :factura_id, :fecha_vencimiento, :documento_file_name, :documento_content_type, :documento_file_size, :documento_uploaded_at
      )
    end
end
