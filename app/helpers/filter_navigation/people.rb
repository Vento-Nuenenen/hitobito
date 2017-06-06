# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module FilterNavigation
  class People < Base

    attr_reader :group

    delegate :can?, to: :template

    def initialize(template, group, params)
      super(template)
      @group = group
      @params = params
      init_kind_filter_names
      init_labels
      init_kind_items
      init_dropdown_links
    end

    def name
      @params[:name]
    end

    def role_type_ids
      @params[:role_type_ids]
    end

    def qualification_kind_ids
      @params[:qualification_kind_id]
    end

    def deep
      @params[:kind] || false
    end

    def validity
      @params[:validity]
    end

    private

    def init_kind_filter_names
      @kind_filter_names = {}
      Role::Kinds.each do |kind|
        @kind_filter_names[kind] = I18n.t("activerecord.attributes.role.class.kind.#{kind}.other")
      end
    end

    def init_labels
      if name.present? && @kind_filter_names.values.include?(name)
        @active_label = name
      elsif name.present?
        dropdown.activate(name)
      elsif role_type_ids.present? || qualification_kind_ids.present?
        dropdown.activate(translate(:custom_filter))
      else
        @active_label = main_filter_name
      end
    end

    def init_kind_items
      @kind_filter_names.each do |kind, name|
        types = group.role_types.select { |t| t.kind == kind }
        if visible_role_types?(types)
          count = group.people.where(roles: { type: types.collect(&:sti_name) }).uniq.count
          path = kind == :member ? path : fixed_types_path(name, types)
          item(name, path, count)
        end
      end
    end

    def visible_role_types?(role_types)
      role_types.present? &&
        (role_types.any?(&:visible_from_above) ||
         can?(:index_local_people, group))
    end

    def main_filter_name
      @kind_filter_names.values.first
    end

    def init_dropdown_links
      if group.layer?
        add_entire_layer_filter_link
      else
        add_entire_subgroup_filter_link
      end
      add_people_role_filter_links
      add_define_people_role_filter_link
      add_define_qualification_filter_link
    end

    def add_entire_layer_filter_link
      name = translate(:entire_layer)
      link = fixed_types_path(name, sub_groups_role_types, kind: 'layer')
      dropdown.add_item(name, link)
    end

    def add_entire_subgroup_filter_link
      name = translate(:entire_group)
      link = fixed_types_path(name, sub_groups_role_types, kind: 'deep')
      dropdown.add_item(name, link)
    end

    def add_people_role_filter_links
      filters = PeopleFilter.for_group(group)
      filters.each { |filter| people_filter_link(filter) }
    end

    def add_define_people_role_filter_link
      if can?(:new, group.people_filters.new)
        dropdown.add_divider if dropdown.items.present?
        dropdown.add_item(translate(:new_role_filter), new_group_people_filter_path)
      end
    end

    def add_define_qualification_filter_link
      if can?(:index_full_people, group)
        dropdown.add_item(translate(:new_qualification_filter),
                          qualification_group_people_filter_path)
      end
    end

    def new_group_people_filter_path
      template.new_group_people_filter_path(
        group.id,
        kind: deep,
        people_filter: { role_type_ids: role_type_ids })
    end

    def qualification_group_people_filter_path
      template.qualification_group_people_filters_path(
        group.id,
        qualification_kind_id: qualification_kind_ids,
        kind: deep,
        validity: validity)
    end

    def people_filter_link(filter)
      item = dropdown.add_item(filter.name, filter_path(filter, kind: 'deep'))
      if can?(:destroy, filter)
        item.sub_items << delete_filter_item(filter)
      end
    end

    def delete_filter_item(filter)
      ::Dropdown::Item.new(template.icon(:trash),
                           delete_group_people_filter_path(filter),
                           data: { confirm: template.ti(:confirm_delete),
                                   method:  :delete })
    end

    def delete_group_people_filter_path(filter)
      template.group_people_filter_path(group, filter)
    end

    def fixed_types_path(name, types, options = {})
      filter_path(PeopleFilter.new(role_type_ids: types.collect(&:id), name: name), options)
    end

    def filter_path(filter, options = {})
      options[:role_type_ids] ||= filter.role_type_ids_string
      options[:name] ||= filter.name
      path(options)
    end

    def path(options = {})
      template.group_people_path(group, options)
    end

    def sub_groups_role_types
      type = group.klass
      group_types = collect_sub_group_types([type], type.possible_children)
      role_types = group_types.collect(&:role_types).flatten.uniq
      role_types.select(&:member?)
    end

    def collect_sub_group_types(all, types)
      types.each do |type|
        unless all.include?(type) || type.layer?
          all << type
          collect_sub_group_types(all, type.possible_children)
        end
      end

      all
    end

  end
end
