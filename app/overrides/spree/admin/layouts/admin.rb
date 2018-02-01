Deface::Override.new(
  virtual_path:  'spree/layouts/admin',
  name:          'uploads_main_menu_tabs',
  insert_bottom: '#main-sidebar',
  text:       <<-HTML
                <% if can?(:display, Spree::Upload) %>
                  <ul class="nav nav-sidebar">
                    <%= tab 'Uploads', url: admin_uploads_path, icon: 'cloud-upload' %>
                  </ul>
                <% end %>
              HTML
)
