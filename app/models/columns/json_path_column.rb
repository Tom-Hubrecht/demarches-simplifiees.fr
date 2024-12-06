# frozen_string_literal: true

class Columns::JSONPathColumn < Columns::ChampColumn
  attr_reader :jsonpath

  def initialize(procedure_id:, label:, stable_id:, tdc_type:, jsonpath:, options_for_select: [], displayable:, filterable: true, type: :text)
    @jsonpath = quote_string(jsonpath)

    super(
      procedure_id:,
      label:,
      stable_id:,
      tdc_type:,
      displayable:,
      filterable:,
      type:,
      options_for_select:
    )
  end

  def filtered_ids(dossiers, search_terms)
    value = quote_string(search_terms.join('|'))

    condition = %{champs.value_json @? '#{jsonpath} ? (@ like_regex "#{value}" flag "i")'}

    dossiers.with_type_de_champ(stable_id)
      .where(condition)
      .ids
  end

  private

  def column_id = "type_de_champ/#{stable_id}-#{jsonpath}"

  def typed_value(champ)
    champ.value_json&.dig(*jsonpath.split('.')[1..])
  end

  def quote_string(string) = ActiveRecord::Base.connection.quote_string(string)
end
