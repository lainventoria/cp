# encoding: utf-8
class ChequesController < ApplicationController
  before_action :set_obra
  before_action :set_caja
  before_action :set_cheques, only: [ :index ]
  before_action :set_cheque, only: [ :show, :edit, :update, :destroy, :depositar, :pagar, :cobrar ]
  before_action :set_order, only: [ :index ]
  before_action :set_recibos, only: [ :show ]

  def index
    @situacion = params[:situacion]
    @cheques = @cheques.where(situacion: params[:situacion]) if params[:situacion]
    @cheques = @cheques.where(estado: params[:estado]) if params[:estado]
    @cheques = @cheques.vencidos if params[:vencidos]
    @cheques = @cheques.depositados if params[:depositados]

    @cheques = @cheques.order(@order)
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
        format.html do
          redirect_to [@cheque.chequera.obra, @cheque.chequera, @cheque],
            notice: 'Cheque creado con éxito.'
        end
        format.json do
          render action: 'show', status: :created,
            location: [@cheque.chequera.obra, @cheque.chequera, @cheque]
        end
      else
        format.html { render action: 'new' }
        format.json { render json: @cheque.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @cheque.update(cheque_params)
        format.html do
          redirect_to [@cheque.chequera.obra, @cheque.chequera, @cheque],
            notice: 'Cheque actualizado con éxito.'
        end
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
        format.html do
          redirect_to obra_cheques_path(@cheque.chequera.obra, situacion: 'propio'),
            notice: 'Cheque pagado con éxito'
        end
        format.json { head :no_content }
      else
        format.html { render action: 'show' }
        format.json { render json: @cheque.errors, status: :unprocessable_entity }
      end
    end
  end

  def depositar
    respond_to do |format|
      if @cheque.depositar(Caja.find(params[:cheque][:cuenta_id]))
        format.html do
          redirect_to [@cheque.chequera.obra,@cheque.chequera,@cheque],
            notice: 'Cheque depositado con éxito'
        end
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
        format.html do
          redirect_to [@cheque.chequera.obra,@cheque.chequera,@cheque],
            notice: 'Cheque cobrado con éxito'
        end
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

    def set_cheques
      @cheques = if @caja.present?
        @caja.cheques
      elseif @obra.present?
        @obra.cheques
      else
        Cheque.all
      end
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

    def set_recibos
      @recibos = @cheque.recibos.uniq
    end
end
