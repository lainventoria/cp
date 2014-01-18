class Caja < ActiveRecord::Base
  belongs_to :obra
  has_many :movimientos

  validates_presence_of :obra_id
end
