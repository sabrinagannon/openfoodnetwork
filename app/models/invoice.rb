# frozen_string_literal: true

class Invoice < ApplicationRecord
  belongs_to :order, class_name: 'Spree::Order'
  serialize :data, Hash
  before_validation :serialize_order
  after_create :cancel_previous_invoices

  def presenter
    @presenter ||= Invoice::DataPresenter.new(self)
  end

  def serialize_order
    return data unless data.empty?

    self.data = Invoice::OrderSerializer.new(order).serializable_hash
  end

  def cancel_previous_invoices
    order.invoices.where.not(id:).update_all(cancelled: true)
  end
end
