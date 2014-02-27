class AddAttachmentDocumentoToRetenciones < ActiveRecord::Migration
  def change
    add_attachment :retenciones, :documento
  end
end
