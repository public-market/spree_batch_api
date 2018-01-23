object false
child(@orders => :orders) do
  extends 'spree/api/v1/orders/show'
end
node(:count) { @orders.count }
