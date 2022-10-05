# frozen_string_literal: true

#  Copyright (c) 2022, Die Mitte. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

class AddTransactionXmlToPayments < ActiveRecord::Migration[6.1]
  def change
    add_column :payments, :transaction_xml, :text, size: :medium
  end
end
