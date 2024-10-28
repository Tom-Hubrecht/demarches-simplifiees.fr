# frozen_string_literal: true

module ColumnsConcern
  extend ActiveSupport::Concern

  included do
    # we cannot use column.id ( == { procedure_id, column_id }.to_json)
    # as the order of the keys is not guaranteed
    # instead, we are using h_id == { procedure_id:, column_id: }
    # another way to find a column is to look for its label
    def find_column(h_id: nil, label: nil)
      column = columns.find { _1.h_id == h_id } if h_id.present?
      column = columns.find { _1.label == label } if label.present?

      raise ActiveRecord::RecordNotFound.new("Column: unable to find h_id: #{h_id} or label: #{label} for procedure_id #{id}") if column.nil?

      column
    end

    def columns
      Current.procedure_columns ||= {}

      Current.procedure_columns[id] ||= begin
        columns = dossier_columns
        columns.concat(standard_columns)
        columns.concat(individual_columns) if for_individual
        columns.concat(moral_columns) if !for_individual
        columns.concat(chorus_columns)
        columns.concat(types_de_champ_columns)
      end
    end

    def chorus_columns
      ['domaine_fonctionnel', 'referentiel_prog', 'centre_de_cout']
        .map { |column| Column.new(procedure_id: id, table: 'procedure', column:, displayable: false, filterable: false) }
    end

    def all_usager_columns_for_export
      columns = [dossier_id_column, email_for_display_column, france_connected_column]
      columns.concat(individual_columns) if for_individual
      columns.concat(moral_columns) if !for_individual
      columns.concat(chorus_columns) if chorusable? && chorus_configuration.complete?

      columns.flatten.compact
    end

    def all_dossier_columns_for_export
      states = [dossier_state_column]

      for_export_before_date = ['archived']
        .map { |column| Column.new(procedure_id: id, table: 'self', column:, type: :text, displayable: false, filterable: false) }
      for_export_after_date = ['motivation']
        .map { |column| Column.new(procedure_id: id, table: 'self', column:, type: :text, displayable: false, filterable: false) }
      routing =
        if self.routing_enabled?
          [Column.new(procedure_id: id, table: 'groupe_instructeur', column: 'id')]
        else
          []
        end

      instructeurs = [Column.new(procedure_id: id, table: 'followers_instructeurs', column: 'email')]

      [states, for_export_before_date, dossier_dates_columns, for_export_after_date, sva_svr_columns(for_export: true), routing, instructeurs].flatten.compact
    end

    def dossier_id_column
      Column.new(procedure_id: id, table: 'self', column: 'id', type: :number)
    end

    def dossier_state_column
      Column.new(procedure_id: id, table: 'self', column: 'state', label: I18n.t('activerecord.attributes.procedure_presentation.fields.self.state'), type: :enum, scope: 'instructeurs.dossiers.filterable_state', displayable: false)
    end

    def email_for_display_column = Column.new(procedure_id: id, table: 'self', column: 'user_email_for_display', filterable: false, displayable: false)

    def france_connected_column = Column.new(procedure_id: id, table: 'self', column: 'user_from_france_connect?', filterable: false, displayable: false)

    def notifications_column
      Column.new(procedure_id: id, table: 'notifications', column: 'notifications', label: "notifications", filterable: false)
    end

    def dossier_columns
      common = [dossier_id_column, notifications_column]

      states = [dossier_state_column]

      non_displayable_dates = ['updated_since', 'depose_since', 'en_construction_since', 'en_instruction_since', 'processed_since']
        .map { |column| Column.new(procedure_id: id, table: 'self', column:, type: :date, displayable: false) }

      for_export_before_date = ['archived']
        .map { |column| Column.new(procedure_id: id, table: 'self', column:, type: :text, displayable: false, filterable: false) }
      for_export_after_date = ['motivation']
        .map { |column| Column.new(procedure_id: id, table: 'self', column:, type: :text, displayable: false, filterable: false) }

      [common, states, for_export_before_date, dossier_dates_columns, for_export_after_date, sva_svr_columns(for_export: false), non_displayable_dates].flatten.compact
    end

    def dossier_dates_columns
      ['created_at', 'updated_at', 'last_champ_updated_at', 'depose_at', 'en_construction_at', 'en_instruction_at', 'processed_at']
        .map { |column| Column.new(procedure_id: id, table: 'self', column:, type: :date) }
    end

    def sva_svr_columns(for_export: false)
      return if !sva_svr_enabled?

      scope = [:activerecord, :attributes, :procedure_presentation, :fields, :self]

      columns = [
        Column.new(procedure_id: id, table: 'self', column: 'sva_svr_decision_on', type: :date,
                  label: I18n.t("#{sva_svr_decision}_decision_on", scope:, type: sva_svr_configuration.human_decision))
      ]
      if !for_export
        columns << Column.new(procedure_id: id, table: 'self', column: 'sva_svr_decision_before', type: :date, displayable: false,
                      label: I18n.t("#{sva_svr_decision}_decision_before", scope:))
      end
      columns
    end

    def default_sorted_column
      SortedColumn.new(column: notifications_column, order: 'desc')
    end

    def default_displayed_columns = [email_column]

    private

    def email_column
      Column.new(procedure_id: id, table: 'user', column: 'email')
    end

    def standard_columns
      [
        email_column,
        email_for_display_column,
        Column.new(procedure_id: id, table: 'followers_instructeurs', column: 'email'),
        Column.new(procedure_id: id, table: 'groupe_instructeur', column: 'id', type: :enum),
        Column.new(procedure_id: id, table: 'avis', column: 'question_answer', filterable: false),
        Column.new(procedure_id: id, table: 'user', column: 'id', filterable: false, displayable: false),
        france_connected_column
      ]
    end

    def individual_columns
      ['gender', 'nom', 'prenom'].map { |column| Column.new(procedure_id: id, table: 'individual', column:) }
        .concat ['for_tiers', 'mandataire_last_name', 'mandataire_first_name'].map { |column| Column.new(procedure_id: id, table: 'self', column:) }
    end

    def moral_columns
      etablissements = ['entreprise_forme_juridique', 'entreprise_siren', 'entreprise_nom_commercial', 'entreprise_raison_sociale', 'entreprise_siret_siege_social']
        .map { |column| Column.new(procedure_id: id, table: 'etablissement', column:) }

      etablissement_dates = ['entreprise_date_creation'].map { |column| Column.new(procedure_id: id, table: 'etablissement', column:, type: :date) }

      for_export = ["siege_social", "naf", "adresse", "numero_voie", "type_voie", "nom_voie", "complement_adresse", "localite", "code_insee_localite", "entreprise_siren", "entreprise_capital_social", "entreprise_numero_tva_intracommunautaire", "entreprise_forme_juridique_code", "entreprise_code_effectif_entreprise", "entreprise_etat_administratif", "entreprise_nom", "entreprise_prenom", "association_rna", "association_titre", "association_objet", "association_date_creation", "association_date_declaration", "association_date_publication"]
        .map { |column| Column.new(procedure_id: id, table: 'etablissement', column:, displayable: false, filterable: false) }

      other = ['siret', 'libelle_naf', 'code_postal'].map { |column| Column.new(procedure_id: id, table: 'etablissement', column:) }

      [etablissements, etablissement_dates, other, for_export].flatten
    end

    def types_de_champ_columns
      all_revisions_types_de_champ.flat_map { _1.columns(procedure_id: id) }
    end
  end
end
