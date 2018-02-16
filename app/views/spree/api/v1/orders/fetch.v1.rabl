object false
child(@orders => :orders) do
  object @order

  node(:order_identifier, &:number)
  node(:created_at, &:created_at)

  child shipping_address: :shipping_address do
    object @address
    cache [I18n.locale, root_object]

    excluded_attrs = %i[id country_id state_id full_name company state_name state_text]
    address_attrs = address_attributes.reject { |attrib| excluded_attrs.include?(attrib) }

    attributes(*address_attrs)

    node(:country) { |addr| addr.country.iso }
    node(:state) { |addr| addr.state.name }
  end

  child line_items: :line_items do
    object @line_item
    cache [I18n.locale, root_object]

    node(:sku) { |li| li.variant.sku }
    node(:quantity, &:quantity)
  end
end

node(:count) { @orders.count }
