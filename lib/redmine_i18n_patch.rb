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

require 'redmine/i18n'

# Redmine::I18n seems to have cases of localize called with other than Date, DateTime, Time in
# methods like format_date. Sometimes the I18n::l alias is not called.
module RedmineI18nPatch
  # localize
  def l(*args, **options)
    if args.first.is_a?(Date) or args.first.is_a?(DateTime) or args.first.is_a?(Time)
      ::I18n.localize(*args, **options)
    else
      super *args, **options
    end
  end
end


unless Redmine::I18n.included_modules.include?(RedmineI18nPatch)
  Redmine::I18n.send(:prepend, RedmineI18nPatch)
end
