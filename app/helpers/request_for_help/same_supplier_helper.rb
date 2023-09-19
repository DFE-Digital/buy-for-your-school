module RequestForHelp
  module SameSupplierHelper
    def available_same_supplier_options
      I18nOption.from("faf.same_supplier.options.%%key%%", FrameworkRequest.same_supplier_useds.keys).in_order_of(:id, %w[yes no not_sure])
    end
  end
end
