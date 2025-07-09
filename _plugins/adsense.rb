# File: _plugins/adsense.rb
#
# This plugin creates a custom Liquid tag `{% adsense %}` for Jekyll.
# It dynamically generates responsive and lazy-loaded Google AdSense ad units
# based on a clean configuration in _config.yml.

module Jekyll
  class AdSenseTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      # This regex efficiently parses named arguments like: type="square"
      @args = text.strip.scan(/(\w+)\s*=\s*"(.*?)"/).to_h
    end

    def render(context)
      # Get the full site configuration from Jekyll's context
      site = context.registers[:site]
      adsense_config = site.config['adsense']

      # 1. Gracefully fail if ads are disabled or the config section is missing
      return "" unless adsense_config && adsense_config['enabled']

      # 2. Extract the 'type' argument from the tag usage
      # e.g., in {% adsense type="square" %}, ad_type becomes "square"
      ad_type = @args['type']
      return "<!-- AdSense Error: 'type' parameter is missing. Usage: {% adsense type=\"your_ad_type\" %} -->" if ad_type.nil?

      # 3. Find the corresponding ad unit data in `_config.yml`
      # The `&.` is a safe navigation operator to prevent errors if `units` is missing.
      ad_unit = adsense_config['units']&.find { |unit| unit['type'] == ad_type }
      return "<!-- AdSense Error: Ad unit with type '#{ad_type}' not found in _config.yml. -->" if ad_unit.nil?

      # 4. Prepare all necessary data variables for building the HTML
      publisher_id = adsense_config.dig('publisher_id') || adsense_config.dig('publisher', 'id')
      slot_id = ad_unit['slot_id']
      
      # Dynamically build a string of data attributes. This is cleaner than multiple `if` statements.
      # It handles `format`, `layout`, and `layout_key` from your config.
      data_attributes = ""
      data_attributes += " data-ad-format=\"#{ad_unit['format']}\"" if ad_unit['format']
      data_attributes += " data-ad-layout=\"#{ad_unit['layout']}\"" if ad_unit['layout']
      data_attributes += " data-ad-layout-key=\"#{ad_unit['layout_key']}\"" if ad_unit['layout_key']

      # We intentionally do NOT add `data-full-width-responsive="true"` because we
      # want to have full control over responsiveness with our own SCSS.

      # 5. Generate the final, clean HTML block.
      #    - The `ad-container` gets a specific class like `ad-type-square` for styling.
      #    - The `ins` tag gets the `lazy-ad` class, which is the hook for our JavaScript.
      #    - The `<<~HTML` syntax is a "heredoc" which makes writing multi-line strings in Ruby clean.
      <<~HTML
      <div class="ad-container ad-type-#{ad_type}">
        <ins class="adsbygoogle lazy-ad"
             data-ad-client="#{publisher_id}"
             data-ad-slot="#{slot_id}"
             #{data_attributes}></ins>
        <div class="ad-label">Advertisement</div>
      </div>
      HTML
    end
  end
end

# This line officially registers our new `adsense` tag with Jekyll's Liquid engine.
Liquid::Template.register_tag('adsense', Jekyll::AdSenseTag)