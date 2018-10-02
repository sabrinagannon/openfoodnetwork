# This class encapsulates a number of "indexes" used during product import. These contain hashes
# of information that need to be accessed at various stages of the import, and are built in order
# to minimise the number of queries that take place. So for instance, if a spreadsheet has 4000
# products for 5 different enterprises and we need to check the enterprise permissions for each
# product during validation, we have a small index for that data that gets built at the beginning
# so we don't have to make 4000 queries.

module ProductImport
  class SpreadsheetData
    def initialize(entries, import_settings)
      @entries = entries
      @import_settings = import_settings
    end

    def enterprises_index
      @enterprises_index || create_enterprises_index
    end

    def producers_index
      @producers_index = create_producers_index
    end

    def categories_index
      @categories_index || create_categories_index
    end

    def tax_index
      @tax_index || create_tax_index
    end

    def shipping_index
      @shipping_index || create_shipping_index
    end

    private

    def import_into_inventory?
      @import_settings[:settings] && @import_settings[:settings]['import_into'] == 'inventories'
    end

    def create_enterprises_index
      @enterprises_index = {}
      @entries.each do |entry|
        enterprise_name = import_into_inventory? ? entry.distributor : entry.producer
        next if @enterprises_index.key? enterprise_name
        enterprise = Enterprise.find_by_name(enterprise_name, select: 'id, name, is_primary_producer')
        @enterprises_index[enterprise_name] = { id: enterprise.try(:id), is_primary_producer: enterprise.try(:is_primary_producer) }
      end
      @enterprises_index
    end

    def create_producers_index
      @producers_index = {}
      @entries.each do |entry|
        next unless entry.producer
        producer_name = entry.producer
        producer_id = @producers_index[producer_name] || Enterprise.find_by_name(producer_name, select: 'id, name').try(:id)
        @producers_index[producer_name] = producer_id
      end
      @producers_index
    end

    def create_categories_index
      @categories_index = {}
      @entries.each do |entry|
        category_name = entry.category
        category_id = @categories_index[category_name] || Spree::Taxon.find_by_name(category_name, select: 'id, name').try(:id)
        @categories_index[category_name] = category_id
      end
      @categories_index
    end

    def create_tax_index
      @tax_index = {}
      Spree::TaxCategory.select([:id, :name]).map { |tc| @tax_index[tc.name] = tc.id }
      @tax_index
    end

    def create_shipping_index
      @shipping_index = {}
      Spree::ShippingCategory.select([:id, :name]).map { |sc| @shipping_index[sc.name] = sc.id }
      @shipping_index
    end
  end
end
