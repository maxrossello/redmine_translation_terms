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
  version '6.0.1'
  url 'https://github.com/maxrossello/redmine_translation_terms.git'
  author_url 'https://github.com/maxrossello'
  requires_redmine :version_or_higher => '6.0.1'
end

require_relative 'lib/i18n_patch'
require_relative 'lib/redmine_i18n_patch'

Rails.configuration.after_initialize do
  Redmine::Plugin.registered_plugins.values.each do |plugin|
    I18n.load_path += Dir.glob(File.join(plugin.directory, 'config', 'elocales', '*.yml'))
  end
end

