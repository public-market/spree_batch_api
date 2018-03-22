object @address
cache [I18n.locale, root_object]

excluded_attrs = %i[id country_id state_id full_name company state_name state_text]
address_attrs = address_attributes.reject { |attrib| excluded_attrs.include?(attrib) }

attributes(*address_attrs)

node(:country) { |addr| addr.country.iso }
node(:state) { |addr| addr.state.name }
