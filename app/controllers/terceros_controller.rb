# encoding: utf-8
class TercerosController < ApplicationController
  before_action :set_tercero, only: [:show, :edit, :update, :destroy]

  # GET /terceros
  # GET /terceros.json
  def index
    @terceros = Tercero.all
  end

  # GET /terceros/1
  # GET /terceros/1.json
  def show
    @editar=false
  end

  # GET /terceros/new
  def new
    @tercero = Tercero.new
    @editar = true
  end

  # GET /terceros/1/edit
  def edit
    @editar=true
  end

  # POST /terceros
  # POST /terceros.json
  def create
    @tercero = Tercero.new(tercero_params)

    respond_to do |format|
      if @tercero.save
        format.html { redirect_to @tercero, notice: 'Tercero creado con éxito' }
        format.json { render action: 'show', status: :created, location: @tercero }
      else
        format.html { render action: 'new' }
        format.json { render json: @tercero.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /terceros/1
  # PATCH/PUT /terceros/1.json
  def update
    respond_to do |format|
      if @tercero.update(tercero_params)
        format.html { redirect_to @tercero, notice: 'Tercero actualizado con éxito.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @tercero.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /terceros/1
  # DELETE /terceros/1.json
  def destroy
    if @tercero.destroy
      respond_to do |format|
        format.html { redirect_to terceros_url }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render action: 'edit' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tercero
      @tercero = Tercero.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tercero_params
      params.require(:tercero).permit(:nombre, :direccion, :telefono, :celular, :email, :iva, :relacion, :cuit, :contacto, :notas)
    end
end
