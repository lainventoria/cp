# Load the Rails application.
require File.expand_path('../application', __FILE__)

Time::DATE_FORMATS[:formato__fecha] = "%d/%m/%Y"

# Initialize the Rails application.
Cp::Application.initialize!
