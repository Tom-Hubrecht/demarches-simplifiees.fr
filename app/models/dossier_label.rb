# frozen_string_literal: true

class DossierLabel < ApplicationRecord
  belongs_to :dossier
  belongs_to :label
end