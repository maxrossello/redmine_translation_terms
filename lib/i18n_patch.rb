# Redmine plugin for Flexible Translation Terms
# Copyright (C) 2018-   Massimo Rossello
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require 'i18n'
require 'yaml'

# Match the file name 'i18n_patch.rb' to satisfy Zeitwerk auto-loading rules
module I18nPatch

  def translate(locale, key, options = I18n::EMPTY_HASH)
    load_overrides_cache(locale)

    options.deep_merge!(@overrides[locale])
    
    super(locale, key, options)
  end

  protected

  # Intercept lookup to guarantee that custom templates from elocales take absolute precedence
  def lookup(locale, key, scope = [], options = I18n::EMPTY_HASH)
    load_elocales_cache(locale)

    # If our custom elocales contain the key, return the template string directly
    ref = key.is_a?(String) ? key.to_sym : key
    if @elocales[locale] && @elocales[locale].key?(ref)
      return @elocales[locale][ref]
    end

    # Fallback to standard Rails 8 lookup if no custom template is defined
    super(locale, key, scope, options)
  end

  private

  # Cache the custom tokenized templates from elocales safely preventing pre-boot empty states
  def load_elocales_cache(locale)
    @elocales ||= {}
    return if @elocales_loaded_ready && @elocales.key?(locale)

    # Mark as initialized to prevent immediate recursion loops during files reading
    @elocales[locale] ||= {}

    plugins = Redmine::Plugin.registered_plugins.values
    return if plugins.empty?

    plugins.each do |plugin|
      # Look for files named 'it.yml', 'en.yml' inside config/elocales/
      files = Dir.glob(File.join(plugin.directory, 'config', 'elocales', "#{locale}.yml"))
      files.each do |file|
        begin
          data = YAML.load_file(file, aliases: true)
          @elocales.deep_merge!(data.deep_symbolize_keys) if data.is_a?(Hash)
        rescue => e
          $stderr.puts "Error loading elocales file #{file}: #{e.message}"
        end
      end
    end

    @elocales_loaded_ready = true
  end

  # Cache the final term replacements from overrides safely preventing pre-boot empty states
  def load_overrides_cache(locale)
    @overrides ||= {}
    return if @overrides_loaded_ready && @overrides.key?(locale)

    # Mark as initialized to prevent immediate recursion loops
    @overrides[locale] ||= {}
    
    plugins = Redmine::Plugin.registered_plugins.values
    return if plugins.empty?

    # Look for files inside config/overrides/it/ or config/overrides/en/
    files = Dir.glob(File.join(Rails.root, 'config', 'overrides', locale.to_s, '*.yml'))
    
    plugins.each do |plugin|
      files += Dir.glob(File.join(plugin.directory, 'config', 'overrides', locale.to_s, '*.yml'))
    end
    
    files.sort { |x, y| File.basename(x) <=> File.basename(y) }.each do |file|
      begin
        data = YAML.load_file(file, aliases: true)
        # Assuming the overrides file maps target terms to replacement values
        @overrides[locale].merge!(data.deep_symbolize_keys) if data.is_a?(Hash)
      rescue => e
        $stderr.puts "Error loading translation override file #{file}: #{e.message}"
      end
    end

    @overrides_loaded_ready = true
  end
end

# Apply the patch directly to the Simple Backend used by Rails 8
unless I18n::Backend::Simple.included_modules.include?(I18nPatch)
  I18n::Backend::Simple.send(:prepend, I18nPatch)
end
