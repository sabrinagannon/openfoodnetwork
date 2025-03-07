# frozen_string_literal: true

require "spec_helper"

describe ProductComponent, type: :component do
  let(:product) { create(:simple_product) }

  describe 'unit' do
    before do
      render_inline(
        ProductComponent.new(
          product: product, columns: [{ label: "Unit", value: "unit", sortable: false }]
        )
      )
    end

    it 'concatenates the unit value and the unit description' do
      expect(page.find('.unit')).to have_content '1.0 weight'
    end
  end

  describe 'category' do
    let(:product) do
      product = create(:simple_product)
      product.taxons = taxons

      product
    end
    let(:taxons) { [create(:taxon, name: 'random 1'), create(:taxon, name: 'random 2')] }

    before do
      render_inline(
        ProductComponent.new(
          product: product, columns: [{ label: "Category", value: "category", sortable: false }]
        )
      )
    end

    it "joins the categories' name" do
      expect(page.find('.category')).to have_content(
        /random 1, random 2/, exact: true, normalize_ws: true
      )
    end
  end

  describe 'on_hand' do
    let(:product) { create(:simple_product, on_hand: on_hand) }
    let(:on_hand) { 5 }

    before do
      render_inline(
        ProductComponent.new(
          product: product, columns: [{ label: "On Hand", value: "on_hand", sortable: false }]
        )
      )
    end

    it 'returns product on_hand' do
      expect(page.find('.on_hand')).to have_content(on_hand)
    end

    context 'when on_hand is nil' do
      let(:on_hand) { nil }

      it 'returns 0' do
        expect(page.find('.on_hand')).to have_content(0.to_s)
      end
    end
  end
end
