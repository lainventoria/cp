module ApplicationHelper
  # Título de la página para el +<head>+ por defecto
  def titulo_de_la_aplicacion
    "#{titulo.present? ? "#{titulo} | " : nil}CP"
  end

  # Por defecto, no se usa nada. Cada helper específico redefine este método si
  # quiere un título específico
  def titulo
    nil
  end

	def formatted_date(date)
	  date.strftime("%d/%m/%Y")
	end
end
