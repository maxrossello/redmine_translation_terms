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

require 'redmine'

Rails.logger.info 'Translation terms'

Redmine::Plugin.register :redmine_translation_terms do
  name 'Redmine Translation Terms plugin'
  author 'Massimo Rossello'
  description 'Applies configured translations to general terms (e.g. issue -> work item, project -> workspace)'
  version '7.0.3'
  url 'https://github.com/maxrossello/redmine_translation_terms.git'
  author_url 'https://github.com/maxrossello'
  requires_redmine :version_or_higher => '7.0.3'
end


# STEP 1: Let's define a dedicated initializator in Rails 8 boot cycle
#class RedmineTranslationTermsInitializer < Rails::Railtie
#  initializer "redmine_translation_terms.hook_elocales", before: :load_config_initializers do |app|
#    # Now Redmine has registered ALL plugins, 
#    # but Rails 8 HASN'T indexed and frozen I18n.load_path yet
#    Redmine::Plugin.registered_plugins.values.each do |plugin|
#      elocales_path = Dir.glob(File.join(plugin.directory, 'config', 'elocales', '*.yml'))
#      app.config.i18n.load_path.concat(elocales_path) if elocales_path.any?
#    end
#  end
#end

# STEP 2: apply I18n patches only after Rails 8 has ended the framework configuration
# and the translation backends

Rails.configuration.after_initialize do
  require_relative 'lib/i18n_patch'
  require_relative 'lib/redmine_i18n_patch'
  
  # Tell Rails 8 that the backend has been modified and that it's ready
  I18n.reload! if Rails.env.test? || Rails.env.development?
end
