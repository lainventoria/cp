# encoding: utf-8
class ChequesController < ApplicationController
  before_action :set_obra
  before_action :set_caja, only: [ :index, :propios, :terceros ]
  before_action :set_cheque, only: [ :show, :edit, :update, :destroy ]

  def index
    @cheques = @caja ? @caja.cheques : Cheque.all
  end

  def show
    @editar = false
  end

  # TODO borrar 'new' cuando exista interfase para crear cheques
  def new
    @cheque = Cheque.new
    @editar = true
  end

  def edit
    @editar = true
  end

  def propios
    @cheques = (@caja ? @caja.cheques : Cheque).propios
    @situacion = "propio"
    render "index"
  end

  def terceros
    @cheques = (@caja ? @caja.cheques : Cheque).de_terceros
    @situacion = "terceros"
    render "index"
  end

  def create
    @cheque = Cheque.new(cheque_params)

    respond_to do |format|
      if @cheque.save
        format.html { redirect_to @cheque, notice: 'Cheque creado con éxito.' }
        format.json { render action: 'show', status: :created, location: @cheque }
      else
        format.html { render action: 'new' }
        format.json { render json: @cheque.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @cheque.update(cheque_params)
        format.html { redirect_to @cheque, notice: 'Cheque actualizado con éxito.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @cheque.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    volver_a_listado =  @cheque.propio? ?  propios_cheques_url : terceros_cheques_url
    @cheque.destroy
    respond_to do |format|
      format.html { redirect_to volver_a_listado }
      format.json { head :no_content }
    end
  end

  private

    def set_cheque
      @cheque = (@obra.present? ? @obra.cheques : Cheque).find(params[:id])
    end

    def cheque_params
      params.require(:cheque).permit(
        :situacion, :numero, :monto, :monto_centavos, :monto_moneda,
        :fecha_vencimiento, :fecha_emision, :beneficiario, :banco, :estado,
        :chequera_id, :cuenta_id
      )
    end

    def set_caja
      @caja = params[:caja_id].present? ? Caja.find(params[:caja_id]) : nil
    end
end
