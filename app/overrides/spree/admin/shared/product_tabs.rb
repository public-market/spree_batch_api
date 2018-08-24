Deface::Override.new(
  virtual_path:  'spree/admin/shared/_product_tabs',
  name:          'uploads_product_menu_tabs',
  insert_bottom: 'ul[data-hook="admin_product_tabs"]',
  text:       <<-HTML
                <%= content_tag :li, class: ('active' if current == :product_uploads) do %>
                  <%= link_to_with_icon 'cloud-upload', 'Inventory uploads', inventory_uploads_admin_product_url(@product) %>
                <% end if can?(:admin, Spree::Upload) && !@product.deleted? %>
              HTML
)
