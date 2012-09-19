class PersonDecorator < BaseDecorator
  decorates :person

  def as_typeahead
    {id: id, name: full_label}
  end
  
  def full_label
    label = to_s
    if company?
      name = "#{first_name} #{last_name}".strip
      label << "(#{name})" if name.present?
    else
      label << "(#{birthday.year})" if birthday
    end
    label
  end
end
