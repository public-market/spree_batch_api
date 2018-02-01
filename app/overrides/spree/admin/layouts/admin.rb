Deface::Override.new(
  virtual_path:  'spree/layouts/admin',
  name:          'uploads_main_menu_tabs',
  insert_bottom: '#main-sidebar',
  text:       <<-HTML
                <% if current_spree_user.respond_to?(:has_spree_role?) && current_spree_user.has_spree_role?(:admin) %>
                  <ul class="nav nav-sidebar">
                    <%= tab 'Uploads', url: admin_uploads_path, icon: 'cloud-upload' %>
                  </ul>
                <% end %>
                <% if current_spree_vendor %>
                  <ul class="nav nav-sidebar">
                    <%= tab 'Uploads', url: admin_uploads_path, icon: 'cloud-upload' %>
                  </ul>
                <% end %>
              HTML
)
