class CuentasController < ApplicationController
  before_action :set_cuenta, only: [:show, :edit, :update, :destroy]

  # GET /cuentas
  # GET /cuentas.json
  def index
    @cuentas = Cuenta.all
  end

  # GET /cuentas/1
  # GET /cuentas/1.json
  def show
  end

  # GET /cuentas/new
  def new
    @cuenta = Cuenta.new
  end

  # GET /cuentas/1/edit
  def edit
  end

  # POST /cuentas
  # POST /cuentas.json
  def create
    @cuenta = Cuenta.new(cuenta_params)

    respond_to do |format|
      if @cuenta.save
        format.html { redirect_to @cuenta, notice: 'Cuenta was successfully created.' }
        format.json { render action: 'show', status: :created, location: @cuenta }
      else
        format.html { render action: 'new' }
        format.json { render json: @cuenta.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cuentas/1
  # PATCH/PUT /cuentas/1.json
  def update
    respond_to do |format|
      if @cuenta.update(cuenta_params)
        format.html { redirect_to @cuenta, notice: 'Cuenta was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @cuenta.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cuentas/1
  # DELETE /cuentas/1.json
  def destroy
    @cuenta.destroy
    respond_to do |format|
      format.html { redirect_to cuentas_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cuenta
      @cuenta = Cuenta.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cuenta_params
      params.require(:cuenta).permit(:numero, :obra_id)
    end
end
