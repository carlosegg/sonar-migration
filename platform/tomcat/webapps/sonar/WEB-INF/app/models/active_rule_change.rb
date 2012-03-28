#
# Sonar, entreprise quality control tool.
# Copyright (C) 2008-2012 SonarSource
# mailto:contact AT sonarsource DOT com
#
# Sonar is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 3 of the License, or (at your option) any later version.
#
# Sonar is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with Sonar; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02
#
class ActiveRuleChange < ActiveRecord::Base
  belongs_to :rules_profile, :class_name => 'Profile', :foreign_key => 'profile_id'
  belongs_to :rule
  has_many :active_rule_param_changes, :dependent => :destroy

  def action_text
    case enabled
      when true then "on"
      when false then "off"
      when nil then "modified"
    end
  end

  def old_severity_text
    Sonar::RulePriority.to_s old_severity
  end

  def new_severity_text
    Sonar::RulePriority.to_s new_severity
  end

  def parameters
    active_rule_param_changes
  end

end
