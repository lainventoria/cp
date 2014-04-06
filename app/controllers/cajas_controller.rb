# encoding: utf-8
class CajasController < ApplicationController
  before_action :set_obra
  before_action :set_caja, except: [ :index, :new, :create ]

  def index
    @cajas =     (@obra ? @obra.cajas : Caja).de_efectivo
    @cuentas =   (@obra ? @obra.cajas : Caja).cuentas
    @chequeras = (@obra ? @obra.cajas : Caja).chequeras
  end

  def show
    @editar = false
  end

  def new
    @caja = Caja.new obra: @obra
    @editar = true
  end

  def edit
    @editar = true
  end

  def create
    @caja = Caja.new caja_params

    ir_a = @obra ? [@obra,@caja] : @caja

    respond_to do |format|
      if @caja.save
        format.html { redirect_to ir_a, notice: 'Caja creada con éxito.' }
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

  # las cajas solo se archivan cuando no tienen saldo
  def destroy
    if @caja.archivar
      respond_to do |format|
        format.html { redirect_to obra_cajas_url(@caja.obra) }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { render action: 'edit', location: @caja }
        format.json { render json: @caja.errors, status: :unprocessable_entity }
      end
    end
  end

  def cambiar
    @operacion = Operacion.new caja: @caja
  end

  def transferir
    @operacion = Operacion.new caja: @caja
  end

  def operar
    @operacion = Operacion.new operacion_params

    respond_to do |format|
      if @operacion.send(operacion)
        format.html { redirect_to ruta_segun_operacion, notice: 'Operación realizada con éxito.' }
        format.json { head :no_content }
      else
        format.html { redirect_to ruta_segun_operacion, notice: 'Ocurrió un error.' }
        format.json { render json: @operacion.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def set_caja
      @caja = (@obra.present? ? @obra.cajas : Caja).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def caja_params
      params.require(:caja).permit(
        :obra_id, :situacion, :tipo, :banco, :numero
      )
    end

    # Operaciones permitidas
    def operaciones_validas
      %{ transferir cambiar }
    end

    # Devuelve la operación sólo si es válida
    def operacion
      if operaciones_validas.include?(params[:tipo_de_operacion])
        params[:tipo_de_operacion]
      else
        nil
      end
    end

    # A qué ruta redirigir después de la operación
    def ruta_segun_operacion
      case operacion
        when 'transferir'
          transferir_caja_path(@caja)
        when 'cambiar'
          cambiar_caja_path(@caja)
        else
          @caja
      end
    end

    # Parámetros permitidos para las operaciones de caja
    def operacion_params
      params.require(:operacion).permit(
        :caja_id, :monto, :monto_moneda, :caja_destino_id,
        :monto_aceptado, :monto_aceptado_moneda
      )
    end
end
