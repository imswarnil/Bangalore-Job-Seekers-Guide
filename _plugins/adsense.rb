# File: _plugins/adsense.rb
#
# Creates a professional Liquid tag for Google AdSense.
# Usage: {% adsense type="square" %}

require 'liquid'

module Jekyll
  class AdSenseTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @args = text.strip.scan(/(\w+)\s*=\s*"(.*?)"/).to_h
    end

    def render(context)
      site = context.registers[:site]
      adsense_config = site.config['adsense'] || {}
      
      # Stop if ads are disabled in _config.yml (optional)
      return "" if adsense_config['enabled'] == false

      publisher_id = adsense_config['publisher_id'] || "ca-pub-1291242080282540"
      ad_type = @args['type']
      return "<!-- AdSense Error: 'type' parameter is missing. -->" unless ad_type

      # --- All Ad Unit Logic is Self-Contained Here ---
      slot_id, special_attributes = case ad_type
        when "square"
          ["7663977887", '']
        when "square-small"
          ["6066270853", '']
        when "square-medium"
          ["9619442326", '']
        when "leaderboard"
          ["1864856299", '']
        when "leaderboard-small"
          # NOTE: You'll need to create a 468x60 ad unit in AdSense for this
          ["YOUR_468x60_SLOT_ID", ''] 
        when "article"
          ["6501428979", 'data-ad-format="fluid" data-ad-layout="in-article"']
        when "feed"
          ["9130894804", 'data-ad-format="fluid" data-ad-layout-key="-6v+f0-19-44+c6"']
        when "multiplex"
          ["6808134701", 'data-ad-format="autorelaxed"']
        when "responsive-auto"
          # A generic responsive ad slot
          ["YOUR_AUTO_RESPONSIVE_SLOT_ID", 'data-ad-format="auto" data-full-width-responsive="true"']
        else
          return "<!-- AdSense Error: Unknown ad type '#{ad_type}'. -->"
      end

      # --- Generate Final HTML Output ---
      # The 'lazy-ad' class is the hook for our lazy loading JavaScript.
      <<~HTML
      <div class="ad-container ad-type-#{ad_type}">
        <ins class="adsbygoogle lazy-ad"
             data-ad-client="#{publisher_id}"
             data-ad-slot="#{slot_id}"
             #{special_attributes}></ins>
        <div class="ad-label">Advertisement</div>
      </div>
      HTML
    end
  end
end

Liquid::Template.register_tag('adsense', Jekyll::AdSenseTag)