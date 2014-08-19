# encoding: utf-8
AttributeNormalizer.configure do |config|
  # The default normalizers if no :with option or block is given is to apply
  # the :strip and :blank normalizers (in that order).
  config.default_normalizers = :strip, :blank

  # You can enable the attribute normalizers automatically if the specified
  # attributes exist in your column_names. It will use the default normalizers
  # for each attribute (e.g.  config.default_normalizers)
  config.default_attributes = :nombre, :descripcion, :tipo, :situacion

  # Todo en mayúsculas
  config.normalizers[:upcase] = lambda do |value, options|
    value.is_a?(String) ? value.upcase : value
  end

  config.normalizers[:truncate] = lambda do |value, options|
    value.is_a?(String) ? value[0, options[:length]] : value
  end
end
