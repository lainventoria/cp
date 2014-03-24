# encoding: utf-8
class ChequesController < ApplicationController
  before_action :set_cheque, only: [:show, :edit, :update, :destroy]
  before_action :set_caja

  def index
    @cheques = @caja ? @caja.cheques : Cheque.all
  end

  def show
  end

  def propios
    @cheques = Cheque.where(situacion: "propio")
    @situacion = "propios"
    render "index"
  end

  def terceros
    @cheques = Cheque.where(situacion: "terceros")
    @situacion = "terceros"
    render "index"
  end

  private

    def set_cheque
      @cheque = Cheque.find(params[:id])
    end

    def cheque_params
      params.require(:cheque).permit(:situacion, :numero,
      :monto_centavos, :monto_moneda, :fecha_vencimiento,
      :fecha_emision, :beneficiario, :banco, :estado)
    end

    def set_caja
      @caja = params[:caja_id].present? ? Caja.find(params[:caja_id]) : nil
    end

end
