object false
child(@orders => :orders) do
  object @order

  node(:order_identifier, &:number)
  node(:created_at, &:created_at)

  child shipping_address: :shipping_address do
    extends 'spree/api/v1/addresses/show_small'
  end

  child line_items: :line_items do
    extends 'spree/api/v1/line_items/show_small'
  end
end

node(:count) { @orders.count }
