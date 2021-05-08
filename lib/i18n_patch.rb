# Redmine plugin for Flexible Translation Terms
# Copyright (C) 2018    Massimo Rossello
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
require 'redmine/i18n'

# Redmine::I18n seems to have cases of localize called with other than Date, DateTime, Time in
# methods like format_date. Sometimes the I18n::l alias is not called.
module RedmineI18nPatch
  # localize
  def l(*args)
    if args.first.is_a?(Date) or args.first.is_a?(DateTime) or args.first.is_a?(Time)
      ::I18n.localize(*args)
    else
      super *args
    end
  end
end


# patch to add interpolated translations
module I18nPatch
    # translate with terms interpolation
    def translate(*args)
      options = args.last.is_a?(Hash) ? args.pop.dup : {}
      key = args.shift
      @overrides ||= Hash.new
      unless @overrides[I18n.locale]
        files = []
        Redmine::Plugin.registered_plugins.values.each do |plugin|
          files += Dir.glob(File.join(plugin.directory, 'config', 'overrides', I18n.locale.to_s, '*.yml'))
          files += Dir.glob(File.join(Rails.root, 'config', 'overrides', I18n.locale.to_s, '*.yml'))
        end
        files.sort {|x,y| File.basename(x) <=> File.basename(y)}.each do |file|
          @overrides[I18n.locale] ||= {}
          @overrides[I18n.locale].merge!( YAML::load_file(file).deep_symbolize_keys )
        end
      end
      options.merge! @overrides[I18n.locale] if @overrides[I18n.locale]
      super(key, options) rescue "translation missing: #{I18n.locale}.#{key}"
    end
    
    alias :t :translate
end

unless I18n.singleton_class.included_modules.include?(I18nPatch)
  I18n.singleton_class.send(:prepend, I18nPatch)
end

unless Redmine::I18n.included_modules.include?(RedmineI18nPatch)
  Redmine::I18n.send(:prepend, RedmineI18nPatch)
end
