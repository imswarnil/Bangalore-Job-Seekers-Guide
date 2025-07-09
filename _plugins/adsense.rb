# File: _plugins/adsense.rb
#
# Creates a professional, robust Liquid tag for Google AdSense.
# Usage: {% adsense type="square" %}
#
# Features:
# - Reads all configuration from _config.yml.
# - Handles errors gracefully if an ad type is missing or not found.
# - Automatically adds a 'lazy-ad' class for performance optimization.
# - Generates clean HTML with no inline styles.
# - Supports all ad formats from your config (display, fluid, autorelaxed, etc.).

require 'liquid'

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

      # 1. Gracefully stop if ads are globally disabled or the config is missing.
      return "" unless adsense_config && adsense_config['enabled']

      # 2. Extract the 'type' argument from the tag usage.
      ad_type = @args['type']
      return "<!-- AdSense Error: 'type' parameter is missing. Usage: {% adsense type=\"your_ad_type\" %} -->" if ad_type.nil?

      # 3. Find the corresponding ad unit data in `_config.yml`.
      # The `&.` is a safe navigation operator to prevent errors if `units` is missing.
      ad_unit = adsense_config['units']&.find { |unit| unit['type'] == ad_type }
      return "<!-- AdSense Error: Ad unit with type '#{ad_type}' not found in _config.yml. -->" if ad_unit.nil?

      # 4. Prepare all necessary data variables for building the HTML.
      publisher_id = adsense_config['publisher_id']
      slot_id = ad_unit['slot_id']
      
      # Build a string of data attributes dynamically from the config.
      data_attributes = ""
      data_attributes += " data-ad-format=\"#{ad_unit['format']}\"" if ad_unit['format']
      data_attributes += " data-ad-layout=\"#{ad_unit['layout']}\"" if ad_unit['layout']
      data_attributes += " data-ad-layout-key=\"#{ad_unit['layout_key']}\"" if ad_unit['layout_key']
      
      # 5. Generate the final, optimized HTML block.
      # The `lazy-ad` class is our hook for the JavaScript lazy loader.
      # The `ad-type-#{ad_type}` class is our hook for responsive CSS.
      <<~HTML
      <div class="ad-container ad-type-#{ad_type}">
        <ins class="adsbygoogle lazy-ad"
             data-ad-client="#{publisher_id}"
             data-ad-slot="#{slot_id}"#{data_attributes}></ins>
        <div class="ad-label">Advertisement</div>
      </div>
      HTML
    end
  end
end

# This line officially registers our new `adsense` tag with Jekyll's Liquid engine.
Liquid::Template.register_tag('adsense', Jekyll::AdSenseTag)