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

# provide a fix for ::I18n.l calls module local Redmine::I18n.l instead of following ::I18n alias
# this seems to affect Redmine 3.4, not 4.x
# using explicit ::I18n.localize in format_date and format_time is not sufficient for issue to localize errors properly
module Redmine
  module I18n
    def l(*args)
      case args.size
      when 1
        ::I18n.t(*args)
      when 2
        if args.first.is_a?(Date)
          ::I18n.localize(*args)
        elsif args.last.is_a?(Hash)
          ::I18n.t(*args)
        elsif args.last.is_a?(String)
          ::I18n.t(args.first, :value => args.last)
        else
          ::I18n.t(args.first, :count => args.last)
        end
      else
        raise "Translation string with multiple values: #{args.first}"
      end
    end
  end
end

# patch to add interpolated translations
module I18nPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.class_eval do
      unloadable
      class << self
        alias_method_chain :translate, :interpolation
        alias :t_with_interpolation :translate_with_interpolation
        alias_method_chain :t, :interpolation
      end
    end
  end

  module ClassMethods
    def translate_with_interpolation(*args)
      options = args.last.is_a?(Hash) ? args.pop.dup : {}
      key = args.shift
      @overrides ||= Hash.new
      unless @overrides[I18n.locale]
        files = []
        Redmine::Plugin.registered_plugins.values.each do |plugin|
          files += Dir.glob(File.join(plugin.directory, 'config', 'overrides', I18n.locale.to_s, '*.yml'))
        end
        files.sort {|x,y| File.basename(x) <=> File.basename(y)}.each do |file|
          @overrides[I18n.locale] ||= {}
          @overrides[I18n.locale].merge!( YAML::load_file(file).deep_symbolize_keys )
        end
      end
      options.merge! @overrides[I18n.locale] if @overrides[I18n.locale]
      translate_without_interpolation(key, options) rescue "translation missing: #{I18n.locale}.#{key}"
    end

    def format_date_with_fix(date)
      return nil unless date
      options = {}
      options[:format] = Setting.date_format unless Setting.date_format.blank?
      ::I18n.localize(date.to_date, options)
    end
    
    def format_time_with_fix(time, include_date=true, user=nil)
      return nil unless time
      user ||= User.current
      options = {}
      options[:format] = (Setting.time_format.blank? ? :time : Setting.time_format)
      time = time.to_time if time.is_a?(String)
      zone = user.time_zone
      local = zone ? time.in_time_zone(zone) : (time.utc? ? time.localtime : time)
      (include_date ? "#{format_date(local)} " : "") + ::I18n.localize(local, options)
    end
    
    def l_with_fix(*args)
      case args.size
      when 1
        ::I18n.t(*args)
      when 2
        if args.first.is_a?(Date)
          ::I18n.localize(*args)
        elsif args.last.is_a?(Hash)
          ::I18n.t(*args)
        elsif args.last.is_a?(String)
          ::I18n.t(args.first, :value => args.last)
        else
          ::I18n.t(args.first, :count => args.last)
        end
      else
        raise "Translation string with multiple values: #{args.first}"
      end
    end

  end
end

unless I18n.included_modules.include?(I18nPatch)
  I18n.send(:include, I18nPatch)
end


