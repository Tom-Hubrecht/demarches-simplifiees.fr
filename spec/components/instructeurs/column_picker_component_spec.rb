# frozen_string_literal: true

describe Instructeurs::ColumnPickerComponent, type: :component do
  let(:component) { described_class.new(procedure:, procedure_presentation:) }

  let(:procedure) { create(:procedure) }
  let(:procedure_id) { procedure.id }
  let(:instructeur) { create(:instructeur) }
  let(:assign_to) { create(:assign_to, procedure: procedure, instructeur: instructeur) }
  let(:procedure_presentation) { create(:procedure_presentation, assign_to: assign_to) }

  describe "#displayable_columns_for_select" do
    let(:default_user_email) { Column.new(procedure_id:, label: 'email', table: 'user', column: 'email') }
    let(:excluded_displayable_field) { Column.new(procedure_id:, label: "label1", table: "table1", column: "column1", displayable: false) }
    let(:email_column_id) { Column.make_id(procedure_id, 'user', 'email') }

    subject { component.displayable_columns_for_select }

    before do
      allow(procedure).to receive(:columns).and_return([
        default_user_email,
        excluded_displayable_field
      ])
    end

    it { is_expected.to eq([[["email", email_column_id]], [email_column_id]]) }
  end
end
