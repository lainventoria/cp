# encoding: utf-8
class ChequesController < ApplicationController
  before_action :set_obra
  before_action :set_caja
  before_action :set_cheque, only: [ :show, :edit, :update, :destroy, :depositar, :pagar, :cobrar ]
  before_action :set_order, only: [:index]

  def index
    if params[:situacion]
      @cheques = (@caja ? @caja.cheques : Cheque).where(situacion: params[:situacion]).order(@order)
    else
      @cheques = (@caja ? @caja.cheques : Cheque.all).order(@order)
    end

    if params[:vencidos]
      @cheques = @cheques.vencidos
    end

    if params[:depositados]
      @cheques = @cheques.depositados
    end

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

  def create
    @cheque = Cheque.new(cheque_params)

    respond_to do |format|
      if @cheque.save
        format.html { redirect_to [@cheque.chequera.obra, @cheque.chequera, @cheque], notice: 'Cheque creado con éxito.' }
        format.json { render action: 'show', status: :created, location: [@cheque.chequera.obra, @cheque.chequera, @cheque] }
      else
        format.html { render action: 'new' }
        format.json { render json: @cheque.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @cheque.update(cheque_params)
        format.html { redirect_to [@cheque.chequera.obra, @cheque.chequera, @cheque], notice: 'Cheque actualizado con éxito.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @cheque.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    volver_a_listado = obra_cajas_url @cheque.chequera.obra, @cheque.chequera
    @cheque.destroy
    respond_to do |format|
      format.html { redirect_to volver_a_listado }
      format.json { head :no_content }
    end
  end

  def pagar
    @cheque = Cheque.find(params[:id])
    respond_to do |format|
      if @cheque.pagar
        format.html { redirect_to [@cheque.chequera.obra,@cheque.chequera,@cheque],
                      notice: 'Cheque pagado con éxito' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @cheque.errors, status: :unprocessable_entity }
      end
    end
  end

  def depositar
    respond_to do |format|
      if @cheque.depositar(Caja.find(params[:cheque][:cuenta_id]))
        format.html { redirect_to [@cheque.chequera.obra,@cheque.chequera,@cheque],
                      notice: 'Cheque depositado con éxito' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @cheque.errors, status: :unprocessable_entity }
      end
    end
  end

  def cobrar
    @cheque = Cheque.find(params[:id])
    respond_to do |format|
      if @cheque.cobrar
        format.html { redirect_to [@cheque.chequera.obra,@cheque.chequera,@cheque],
                      notice: 'Cheque cobrado con éxito' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @cheque.errors, status: :unprocessable_entity }
      end
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
        :chequera_id, :cuenta_id, :obra_id
      )
    end

    def set_caja
      if params[:caja_id]
        @caja = (@obra.present? ? @obra.cajas : Caja).find(params[:caja_id])
      end
    end
end
