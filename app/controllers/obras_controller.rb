class ObrasController < ApplicationController
  before_action :set_obra, only: [:show, :edit, :update, :destroy]

  # GET /obras
  # GET /obras.json
  def index
    @obras = Obra.all
  end

  # GET /obras/1
  # GET /obras/1.json
  def show
  end

  # GET /obras/new
  def new
    @obra = Obra.new
  end

  # GET /obras/1/edit
  def edit
  end

  # POST /obras
  # POST /obras.json
  def create
    @obra = Obra.new(obra_params)

    respond_to do |format|
      if @obra.save
        format.html { redirect_to @obra, notice: 'Obra was successfully created.' }
        format.json { render action: 'show', status: :created, location: @obra }
      else
        format.html { render action: 'new' }
        format.json { render json: @obra.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /obras/1
  # PATCH/PUT /obras/1.json
  def update
    respond_to do |format|
      if @obra.update(obra_params)
        format.html { redirect_to @obra, notice: 'Obra was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @obra.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /obras/1
  # DELETE /obras/1.json
  def destroy
    @obra.destroy
    respond_to do |format|
      format.html { redirect_to obras_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_obra
      @obra = Obra.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def obra_params
      params.require(:obra).permit(
        :nombre, :direccion
      )
    end
end
